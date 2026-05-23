import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/my_health/data/repositories/mock_my_health_repository.dart';
import 'package:oncare/features/my_health/domain/entities/health_history.dart';
import 'package:oncare/features/my_health/presentation/controllers/my_health_controller.dart';

void main() {
  test('myHealthStateProvider returns full state with 3 indicators', () async {
    final container = ProviderContainer(
      overrides: <Override>[
        // Default repo is DioMyHealthRepository (Stage 9.9); use the
        // in-memory mock for the unit test.
        myHealthRepositoryProvider.overrideWithValue(
          const MockMyHealthRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final state = await container.read(myHealthStateProvider.future);
    expect(state.profile.name, '김민수');
    expect(state.profile.email, 'minsu@oncare.com');
    expect(state.risk.level, RiskLevel.medium);
    expect(state.indicators.length, 3);
    expect(state.indicators.map((IndicatorTrend t) => t.kind), <IndicatorKind>[
      IndicatorKind.weight,
      IndicatorKind.bloodPressure,
      IndicatorKind.bloodSugar,
    ]);
    expect(state.activityPoints, 1240);
    expect(state.settings.length, 4);
  });
}
