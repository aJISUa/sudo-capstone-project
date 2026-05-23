import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/features/diet/data/repositories/mock_diet_repository.dart';
import 'package:oncare/features/diet/domain/entities/diet_day.dart';
import 'package:oncare/features/diet/domain/repositories/diet_repository.dart';

final dietRepositoryProvider = Provider<DietRepository>(
  (ref) => const MockDietRepository(),
  name: 'dietRepository',
);

final dietTodayProvider = FutureProvider<DietDay>((ref) {
  return ref.watch(dietRepositoryProvider).fetchToday();
}, name: 'dietToday');
