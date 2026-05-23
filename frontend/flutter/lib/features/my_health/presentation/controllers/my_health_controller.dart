import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/network/dio_client.dart';
import 'package:oncare/features/my_health/data/repositories/dio_my_health_repository.dart';
import 'package:oncare/features/my_health/domain/entities/health_history.dart';
import 'package:oncare/features/my_health/domain/repositories/my_health_repository.dart';

final myHealthRepositoryProvider = Provider<MyHealthRepository>(
  (ref) => DioMyHealthRepository(ref.watch(dioProvider)),
  name: 'myHealthRepository',
);

final myHealthStateProvider = FutureProvider<MyHealthState>((ref) {
  return ref.watch(myHealthRepositoryProvider).fetchState();
}, name: 'myHealthState');
