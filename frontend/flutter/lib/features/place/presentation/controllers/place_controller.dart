import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/network/dio_client.dart';
import 'package:oncare/features/place/data/repositories/dio_place_repository.dart';
import 'package:oncare/features/place/domain/entities/place.dart';
import 'package:oncare/features/place/domain/repositories/place_repository.dart';

final placeRepositoryProvider = Provider<PlaceRepository>(
  (ref) => DioPlaceRepository(ref.watch(dioProvider)),
  name: 'placeRepository',
);

final nearbyPlacesProvider = FutureProvider<List<Place>>((ref) {
  return ref.watch(placeRepositoryProvider).nearbyPlaces();
}, name: 'nearbyPlaces');
