import 'package:oncare/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:oncare/features/dashboard/domain/repositories/dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  const MockDashboardRepository();

  @override
  Future<DashboardSummary> fetchSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const DashboardSummary(
      indicators: <HealthIndicator>[
        HealthIndicator(label: '칼로리', current: 1170, max: 2000, unit: 'kcal'),
        HealthIndicator(
          label: '나트륨',
          current: 2100,
          max: 2000,
          unit: 'mg',
          overBudget: true,
        ),
        HealthIndicator(label: '당류', current: 45, max: 50, unit: 'g'),
      ],
      dietEntries: 2,
      exerciseMinutes: 45,
      todaySchedule: <ScheduleItem>[
        ScheduleItem(time: '10:00', title: '병원 정기검진', emoji: '🏥'),
        ScheduleItem(time: '18:00', title: '헬스장 운동', emoji: '💪'),
      ],
      weekScore: 85,
      weekScoreDelta: 12,
      sodiumWarning: '오늘의 나트륨 섭취량이 높아요. 저녁에는 담백한 구이나 샐러드를 추천해요!',
      exerciseFeedback: '주간 운동 목표 80%를 달성했어요! 오늘 가볍게 걷기를 더해 100%를 채워봐요!',
    );
  }
}
