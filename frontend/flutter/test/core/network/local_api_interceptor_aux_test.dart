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

  test('GET /ai-coach/feedback returns greeting + 4 suggestions', () async {
    final res = await dio.get<Map<String, Object?>>('/ai-coach/feedback');
    expect(res.statusCode, 200);
    expect(res.data!['greeting'], isNotEmpty);
    final suggestions = (res.data!['suggestions']! as List<Object?>)
        .cast<Map<String, Object?>>();
    expect(suggestions.length, 4);
    final tags = suggestions.map((s) => s['tag']! as String).toSet();
    expect(
      tags,
      containsAll(<String>['diet', 'exercise', 'sleep', 'hydration']),
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
}
