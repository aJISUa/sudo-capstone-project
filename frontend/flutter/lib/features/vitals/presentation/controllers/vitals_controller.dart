import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/network/dio_client.dart';
import 'package:oncare/features/vitals/data/repositories/dio_vitals_repository.dart';
import 'package:oncare/features/vitals/domain/entities/vital.dart';
import 'package:oncare/features/vitals/domain/repositories/vitals_repository.dart';

/// Production wiring: dio → LocalApiInterceptor (dev) / FastAPI (prod).
/// Tests override this with a [MockVitalsRepository].
final vitalsRepositoryProvider = Provider<VitalsRepository>(
  (ref) => DioVitalsRepository(ref.watch(dioProvider)),
  name: 'vitalsRepository',
);

/// Latest reading for a given [VitalKind]. Auto-disposes so the cache
/// drops when no widget is listening — important after the user
/// submits a new value via [vitalsRepositoryProvider], which calls
/// `ref.invalidate` on this family.
final latestVitalProvider = FutureProvider.autoDispose
    .family<VitalRecord?, VitalKind>(
      (ref, kind) => ref.watch(vitalsRepositoryProvider).latest(kind),
      name: 'latestVital',
    );
