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

  test('POST /diet/analyze returns an analysis and persists an entry', () async {
    final form = FormData.fromMap(<String, Object?>{
      'image': MultipartFile.fromBytes(<int>[1, 2, 3, 4], filename: 'meal.jpg'),
      'meal_type': 'dinner',
    });
    final res = await dio.post<Map<String, Object?>>('/diet/analyze', data: form);
    expect(res.statusCode, 200);
    expect(res.data!['entry_id'], isNotNull);

    final analysis = res.data!['analysis']! as Map<String, Object?>;
    final foods = (analysis['foods']! as List<Object?>).cast<Map<String, Object?>>();
    expect(foods, isNotEmpty);
    expect(foods.first['name'], isNotNull);
    expect(analysis['total_calories'], greaterThan(0));

    // 저장돼서 오늘 식단 집계에 반영된다.
    final today = await dio.get<Map<String, Object?>>('/diet/days/today');
    expect(today.statusCode, 200);
    expect(today.data!['total_calories'], greaterThan(0));
    final entries = (today.data!['entries']! as List<Object?>);
    expect(entries, isNotEmpty);
  });
}
