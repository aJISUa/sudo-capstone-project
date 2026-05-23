# Changelog

All notable changes to this project will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
