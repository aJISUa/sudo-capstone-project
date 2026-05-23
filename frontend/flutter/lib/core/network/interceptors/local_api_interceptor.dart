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
    'GET /diet/days/today': _dietToday,
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
