# Changelog

All notable changes to this project will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0+2] — 2026-05-20

UX Alignment with the React original (Stage 8). The app now matches
the look-and-feel of `oncare-prototype.vercel.app`.

### Changed
- **Tokens**: AppColors switched to the shadcn theme values exported
  from `src/styles/theme.css` (primary #3EAFDF, secondary #277DA1,
  warning #F97316, muted/accent blue tints, foreground #262626, etc.).
  Domain accents (domainDiet/exercise/health/aiCoach) removed.
- **Radii**: base `md` aligned to 10 (shadcn `--radius`); new `card`
  token = 20 for tailwind `rounded-2xl`.
- **Shell**: BottomNav rebuilt as a 64dp custom bar with labels 홈 /
  식단 / 운동 / My (was Dashboard / Diet / Exercise / My Health).
- **Header**: new `OncareHeader` (title + bell + calendar + unread dot)
  replaces AppBar across Dashboard/Diet/Exercise/MyHealth.
- **Dashboard**: 5-card stack — 인사말 / 그라데이션 quick-input
  (체중·혈압·혈당) / 오늘의 건강 요약 (warning + 4 progress bars +
  quick stats) / 오늘의 일정 / 이번 주 건강 점수 (green gradient).
  DashboardSummary model rewritten around `HealthIndicator`,
  `ScheduleItem`.
- **Diet**: 영양 요약 카드 (총 kcal / 나트륨 / 당류) + AiCoachCard +
  meal cards with sodium/sugar pill tags.
- **Exercise**: 4 stat tiles (운동 횟수/총 시간/소모 칼로리/연속 일수)
  + 주간 bar chart + AiCoachCard + history list.
- **MyHealth**: ProfileCard with gradient avatar ring + orange/red
  risk gradient card + 3 IndicatorTile rows with inline sparkline +
  활동 포인트 카드 (primary→secondary gradient) + 설정 메뉴.

### Added
- **Modals**: `shared/widgets/modals/` — `schedule_calendar_sheet.dart`
  (bottom sheet with month grid + coloured event chips +
  「일정 추가」), `quick_input_dialog.dart` (체중/혈압/혈당 입력 폼),
  `add_event_dialog.dart` (제목/날짜/시간/카테고리), and
  `right_slide_panel.dart` helper.
- **Panels**: `notification_panel.dart` (right-slide overlay with
  "안 읽음만 보기" Switch and 「모두 읽음」) and `ai_coach_panel.dart`
  ("온이의 피드백" right-slide overlay). Both backed by the existing
  controllers.
- Dashboard wiring: bell → notification panel, calendar icon and
  schedule rows → calendar sheet, quick-input buttons → input
  dialogs, new FAB → AI coach panel.

## [0.1.0+1] — 2026-05-20

Initial milestone: Flutter reconstruction of the Oncare prototype
covering Stages 0–7 (Discovery → Bootstrap → Core → Design System →
Features MVP → Polish → Quality → Release scaffolding).

### Added
- **Stage 0** Discovery — PLAN, STRUCTURE, DESIGN_TOKENS,
  CONTRIBUTING_NOTES; Q1–Q12 decisions locked.
- **Stage 1** Bootstrap — `flutter create`, lib/ skeleton, core
  dependencies, strict analyzer, AppConfig + dart-define,
  GitHub Actions CI (format/analyze/test) + CD (web →
  github.io/oncare-flutter).
- **Stage 2** Core infra — go_router with StatefulShellRoute +
  BottomNav, Riverpod ProviderObserver, design tokens + Material
  theme, Dio + interceptors (mock/auth-stub/logging), drift +
  secure_storage + prefs, AppError/Result + ErrorView/EmptyState,
  ko/en ARB.
- **Stage 3** Design system — color/typo/spacing/radius/breakpoints
  tokens, AppButton/Card/Input/Badge/Avatar atoms,
  MetricCard/ChartCard/SectionHeader molecules, ResponsiveBuilder,
  fl_chart wrappers (Line/Bar/Donut), `/dev/ui-catalog` page.
- **Stage 4** Feature MVPs (all mock data) — Dashboard, Diet Record,
  Exercise, My Health, AI Coach, Notification panel (+ simulated
  push), Place (Maps placeholder), Auth (4-provider mock — Apple /
  Google / Kakao / Naver).
- **Stage 5** Integration & polish — NavLoggerObserver, dashboard
  staggered animations, MetricCard Semantics labels, dashboard
  responsive wide layout, dashboard copy via AppLocalizations.
- **Stage 6** Quality — model invariant tests, page-level widget
  tests for Dashboard data/error paths, golden infra
  (`dart_test.yaml` tag + CI exclusion), integration smoke
  (`integration_test/app_smoke_test.dart`).
- **Stage 7** Release — `docs/RELEASE.md` (web/android/ios manual
  guides + SemVer policy), this CHANGELOG, README final touch.

### Notes
- `retrofit` + `retrofit_generator` temporarily removed (Stage 2.4
  comment); reintroduced once their versions are compatible.
- Real Google Maps Flutter integration deferred until API keys
  are configured (Stage 4.7 placeholder).
- Real social sign-in SDKs deferred until SDK keys are configured
  (Stage 4.8 mock).
