import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/network/dio_client.dart';
import 'package:oncare/features/exercise/data/repositories/dio_exercise_repository.dart';
import 'package:oncare/features/exercise/data/repositories/mock_gym_repository.dart';
import 'package:oncare/features/exercise/domain/entities/exercise_week.dart';
import 'package:oncare/features/exercise/domain/entities/gym.dart';
import 'package:oncare/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:oncare/features/exercise/domain/repositories/gym_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => DioExerciseRepository(ref.watch(dioProvider)),
  name: 'exerciseRepository',
);

final exerciseWeekProvider = FutureProvider<ExerciseWeek>((ref) {
  return ref.watch(exerciseRepositoryProvider).fetchThisWeek();
}, name: 'exerciseWeek');

/// Gym data has no backend endpoint yet — the prototype shipped only
/// mock data, so wire the page to a static repository for now. A real
/// `DioGymRepository` can be swapped in once `/gyms/*` lands.
final gymRepositoryProvider = Provider<GymRepository>(
  (ref) => const MockGymRepository(),
  name: 'gymRepository',
);

final myGymProvider = FutureProvider<Gym?>((ref) {
  return ref.watch(gymRepositoryProvider).fetchMyGym();
}, name: 'myGym');

final nearbyGymsProvider = FutureProvider<List<Gym>>((ref) {
  return ref.watch(gymRepositoryProvider).fetchNearby();
}, name: 'nearbyGyms');
