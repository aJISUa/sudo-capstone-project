import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'package:oncare/core/network/interceptors/local_api_interceptor.dart';
import 'package:oncare/core/storage/app_database.dart';

void main() {
  late AppDatabase db;
  late Dio dio;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(LocalApiInterceptor(db, Logger(level: Level.off)));
  });

  tearDown(() async {
    await db.close();
    dio.close();
  });

  test('GET /ai-coach/feedback returns greeting + 3 suggestions', () async {
    final res = await dio.get<Map<String, Object?>>('/ai-coach/feedback');
    expect(res.statusCode, 200);
    expect(res.data!['greeting'], isNotEmpty);
    final suggestions = (res.data!['suggestions']! as List<Object?>)
        .cast<Map<String, Object?>>();
    expect(suggestions.length, 3);
    final tags = suggestions.map((s) => s['tag']! as String).toSet();
    expect(
      tags,
      containsAll(<String>['diet', 'exercise', 'hydration']),
    );
  });

  test('GET /users/me returns the demo profile', () async {
    final res = await dio.get<Map<String, Object?>>('/users/me');
    expect(res.statusCode, 200);
    expect(res.data!['email'], 'minsu@oncare.com');
  });

  test('GET /users/me/health returns the full MyHealthState shape', () async {
    final res = await dio.get<Map<String, Object?>>('/users/me/health');
    expect(res.statusCode, 200);
    final body = res.data!;
    expect((body['profile']! as Map)['name'], '김민수');
    expect((body['risk']! as Map)['level'], 'medium');
    final indicators = (body['indicators']! as List<Object?>)
        .cast<Map<String, Object?>>();
    expect(indicators.length, 3);
    expect(indicators.map((i) => i['kind']).toList(), <String>[
      'weight',
      'blood-pressure',
      'blood-sugar',
    ]);
    expect(body['activity_points'], 1240);
  });

  test('GET /places/nearby returns four places with all categories', () async {
    final res = await dio.get<List<Object?>>('/places/nearby');
    expect(res.statusCode, 200);
    final places = res.data!.cast<Map<String, Object?>>();
    expect(places.length, 4);
    final categories = places.map((p) => p['category']! as String).toSet();
    expect(
      categories,
      containsAll(<String>['medical', 'fitness', 'healthy_food', 'pharmacy']),
    );
  });

  test('GET /healthz returns drift-local marker', () async {
    final res = await dio.get<Map<String, Object?>>('/healthz');
    expect(res.statusCode, 200);
    expect(res.data!['status'], 'ok');
    expect(res.data!['backend'], 'drift-local');
  });

  test('POST /ai-coach/chat returns a grounded reply with sources', () async {
    final res = await dio.post<Map<String, Object?>>(
      '/ai-coach/chat',
      data: <String, Object?>{'message': '나트륨을 줄이려면 어떻게 해요?'},
    );
    expect(res.statusCode, 200);
    expect(res.data!['reply'], isNotEmpty);
    final sources = (res.data!['sources']! as List<Object?>).cast<String>();
    expect(sources, contains('나트륨 줄이기'));
  });

  test('POST /ai-coach/chat rejects an empty message', () async {
    final res = await dio.post<Map<String, Object?>>(
      '/ai-coach/chat',
      data: <String, Object?>{'message': '   '},
      options: Options(validateStatus: (int? s) => true),
    );
    expect(res.statusCode, 400);
  });

  test('PUT /users/me persists profile; GET /users/me/profile + /users/me reflect it', () async {
    final put = await dio.put<Map<String, Object?>>(
      '/users/me',
      data: <String, Object?>{'name': '이순신', 'phone': '010-9999-0000'},
    );
    expect(put.statusCode, 200);
    expect(put.data!['name'], '이순신');

    final prof = await dio.get<Map<String, Object?>>('/users/me/profile');
    expect(prof.data!['name'], '이순신');
    expect(prof.data!['phone'], '010-9999-0000');
    expect(prof.data!['email'], 'minsu@oncare.com'); // 안 바꾼 값은 기본 유지

    final me = await dio.get<Map<String, Object?>>('/users/me');
    expect(me.data!['name'], '이순신');
  });

  test('PUT /users/me/health-goals persists goals', () async {
    await dio.put<Map<String, Object?>>(
      '/users/me/health-goals',
      data: <String, Object?>{'goal_weight_kg': 65, 'daily_sodium_mg': 1800},
    );
    final prof = await dio.get<Map<String, Object?>>('/users/me/profile');
    expect(prof.data!['goal_weight_kg'], 65);
    expect(prof.data!['daily_sodium_mg'], 1800);
    expect(prof.data!['goal_bp_systolic'], 120); // 미변경 목표는 기본 유지
  });

  test('POST /auth/login issues a token for non-empty credentials', () async {
    final res = await dio.post<Map<String, Object?>>(
      '/auth/login',
      data: <String, Object?>{'username': 'a@b.com', 'password': 'pw'},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    expect(res.statusCode, 200);
    expect((res.data!['access_token']! as String).isNotEmpty, isTrue);
    expect(res.data!['token_type'], 'bearer');
  });

  test('POST /auth/login rejects empty credentials', () async {
    final res = await dio.post<Map<String, Object?>>(
      '/auth/login',
      data: <String, Object?>{'username': '', 'password': ''},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (int? s) => true,
      ),
    );
    expect(res.statusCode, 400);
  });

  test('POST /auth/register creates a user (201) for valid input', () async {
    final res = await dio.post<Map<String, Object?>>(
      '/auth/register',
      data: <String, Object?>{
        'email': 'new@oncare.com',
        'password': 'password123',
        'name': '홍길동',
      },
    );
    expect(res.statusCode, 201);
    expect(res.data!['email'], 'new@oncare.com');
    expect(res.data!['name'], '홍길동');
    expect((res.data!['id']! as String).isNotEmpty, isTrue);
  });

  test('POST /auth/register defaults name to the email local-part', () async {
    final res = await dio.post<Map<String, Object?>>(
      '/auth/register',
      data: <String, Object?>{
        'email': 'solo@oncare.com',
        'password': 'password123',
      },
    );
    expect(res.statusCode, 201);
    expect(res.data!['name'], 'solo');
  });

  test('POST /auth/register rejects empty credentials', () async {
    final res = await dio.post<Map<String, Object?>>(
      '/auth/register',
      data: <String, Object?>{'email': '', 'password': ''},
      options: Options(validateStatus: (int? s) => true),
    );
    expect(res.statusCode, 400);
  });
}
