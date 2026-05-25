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
          latestValue: '72',
          unit: 'kg',
          deltaText: '-10kg (2주 전 대비)',
          improving: true,
          last7Days: <double>[0.62, 0.58, 0.52, 0.45, 0.36, 0.28, 0.20],
          chartValues: <double>[
            82, 80, 79, 78, 78, 77, 77, 76, 75, 75, 74, 73, 73, 72,
          ],
          recentRecords: <IndicatorRecord>[
            IndicatorRecord(label: '오늘', value: '72 kg'),
            IndicatorRecord(label: '1일 전', value: '72 kg'),
            IndicatorRecord(label: '2일 전', value: '73 kg'),
            IndicatorRecord(label: '3일 전', value: '73 kg'),
            IndicatorRecord(label: '4일 전', value: '74 kg'),
          ],
        ),
        IndicatorTrend(
          kind: IndicatorKind.bloodPressure,
          label: '혈압',
          latestValue: '124',
          unit: 'mmHg',
          deltaText: '-21mmHg (2주 전 대비)',
          improving: true,
          last7Days: <double>[0.80, 0.74, 0.66, 0.55, 0.42, 0.28, 0.16],
          chartValues: <double>[
            145, 144, 142, 140, 140, 138, 136, 134, 132, 130, 129, 127, 126, 124,
          ],
          recentRecords: <IndicatorRecord>[
            IndicatorRecord(label: '오늘', value: '124 mmHg'),
            IndicatorRecord(label: '1일 전', value: '125 mmHg'),
            IndicatorRecord(label: '2일 전', value: '126 mmHg'),
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
          last7Days: <double>[0.78, 0.70, 0.60, 0.50, 0.40, 0.30, 0.18],
          chartValues: <double>[
            128, 124, 120, 118, 116, 113, 110, 108, 106, 104, 102, 100, 98, 96,
          ],
          recentRecords: <IndicatorRecord>[
            IndicatorRecord(label: '오늘', value: '96 mg/dL'),
            IndicatorRecord(label: '1일 전', value: '98 mg/dL'),
            IndicatorRecord(label: '2일 전', value: '99 mg/dL'),
            IndicatorRecord(label: '3일 전', value: '100 mg/dL'),
            IndicatorRecord(label: '4일 전', value: '102 mg/dL'),
          ],
        ),
      ],
      activityPoints: 1240,
      activityRank: 14,
      settings: <SettingsItem>[
        SettingsItem(
          label: '개인 정보',
          icon: '👤',
          kind: SettingsKind.personalInfo,
        ),
        SettingsItem(
          label: '건강 데이터',
          icon: '📊',
          kind: SettingsKind.healthData,
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
