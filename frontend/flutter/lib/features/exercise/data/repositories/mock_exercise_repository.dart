import 'package:oncare/features/exercise/domain/entities/exercise_week.dart';
import 'package:oncare/features/exercise/domain/repositories/exercise_repository.dart';

class MockExerciseRepository implements ExerciseRepository {
  const MockExerciseRepository();

  @override
  Future<ExerciseWeek> fetchThisWeek() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const ExerciseWeek(
      dailyMinutes: <double>[30, 0, 45, 20, 60, 35, 50],
      dayLabels: <String>['월', '화', '수', '목', '금', '토', '일'],
      totalMinutes: 240,
      sessions: <ExerciseSession>[
        ExerciseSession(
          dayLabel: '월',
          type: ExerciseType.cardio,
          minutes: 30,
          calories: 250,
        ),
        ExerciseSession(
          dayLabel: '수',
          type: ExerciseType.strength,
          minutes: 45,
          calories: 320,
        ),
        ExerciseSession(
          dayLabel: '목',
          type: ExerciseType.yoga,
          minutes: 20,
          calories: 100,
        ),
        ExerciseSession(
          dayLabel: '금',
          type: ExerciseType.cardio,
          minutes: 60,
          calories: 480,
        ),
        ExerciseSession(
          dayLabel: '토',
          type: ExerciseType.walking,
          minutes: 35,
          calories: 180,
        ),
        ExerciseSession(
          dayLabel: '일',
          type: ExerciseType.strength,
          minutes: 50,
          calories: 360,
        ),
      ],
    );
  }
}
