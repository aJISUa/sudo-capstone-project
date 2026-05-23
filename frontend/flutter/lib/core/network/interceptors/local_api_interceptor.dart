import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart'
    show OrderClauseGenerator, OrderingMode, OrderingTerm, Value;
import 'package:logger/logger.dart';

import 'package:oncare/core/storage/app_database.dart';

/// A drift-backed dummy backend. Intercepts dio requests and serves
/// them out of the local SQLite database so the app can run as a
/// "local backend" before the real FastAPI server exists.
///
/// Path dispatch is done in `_handle()` — handlers return `null` to
/// fall through to the next interceptor (and ultimately to the real
/// network when `USE_MOCK_API=false`).
///
/// snake_case payloads are produced/consumed via
/// `core/network/case_mapper.dart` so the contract matches the real
/// server's Pydantic models.
class LocalApiInterceptor extends Interceptor {
  LocalApiInterceptor(this._db, this._logger);

  final AppDatabase _db;
  final Logger _logger;

  // Path-pattern → handler map. Static paths get O(1) dispatch;
  // path-with-id endpoints (`/diet/entries/{id}`) fall to the regex
  // section below.
  late final Map<String, _Handler> _routes = <String, _Handler>{
    'GET /ping': _ping,
    'GET /healthz': _healthz,
    'GET /version': _version,
    'GET /dashboard/summary': _dashboardSummary,
    'GET /diet/days/today': _dietToday,
    'GET /exercise/weeks/current': _exerciseCurrentWeek,
    'GET /schedule/events': _scheduleEvents,
    'GET /notifications': _notifications,
    'GET /ai-coach/feedback': _aiCoachFeedback,
    'GET /users/me': _usersMe,
    'GET /users/me/health': _usersMeHealth,
    'GET /places/nearby': _placesNearby,
    // Vitals — three fixed kinds (weight | blood-pressure | blood-sugar).
    'POST /vitals/weight': _vitalsSubmit,
    'POST /vitals/blood-pressure': _vitalsSubmit,
    'POST /vitals/blood-sugar': _vitalsSubmit,
    'GET /vitals/weight/latest': _vitalsLatest,
    'GET /vitals/blood-pressure/latest': _vitalsLatest,
    'GET /vitals/blood-sugar/latest': _vitalsLatest,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final response = await _safeHandle(options);
    if (response != null) {
      handler.resolve(response);
      return;
    }
    handler.next(options);
  }

  Future<Response<Object?>?> _safeHandle(RequestOptions options) async {
    final method = options.method.toUpperCase();
    final path = options.path;
    final key = '$method $path';

    try {
      // Static dispatch first.
      final exact = _routes[key];
      if (exact != null) {
        _logger.d('[local-api] $key (exact)');
        return await exact(options);
      }
      // (Regex routes will be added by later phases — diet/exercise/
      // vitals/notifications/schedule etc.)
      return null;
    } catch (e, st) {
      _logger.e('[local-api] $key failed', error: e, stackTrace: st);
      return Response<Object?>(
        requestOptions: options,
        statusCode: 500,
        data: <String, Object?>{
          'code': 'internal_error',
          'message': e.toString(),
        },
      );
    }
  }

  // ---- handlers ----

  Future<Response<Object?>> _ping(RequestOptions options) async {
    return _ok(options, <String, Object?>{'message': 'pong (local)'});
  }

  Future<Response<Object?>> _healthz(RequestOptions options) async {
    return _ok(options, <String, Object?>{
      'status': 'ok',
      'backend': 'drift-local',
    });
  }

  Future<Response<Object?>> _version(RequestOptions options) async {
    return _ok(options, <String, Object?>{
      'api_version': 'v1',
      'app_version': '0.2.0+2',
    });
  }

  // ---- Dashboard ----

  Future<Response<Object?>> _dashboardSummary(RequestOptions options) async {
    final today = _todayDateString();

    // Diet aggregates.
    final dietRows = await (_db.select(
      _db.dietEntries,
    )..where((t) => t.date.equals(today))).get();
    int totalCalories = 0;
    int totalSodium = 0;
    int totalSugar = 0;
    for (final r in dietRows) {
      totalCalories += r.totalCalories;
      totalSodium += r.sodiumMg;
      totalSugar += r.sugarG;
    }

    // Exercise minutes for today's day-label.
    final todayLabel = _weekdayLabels[DateTime.now().weekday - 1];
    final weekStart = _mondayOfThisWeekString();
    // Two chained .where() calls are AND-joined by drift.
    final exerciseRows =
        await (_db.select(_db.exerciseSessions)
              ..where((t) => t.weekStart.equals(weekStart))
              ..where((t) => t.dayLabel.equals(todayLabel)))
            .get();
    int exerciseMinutes = 0;
    for (final r in exerciseRows) {
      exerciseMinutes += r.minutes;
    }

    // Latest blood sugar reading (mg/dL) — defaults to 0 when none.
    int bloodSugar = 0;
    final bsRow =
        await (_db.select(_db.vitals)
              ..where((t) => t.kind.equals('blood-sugar'))
              ..orderBy(<OrderClauseGenerator<$VitalsTable>>[
                (t) => OrderingTerm(
                  expression: t.recordedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (bsRow != null) {
      final v = jsonDecode(bsRow.valueJson) as Map<Object?, Object?>;
      final raw = v['mg_per_dl'];
      if (raw is num) bloodSugar = raw.toInt();
    }

    // Today's schedule items.
    final schedRows = await (_db.select(
      _db.scheduleEvents,
    )..where((t) => t.date.equals(today))).get();
    final schedJson = <Map<String, Object?>>[
      for (final r in schedRows)
        <String, Object?>{'time': r.time, 'title': r.title, 'emoji': r.emoji},
    ];

    // Heuristic "week score": stretch diet+exercise into a 0..100 band
    // so the card always renders something even on an empty database.
    final calRatio = (totalCalories / 2000.0).clamp(0.0, 1.0);
    final exRatio = (exerciseMinutes / 60.0).clamp(0.0, 1.0);
    final score = (50 + calRatio * 25 + exRatio * 25).round();

    return _ok(options, <String, Object?>{
      'indicators': <Map<String, Object?>>[
        <String, Object?>{
          'label': '칼로리',
          'current': totalCalories,
          'max': 2000,
          'unit': 'kcal',
        },
        <String, Object?>{
          'label': '나트륨',
          'current': totalSodium,
          'max': 2000,
          'unit': 'mg',
          'over_budget': totalSodium > 2000,
        },
        <String, Object?>{
          'label': '당류',
          'current': totalSugar,
          'max': 50,
          'unit': 'g',
        },
        <String, Object?>{
          'label': '혈당',
          'current': bloodSugar,
          'max': 120,
          'unit': 'mg/dL',
        },
      ],
      'diet_entries': dietRows.length,
      'exercise_minutes': exerciseMinutes,
      'today_schedule': schedJson,
      'week_score': score,
      // Delta is a static demo number for now — full week-over-week
      // diff lands in a later phase.
      'week_score_delta': 12,
      'sodium_warning': totalSodium > 2000
          ? '오늘의 나트륨 섭취량이 높아요. 저녁에는 담백한 구이나 샐러드를 추천해요!'
          : null,
    });
  }

  // ---- Diet ----

  Future<Response<Object?>> _dietToday(RequestOptions options) async {
    final today = _todayDateString();
    final rows = await (_db.select(
      _db.dietEntries,
    )..where((t) => t.date.equals(today))).get();

    int totalCalories = 0;
    int totalSodium = 0;
    int totalSugar = 0;
    final entriesJson = <Map<String, Object?>>[];
    for (final r in rows) {
      totalCalories += r.totalCalories;
      totalSodium += r.sodiumMg;
      totalSugar += r.sugarG;
      entriesJson.add(<String, Object?>{
        'id': r.id,
        'meal_type': r.mealType,
        'time_label': r.timeLabel,
        'foods': (jsonDecode(r.foodsJson) as List<Object?>).cast<Object?>(),
        'total_calories': r.totalCalories,
        'sodium_mg': r.sodiumMg,
        'sugar_g': r.sugarG,
      });
    }

    return _ok(options, <String, Object?>{
      'entries': entriesJson,
      'total_calories': totalCalories,
      'total_sodium_mg': totalSodium,
      'total_sugar_g': totalSugar,
      // Macro breakdown isn't tracked per entry yet — return the
      // demo split until a richer schema lands.
      'macros': <String, Object?>{
        'carbs_pct': 50,
        'protein_pct': 30,
        'fat_pct': 20,
      },
      'ai_coach_message': totalSodium > 2000
          ? '오늘 점심에 나트륨이 많았어요. 저녁은 담백한 구이/샐러드로 균형을 맞춰봐요!'
          : '균형 잡힌 하루였어요. 내일도 이대로 가요!',
    });
  }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ---- Exercise ----

  static const List<String> _weekdayLabels = <String>[
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일',
  ];

  Future<Response<Object?>> _exerciseCurrentWeek(RequestOptions options) async {
    final weekStart = _mondayOfThisWeekString();
    final rows = await (_db.select(
      _db.exerciseSessions,
    )..where((t) => t.weekStart.equals(weekStart))).get();

    // Aggregate minutes per day-label so the bar chart can render even
    // when a day is missing (React mock left Tue=0).
    final perDay = <String, int>{for (final l in _weekdayLabels) l: 0};
    int totalMinutes = 0;
    int totalCalories = 0;
    final sessionsJson = <Map<String, Object?>>[];

    for (final r in rows) {
      totalMinutes += r.minutes;
      totalCalories += r.calories;
      perDay.update(
        r.dayLabel,
        (m) => m + r.minutes,
        ifAbsent: () => r.minutes,
      );
      sessionsJson.add(<String, Object?>{
        'id': r.id,
        'day_label': r.dayLabel,
        'type': r.type,
        'minutes': r.minutes,
        'calories': r.calories,
      });
    }

    final dailyMinutes = <num>[for (final l in _weekdayLabels) perDay[l] ?? 0];

    // "Streak" = consecutive non-zero days ending at today's weekday
    // (or simply the count of non-zero days for the simple mock).
    final streak = dailyMinutes.where((m) => m > 0).length;

    return _ok(options, <String, Object?>{
      'sessions': sessionsJson,
      'daily_minutes': dailyMinutes,
      'day_labels': _weekdayLabels,
      'total_minutes': totalMinutes,
      'total_calories': totalCalories,
      'streak_days': streak,
      'ai_coach_message': totalMinutes >= 240
          ? '주간 운동 목표 80%를 달성했어요! 일요일에 가볍게 걷기를 더해 100%를 채워봐요.'
          : '이번 주는 운동량이 조금 부족해요. 가벼운 산책부터 다시 시작해 봐요.',
    });
  }

  // ---- Schedule ----

  Future<Response<Object?>> _scheduleEvents(RequestOptions options) async {
    // `?date=YYYY-MM-DD`. Defaults to today.
    final date =
        (options.queryParameters['date'] as String?) ?? _todayDateString();
    final rows = await (_db.select(
      _db.scheduleEvents,
    )..where((t) => t.date.equals(date))).get();

    final list = <Map<String, Object?>>[
      for (final r in rows)
        <String, Object?>{
          'id': r.id,
          'date': r.date,
          'time': r.time,
          'title': r.title,
          'category': r.category,
          'emoji': r.emoji,
          'color_hex': r.colorHex,
        },
    ];
    return _ok(options, list);
  }

  // ---- Notifications ----

  Future<Response<Object?>> _notifications(RequestOptions options) async {
    final query = _db.select(_db.notificationItems)
      ..orderBy(<OrderClauseGenerator<$NotificationItemsTable>>[
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    final rows = await query.get();

    final now = DateTime.now();
    final list = <Map<String, Object?>>[
      for (final r in rows)
        <String, Object?>{
          'id': r.id,
          'title': r.title,
          'body': r.body,
          'category': r.category,
          'read': r.read,
          'created_at': r.createdAt.toIso8601String(),
          'time_ago': _timeAgoKorean(now.difference(r.createdAt)),
        },
    ];
    return _ok(options, list);
  }

  // ---- AI Coach ----

  Future<Response<Object?>> _aiCoachFeedback(RequestOptions options) async {
    return _ok(options, <String, Object?>{
      'greeting': '안녕하세요, 오늘 컨디션은 어떠세요?',
      'suggestions': <Map<String, Object?>>[
        <String, Object?>{
          'tag': 'diet',
          'title': '점심에 단백질을 +10g 추가해 보세요',
          'body': '오전 운동량을 보면 점심에 단백질을 조금 더 채우는 것이 좋아요.',
        },
        <String, Object?>{
          'tag': 'exercise',
          'title': '저녁 산책 15분',
          'body': '저녁 시간대 가벼운 유산소는 수면의 질도 함께 끌어올립니다.',
        },
        <String, Object?>{
          'tag': 'hydration',
          'title': '수분 보충',
          'body': '오늘 평소보다 활동량이 많았어요. 물 한 컵 더 마셔봐요.',
        },
        <String, Object?>{
          'tag': 'sleep',
          'title': '취침 1시간 전 화면 줄이기',
          'body': '깊은 수면 비율이 낮은 패턴이 보입니다. 자극을 줄여보세요.',
        },
      ],
    });
  }

  // ---- Users / Me ----

  Future<Response<Object?>> _usersMe(RequestOptions options) async {
    return _ok(options, <String, Object?>{
      'id': 'user-demo',
      'name': '김민수',
      'email': 'minsu@oncare.com',
    });
  }

  Future<Response<Object?>> _usersMeHealth(RequestOptions options) async {
    return _ok(options, <String, Object?>{
      'profile': <String, Object?>{'name': '김민수', 'email': 'minsu@oncare.com'},
      'risk': <String, Object?>{
        'title': '고혈압·당뇨 위험 주의',
        'body': '최근 혈압과 혈당 추세가 다소 높습니다. 식단·운동 관리에 신경 써주세요.',
        'level': 'medium',
      },
      'indicators': <Map<String, Object?>>[
        <String, Object?>{
          'kind': 'weight',
          'label': '체중',
          'latest_value': '68.2',
          'unit': 'kg',
          'delta_text': '-1.2kg (지난주 대비)',
          'improving': true,
          'last_7_days': <double>[0.95, 0.92, 0.90, 0.86, 0.83, 0.80, 0.76],
        },
        <String, Object?>{
          'kind': 'blood-pressure',
          'label': '혈압',
          'latest_value': '124/82',
          'unit': 'mmHg',
          'delta_text': '+4 (지난주 대비)',
          'improving': false,
          'last_7_days': <double>[0.60, 0.62, 0.65, 0.70, 0.74, 0.78, 0.80],
        },
        <String, Object?>{
          'kind': 'blood-sugar',
          'label': '혈당',
          'latest_value': '95',
          'unit': 'mg/dL',
          'delta_text': '-3 (지난주 대비)',
          'improving': true,
          'last_7_days': <double>[0.75, 0.74, 0.72, 0.71, 0.70, 0.69, 0.65],
        },
      ],
      'activity_points': 1240,
      'activity_rank': 14,
      'settings': <Map<String, Object?>>[
        <String, Object?>{'label': '개인 정보', 'icon': '👤'},
        <String, Object?>{'label': '건강 데이터', 'icon': '📊'},
        <String, Object?>{'label': '알림 설정', 'icon': '🔔'},
        <String, Object?>{'label': '고객 지원', 'icon': '💬'},
      ],
    });
  }

  // ---- Places ----

  Future<Response<Object?>> _placesNearby(RequestOptions options) async {
    return _ok(options, <Map<String, Object?>>[
      <String, Object?>{
        'id': 'p1',
        'name': '강남세브란스 가정의학과',
        'category': 'medical',
        'address': '서울특별시 강남구 테헤란로 123',
        'distance_meters': 420,
        'lat': 37.4979,
        'lng': 127.0276,
      },
      <String, Object?>{
        'id': 'p2',
        'name': '온케어 피트니스',
        'category': 'fitness',
        'address': '서울특별시 강남구 역삼로 55',
        'distance_meters': 680,
        'lat': 37.5005,
        'lng': 127.0319,
      },
      <String, Object?>{
        'id': 'p3',
        'name': '그린 샐러드 바',
        'category': 'healthy_food',
        'address': '서울특별시 강남구 강남대로 311',
        'distance_meters': 250,
        'lat': 37.4970,
        'lng': 127.0270,
      },
      <String, Object?>{
        'id': 'p4',
        'name': '24시간 메디팜약국',
        'category': 'pharmacy',
        'address': '서울특별시 강남구 테헤란로 99',
        'distance_meters': 800,
        'lat': 37.4995,
        'lng': 127.0263,
      },
    ]);
  }

  String _timeAgoKorean(Duration d) {
    if (d.inMinutes < 1) return '방금';
    if (d.inMinutes < 60) return '${d.inMinutes}분 전';
    if (d.inHours < 24) return '${d.inHours}시간 전';
    if (d.inDays == 1) return '어제';
    return '${d.inDays}일 전';
  }

  String _mondayOfThisWeekString() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return '${monday.year.toString().padLeft(4, '0')}-'
        '${monday.month.toString().padLeft(2, '0')}-'
        '${monday.day.toString().padLeft(2, '0')}';
  }

  // ---- Vitals ----

  /// Path tail → drift `kind` value. Centralised so POST and GET
  /// agree on the same string.
  String? _kindFromPath(String path) {
    if (path.startsWith('/vitals/weight')) return 'weight';
    if (path.startsWith('/vitals/blood-pressure')) return 'blood-pressure';
    if (path.startsWith('/vitals/blood-sugar')) return 'blood-sugar';
    return null;
  }

  Future<Response<Object?>> _vitalsSubmit(RequestOptions options) async {
    final kind = _kindFromPath(options.path);
    if (kind == null) {
      return _badRequest(options, 'unknown vital kind: ${options.path}');
    }

    final body = options.data;
    Map<String, Object?> payload;
    if (body is Map) {
      payload = body.cast<String, Object?>();
    } else if (body is String && body.isNotEmpty) {
      payload = (jsonDecode(body) as Map<Object?, Object?>)
          .cast<String, Object?>();
    } else {
      payload = <String, Object?>{};
    }

    // Pluck `recorded_at` off the payload (if provided) and store the
    // rest as the value blob.
    final recordedAtRaw = payload.remove('recorded_at');
    final recordedAt = recordedAtRaw is String && recordedAtRaw.isNotEmpty
        ? DateTime.parse(recordedAtRaw)
        : DateTime.now();

    final id = 'v-${DateTime.now().microsecondsSinceEpoch}';
    await _db
        .into(_db.vitals)
        .insert(
          VitalsCompanion(
            id: Value<String>(id),
            kind: Value<String>(kind),
            valueJson: Value<String>(jsonEncode(payload)),
            recordedAt: Value<DateTime>(recordedAt),
          ),
        );

    return _ok(options, <String, Object?>{
      'id': id,
      'kind': kind,
      'value': payload,
      'recorded_at': recordedAt.toIso8601String(),
    });
  }

  Future<Response<Object?>> _vitalsLatest(RequestOptions options) async {
    final kind = _kindFromPath(options.path);
    if (kind == null) {
      return _badRequest(options, 'unknown vital kind: ${options.path}');
    }

    final query = _db.select(_db.vitals)
      ..where((t) => t.kind.equals(kind))
      ..orderBy(<OrderClauseGenerator<$VitalsTable>>[
        (t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc),
      ])
      ..limit(1);
    final row = await query.getSingleOrNull();

    if (row == null) {
      // No reading yet — return a 200 with empty body so the client
      // can treat null as "no data". (FastAPI will mirror this with
      // an explicit nullable response model.)
      return _ok(options, <String, Object?>{});
    }

    return _ok(options, <String, Object?>{
      'id': row.id,
      'kind': row.kind,
      'value': (jsonDecode(row.valueJson) as Map<Object?, Object?>)
          .cast<String, Object?>(),
      'recorded_at': row.recordedAt.toIso8601String(),
    });
  }

  // ---- helpers ----

  /// Build a 200 OK response carrying [body]. Subclasses of handlers
  /// will build their bodies as plain Map/List structures (snake_case)
  /// before passing in.
  Response<Object?> _ok(RequestOptions options, Object? body) {
    return Response<Object?>(
      requestOptions: options,
      statusCode: 200,
      data: body,
    );
  }

  Response<Object?> _badRequest(RequestOptions options, String message) {
    return Response<Object?>(
      requestOptions: options,
      statusCode: 400,
      data: <String, Object?>{'code': 'bad_request', 'message': message},
    );
  }

  /// Expose the database to test scaffolding without leaking internals.
  AppDatabase get database => _db;
}

typedef _Handler = Future<Response<Object?>> Function(RequestOptions);
