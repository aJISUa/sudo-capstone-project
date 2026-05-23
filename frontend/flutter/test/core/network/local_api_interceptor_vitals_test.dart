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

  test('POST /vitals/weight persists and returns the new record', () async {
    final res = await dio.post<Map<String, Object?>>(
      '/vitals/weight',
      data: <String, Object?>{
        'kg': 70.3,
        'recorded_at': '2026-05-20T08:00:00.000Z',
      },
    );
    expect(res.statusCode, 200);
    expect(res.data?['kind'], 'weight');
    final value = res.data?['value']! as Map<Object?, Object?>;
    expect(value['kg'], 70.3);
    expect(res.data?['recorded_at'], '2026-05-20T08:00:00.000Z');

    // Round-trip through GET /vitals/weight/latest.
    final latest = await dio.get<Map<String, Object?>>('/vitals/weight/latest');
    expect(latest.statusCode, 200);
    final latestValue = latest.data?['value']! as Map<Object?, Object?>;
    expect(latestValue['kg'], 70.3);
  });

  test('POST /vitals/blood-pressure persists systolic + diastolic', () async {
    final res = await dio.post<Map<String, Object?>>(
      '/vitals/blood-pressure',
      data: <String, Object?>{'systolic': 118, 'diastolic': 76},
    );
    expect(res.statusCode, 200);
    final value = res.data?['value']! as Map<Object?, Object?>;
    expect(value['systolic'], 118);
    expect(value['diastolic'], 76);
  });

  test('GET /vitals/blood-sugar/latest returns empty body when none', () async {
    final res = await dio.get<Map<String, Object?>>(
      '/vitals/blood-sugar/latest',
    );
    expect(res.statusCode, 200);
    expect(res.data, isEmpty);
  });
}
