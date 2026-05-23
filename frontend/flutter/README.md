# oncare-flutter

[Oncare Prototype (React/TS)](https://github.com/subin21cc/Oncareprototype) 를 Flutter로 재구성하는 프로젝트입니다.
**Android / iOS / Web** 3개 타깃을 단일 코드베이스로 빌드하며, 웹은 GitHub Pages에 CI 배포됩니다.

> 현재 상태: **모든 Stage 0–7 완료** — v0.1.0+1 (mock-data MVP)

## 문서

- [docs/PLAN.md](./docs/PLAN.md) — 전체 로드맵 (Stage × Phase), 기술 스택, [결정 이력](./docs/PLAN.md#9-결정-이력-decision-log)
- [docs/STRUCTURE.md](./docs/STRUCTURE.md) — Flutter 디렉토리 구조 및 아키텍처 의존성 규칙
- [docs/DESIGN_TOKENS.md](./docs/DESIGN_TOKENS.md) — 디자인 토큰 초안 (Figma 접근 후 보강)
- [docs/CONTRIBUTING_NOTES.md](./docs/CONTRIBUTING_NOTES.md) — 커밋 컨벤션, AI co-author trailer 미사용 정책, Phase/Stage 커밋·푸시 케이던스
- [docs/RELEASE.md](./docs/RELEASE.md) — Web/Android/iOS 수동 릴리즈 절차, SemVer 정책
- [CHANGELOG.md](./CHANGELOG.md) — 버전별 변경 이력

## 빌드 / 실행

```bash
# 의존성
flutter pub get

# Web (개발)
flutter run -d chrome \
  --dart-define=ENV=dev \
  --dart-define=API_BASE_URL=https://dev.api.oncare.example.com

# Web (배포 빌드, GitHub Pages용)
flutter build web --release \
  --base-href "/oncare-flutter/" \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://api.oncare.example.com

# Android
flutter run -d <android-device>  # debug
flutter build apk --release      # 또는 build appbundle

# iOS
flutter run -d <ios-device>      # debug
flutter build ios --release      # Xcode에서 archive
```

## CI / CD

`.github/workflows/`:

- **`ci.yml`** — `push`(main) / `pull_request`에서 `dart format` + `flutter analyze` + `flutter test` 실행
- **`deploy-web.yml`** — `push`(main) 시 `flutter build web` 후 GitHub Pages에 자동 배포 → `https://barmi.github.io/oncare-flutter/`

### 최초 1회 설정

워크플로우의 `actions/configure-pages@v5`에 `enablement: true`를 줘서 첫 실행 시 Pages site를 자동 provision 합니다.
권한 정책으로 자동 활성화가 막힐 경우(organization 레포 등) **수동으로 한 번만** 활성화하세요:

1. 레포 → **Settings → Pages**
2. **Source**: `GitHub Actions` 로 변경
3. Actions 탭에서 실패한 `Deploy Web (GitHub Pages)` 워크플로우를 **Re-run**

(선택) **Settings → Secrets and variables → Actions → Variables** 에 `API_BASE_URL` 등록 — 미설정 시 dev 기본값 사용

## Stage 진행 현황

- [x] **Stage 0 — Discovery & Decision** (PLAN, STRUCTURE, DESIGN_TOKENS, 결정 Q1–Q12)
- [x] **Stage 1 — Bootstrap** (flutter create, deps, lint, AppConfig, CI/CD)
- [x] **Stage 2 — Core Infrastructure** (router, theme, dio, drift, errors, l10n)
- [x] **Stage 3 — Design System** (tokens / atoms / molecules / charts / responsive / UI 카탈로그)
- [x] **Stage 4 — Features MVP** (Dashboard / Diet / Exercise / MyHealth / AICoach / Notification / Place / Auth — 모두 mock 데이터)
- [x] **Stage 5 — Integration & Polish** (nav logger, dashboard animation, MetricCard a11y, dashboard responsive layout, dashboard i18n)
- [x] **Stage 6 — Quality** (model/widget tests, golden infra w/ tag, integration smoke)
- [x] **Stage 7 — Release** (RELEASE.md guides, CHANGELOG v0.1.0+1, web Pages live)
