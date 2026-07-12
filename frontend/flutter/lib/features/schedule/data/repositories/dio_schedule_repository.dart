import 'package:dio/dio.dart';

import 'package:oncare/features/schedule/domain/entities/schedule_event.dart';
import 'package:oncare/features/schedule/domain/repositories/schedule_repository.dart';

/// Network-side [ScheduleRepository]. dev/local builds get served by
/// `LocalApiInterceptor`; prod hits FastAPI's `GET /schedule/events`.
class DioScheduleRepository implements ScheduleRepository {
  DioScheduleRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<ScheduleEvent>> fetchByDate(String date) async {
    final res = await _dio.get<List<Object?>>(
      '/schedule/events',
      queryParameters: <String, Object?>{'date': date},
    );
    final rows = res.data ?? const <Object?>[];
    return rows
        .cast<Map<String, Object?>>()
        .map(ScheduleEvent.fromJson)
        .toList();
  }

  @override
  Future<List<ScheduleEvent>> fetchByMonth(String month) async {
    final res = await _dio.get<List<Object?>>(
      '/schedule/events',
      queryParameters: <String, Object?>{'month': month},
    );
    final rows = res.data ?? const <Object?>[];
    return rows
        .cast<Map<String, Object?>>()
        .map(ScheduleEvent.fromJson)
        .toList();
  }

  @override
  Future<ScheduleEvent> createEvent({
    required String date,
    required String title,
    String time = '',
    ScheduleCategory category = ScheduleCategory.other,
  }) async {
    final res = await _dio.post<Map<String, Object?>>(
      '/schedule/events',
      data: <String, Object?>{
        'date': date,
        'time': time,
        'title': title,
        'category': category.name,
      },
    );
    return ScheduleEvent.fromJson(res.data!);
  }
}
