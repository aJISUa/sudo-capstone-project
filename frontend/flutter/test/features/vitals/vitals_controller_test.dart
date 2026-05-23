import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/vitals/data/repositories/mock_vitals_repository.dart';
import 'package:oncare/features/vitals/domain/entities/vital.dart';
import 'package:oncare/features/vitals/presentation/controllers/vitals_controller.dart';

void main() {
  test('submit + latest round-trip through MockVitalsRepository', () async {
    final container = ProviderContainer(
      overrides: <Override>[
        // Default impl is DioVitalsRepository → needs dio + db
        // overrides; in-memory mock is enough for the unit test.
        vitalsRepositoryProvider.overrideWithValue(MockVitalsRepository()),
      ],
    );
    addTearDown(container.dispose);

    final repo = container.read(vitalsRepositoryProvider);
    final saved = await repo.submit(const WeightSubmission(kg: 70.1));
    expect(saved.kind, VitalKind.weight);
    expect(saved.value['kg'], 70.1);

    final latest = await container.read(
      latestVitalProvider(VitalKind.weight).future,
    );
    expect(latest, isNotNull);
    expect(latest!.value['kg'], 70.1);
  });

  test('latest filters by kind', () async {
    final container = ProviderContainer(
      overrides: <Override>[
        vitalsRepositoryProvider.overrideWithValue(MockVitalsRepository()),
      ],
    );
    addTearDown(container.dispose);

    final repo = container.read(vitalsRepositoryProvider);
    await repo.submit(const WeightSubmission(kg: 70.0));
    await repo.submit(
      const BloodPressureSubmission(systolic: 118, diastolic: 76),
    );

    final bp = await container.read(
      latestVitalProvider(VitalKind.bloodPressure).future,
    );
    expect(bp, isNotNull);
    expect(bp!.value['systolic'], 118);
    expect(bp.value['diastolic'], 76);

    final sugar = await container.read(
      latestVitalProvider(VitalKind.bloodSugar).future,
    );
    expect(sugar, isNull);
  });
}
