// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Oncare';

  @override
  String get navDashboard => '대시보드';

  @override
  String get navDiet => '식단';

  @override
  String get navExercise => '운동';

  @override
  String get navMyHealth => '내 건강';

  @override
  String get pageDashboardTitle => '대시보드';

  @override
  String get pageDietTitle => '식단 기록';

  @override
  String get pageExerciseTitle => '운동';

  @override
  String get pageMyHealthTitle => '내 건강';

  @override
  String get pageAiCoachTitle => 'AI 코치';

  @override
  String get pageNotificationTitle => '알림';

  @override
  String get pagePlaceTitle => '장소';

  @override
  String get pageSignInTitle => '로그인';

  @override
  String get actionOpenAiCoach => 'AI 코치 열기';

  @override
  String get actionFindPlace => '장소 찾기';

  @override
  String get actionSignInPlaceholder => '로그인 (placeholder)';

  @override
  String get actionRetry => '다시 시도';

  @override
  String get placeholderDashboard => '대시보드 (placeholder)';

  @override
  String get placeholderDiet => '식단 기록 (placeholder)';

  @override
  String get placeholderExercise => '운동 (placeholder)';

  @override
  String get placeholderMyHealth => '내 건강 (placeholder)';

  @override
  String get placeholderAiCoach => 'AI 코치 (placeholder, mock 응답)';

  @override
  String get placeholderNotification => '알림 (placeholder)';

  @override
  String get placeholderPlace => '장소 (placeholder, Stage 4에서 Google Maps)';

  @override
  String get placeholderSignIn => '로그인 (placeholder, Stage 4에서 소셜 SDK)';

  @override
  String get errorNetwork => '네트워크 문제';

  @override
  String get errorUnauthorized => '로그인이 필요합니다';

  @override
  String get errorNotFound => '찾을 수 없습니다';

  @override
  String get errorServer => '서버 오류';

  @override
  String get errorCancelled => '취소됨';

  @override
  String get errorUnknown => '알 수 없는 오류';

  @override
  String get dashboardSectionToday => '오늘의 요약';

  @override
  String get dashboardMetricCalories => '칼로리';

  @override
  String get dashboardMetricExercise => '운동';

  @override
  String get dashboardMetricWeight => '체중';

  @override
  String get dashboardChartWeightWeek => '주간 체중';

  @override
  String dashboardCaloriesProgress(int pct, int goal) {
    return '$pct% / $goal';
  }

  @override
  String dashboardWeightDelta(String sign, String delta) {
    return '$sign$delta (지난주 대비)';
  }

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitMinutes => '분';

  @override
  String get unitKg => 'kg';
}
