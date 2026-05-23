import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/place/data/repositories/mock_place_repository.dart';
import 'package:oncare/features/place/domain/entities/place.dart';
import 'package:oncare/features/place/presentation/controllers/place_controller.dart';

void main() {
  test(
    'nearbyPlacesProvider returns mock places with all categories',
    () async {
      final container = ProviderContainer(
        overrides: <Override>[
          // Default repo is DioPlaceRepository (Stage 9.9); use the
          // in-memory mock for the unit test.
          placeRepositoryProvider.overrideWithValue(
            const MockPlaceRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final places = await container.read(nearbyPlacesProvider.future);
      expect(places, isNotEmpty);
      final cats = places.map((Place p) => p.category).toSet();
      expect(cats, contains(PlaceCategory.medical));
      expect(cats, contains(PlaceCategory.fitness));
      expect(cats, contains(PlaceCategory.healthyFood));
      expect(cats, contains(PlaceCategory.pharmacy));
    },
  );
}
