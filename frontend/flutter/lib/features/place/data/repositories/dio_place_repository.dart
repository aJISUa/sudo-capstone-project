import 'package:dio/dio.dart';

import 'package:oncare/features/place/domain/entities/place.dart';
import 'package:oncare/features/place/domain/repositories/place_repository.dart';

class DioPlaceRepository implements PlaceRepository {
  DioPlaceRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Place>> nearbyPlaces() async {
    final res = await _dio.get<List<Object?>>('/places/nearby');
    final rows = res.data ?? const <Object?>[];
    return rows.cast<Map<String, Object?>>().map(Place.fromJson).toList();
  }
}
