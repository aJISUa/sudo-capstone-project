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
          kind: IndicatorKind.bloodPressure,
          label: '혈압',
          latestValue: '124',
          unit: 'mmHg',
          deltaText: '-14mmHg (2주 전 대비)',
          improving: true,
          last7Days: <double>[0.46, 0.40, 0.36, 0.43, 0.31, 0.26, 0.22],
          chartValues: <double>[
            138, 136, 140, 135, 133, 137, 132,
            130, 134, 128, 127, 131, 126, 124,
          ],
          recentRecords: <IndicatorRecord>[
            IndicatorRecord(label: '오늘', value: '124 mmHg'),
            IndicatorRecord(label: '1일 전', value: '126 mmHg'),
            IndicatorRecord(label: '2일 전', value: '131 mmHg'),
            IndicatorRecord(label: '3일 전', value: '127 mmHg'),
            IndicatorRecord(label: '4일 전', value: '128 mmHg'),
          ],
        ),
        IndicatorTrend(
          kind: IndicatorKind.bloodPressure,
          label: '혈압',
          latestValue: '124',
          unit: 'mmHg',
          deltaText: '-14mmHg (2주 전 대비)',
          improving: true,
          last7Days: <double>[0.46, 0.40, 0.36, 0.43, 0.31, 0.26, 0.22],
          chartValues: <double>[
            138, 136, 140, 135, 133, 137, 132,
            130, 134, 128, 127, 131, 126, 124,
          ],
          recentRecords: <IndicatorRecord>[
            IndicatorRecord(label: '오늘', value: '124 mmHg'),
            IndicatorRecord(label: '1일 전', value: '126 mmHg'),
            IndicatorRecord(label: '2일 전', value: '131 mmHg'),
            IndicatorRecord(label: '3일 전', value: '127 mmHg'),
            IndicatorRecord(label: '4일 전', value: '128 mmHg'),
          ],
        ),
        IndicatorTrend(
          kind: IndicatorKind.bloodSugar,
          label: '혈당',
          latestValue: '96',
          unit: 'mg/dL',
          deltaText: '-32mg/dL (2주 전 대비)',
          improving: true,
          last7Days: <double>[0.50, 0.44, 0.38, 0.55, 0.32, 0.27, 0.20],
          chartValues: <double>[
            128, 125, 132, 123, 120, 126, 118,
            115, 122, 110, 106, 116, 101, 96,
          ],
          recentRecords: <IndicatorRecord>[
            IndicatorRecord(label: '오늘', value: '96 mg/dL'),
            IndicatorRecord(label: '1일 전', value: '101 mg/dL'),
            IndicatorRecord(label: '2일 전', value: '116 mg/dL'),
            IndicatorRecord(label: '3일 전', value: '106 mg/dL'),
            IndicatorRecord(label: '4일 전', value: '110 mg/dL'),
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
