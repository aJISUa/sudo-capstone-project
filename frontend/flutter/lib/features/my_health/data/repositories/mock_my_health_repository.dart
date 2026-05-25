import 'package:oncare/features/my_health/domain/entities/health_history.dart';
import 'package:oncare/features/my_health/domain/repositories/my_health_repository.dart';

class MockMyHealthRepository implements MyHealthRepository {
  const MockMyHealthRepository();

  @override
  Future<MyHealthState> fetchState() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const MyHealthState(
      profile: UserProfile(name: '김민수', email: 'minsu@oncare.com'),
      risk: RiskAlert(
        title: '고혈압·당뇨 위험 주의',
        body: '최근 혈압과 혈당 추세가 다소 높습니다. 식단·운동 관리에 신경 써주세요.',
        level: RiskLevel.medium,
      ),
      indicators: <IndicatorTrend>[
        IndicatorTrend(
          kind: IndicatorKind.weight,
          label: '체중',
          latestValue: '72.7',
          unit: 'kg',
          deltaText: '-2.3kg (2주 전 대비)',
          improving: true,
          last7Days: <double>[0.50, 0.47, 0.44, 0.42, 0.39, 0.36, 0.34],
          chartValues: <double>[
            75.0, 74.8, 74.9, 74.6, 74.4, 74.2, 74.0,
            73.8, 73.7, 73.4, 73.2, 73.3, 72.9, 72.7,
          ],
          recentRecords: <IndicatorRecord>[
            IndicatorRecord(label: '오늘', value: '72.7 kg'),
            IndicatorRecord(label: '1일 전', value: '72.9 kg'),
            IndicatorRecord(label: '2일 전', value: '73.3 kg'),
            IndicatorRecord(label: '3일 전', value: '73.2 kg'),
            IndicatorRecord(label: '4일 전', value: '73.4 kg'),
          ],
        ),
        IndicatorTrend(
          kind: IndicatorKind.bloodPressure,
          label: '혈압',
          latestValue: '124/79',
          unit: 'mmHg',
          deltaText: '-14mmHg (2주 전 대비)',
          improving: true,
          last7Days: <double>[0.54, 0.51, 0.53, 0.48, 0.45, 0.42, 0.40],
          chartValues: <double>[
            138, 136, 140, 135, 133, 137, 132,
            130, 134, 128, 127, 131, 126, 124,
          ],
          recentRecords: <IndicatorRecord>[
            IndicatorRecord(label: '오늘', value: '124/79 mmHg'),
            IndicatorRecord(label: '1일 전', value: '126/80 mmHg'),
            IndicatorRecord(label: '2일 전', value: '131/83 mmHg'),
            IndicatorRecord(label: '3일 전', value: '127/81 mmHg'),
            IndicatorRecord(label: '4일 전', value: '128/82 mmHg'),
          ],
        ),
        IndicatorTrend(
          kind: IndicatorKind.bloodSugar,
          label: '혈당',
          latestValue: '96',
          unit: 'mg/dL',
          deltaText: '-32mg/dL (2주 전 대비)',
          improving: true,
          last7Days: <double>[0.56, 0.53, 0.50, 0.52, 0.46, 0.41, 0.38],
          chartValues: <double>[
            128, 126, 130, 124, 121, 119, 117,
            115, 120, 112, 108, 114, 101, 96,
          ],
          recentRecords: <IndicatorRecord>[
            IndicatorRecord(label: '오늘', value: '96 mg/dL'),
            IndicatorRecord(label: '1일 전', value: '101 mg/dL'),
            IndicatorRecord(label: '2일 전', value: '114 mg/dL'),
            IndicatorRecord(label: '3일 전', value: '108 mg/dL'),
            IndicatorRecord(label: '4일 전', value: '112 mg/dL'),
          ],
        ),
      ],
      activityPoints: 1240,
      activityRank: 14,
      settings: <SettingsItem>[
        SettingsItem(
          label: '내 프로필',
          icon: '👤',
          kind: SettingsKind.myProfile,
        ),
        SettingsItem(
          label: '건강 목표',
          icon: '📊',
          kind: SettingsKind.healthGoal,
        ),
        SettingsItem(
          label: '알림 설정',
          icon: '🔔',
          kind: SettingsKind.notification,
        ),
        SettingsItem(
          label: '고객 지원',
          icon: '💬',
          kind: SettingsKind.support,
        ),
      ],
    );
  }
}
