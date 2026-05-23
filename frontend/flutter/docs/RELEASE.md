# Release Notes & Manual Build Guides

이 문서는 Web 자동 배포(Stage 1.7) 외에 **수동으로 처리해야 하는**
Android / iOS 릴리즈 절차와 버전 관리 정책을 정리합니다.

> CI 자동화 범위 (Q12 결정): **Web만 자동**. Android/iOS는 수동.

---

## 1. Web — GitHub Pages

이미 [`.github/workflows/deploy-web.yml`](../.github/workflows/deploy-web.yml)
이 자동 배포 중이며, `main` 푸시 시점에 갱신됩니다.

- **라이브 URL**: <https://barmi.github.io/oncare-flutter/>
- **base-href**: `/oncare-flutter/`
- **URL 전략**: Hash (`#/...`) — GitHub Pages 404 fallback 불필요 (Q10)
- **env**: `--dart-define=ENV=prod`, `--dart-define=API_BASE_URL=$API_BASE_URL`
  (Variables에 `API_BASE_URL`이 없으면 dev URL fallback)

수동 빌드(로컬에서 확인 시):

```bash
flutter build web --release \
  --base-href "/oncare-flutter/" \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://api.oncare.example.com
# 출력: build/web/
```

---

## 2. Android — `.aab` (Play Store), `.apk` (사이드로드)

### 2.1 키스토어 준비 (1회)

```bash
keytool -genkey -v -keystore ~/keys/oncare-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias oncare
```

`android/key.properties` 생성(파일은 `.gitignore`에 이미 포함):

```
storeFile=/Users/<you>/keys/oncare-upload.jks
storePassword=<...>
keyAlias=oncare
keyPassword=<...>
```

`android/app/build.gradle.kts` 의 `signingConfigs.release` 에서
`key.properties` 를 읽도록 표준 패턴으로 연결합니다(Flutter 가이드 참고).

### 2.2 빌드

```bash
# Play Store 업로드용 AAB
flutter build appbundle --release \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://api.oncare.example.com
# 출력: build/app/outputs/bundle/release/app-release.aab

# 사이드로드용 APK
flutter build apk --release \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://api.oncare.example.com
# 출력: build/app/outputs/flutter-apk/app-release.apk
```

### 2.3 사전 점검

- [ ] `applicationId` = `com.barmi.oncare` (Stage 1.1에서 설정됨)
- [ ] 권한 — 현재는 마이크/카메라 등 추가 권한 없음. 새 기능 추가 시 `AndroidManifest.xml` 갱신.
- [ ] 소셜 SDK 통합 시 `AndroidManifest.xml` placeholder
  (`KAKAO_NATIVE_KEY`, `NAVER_CLIENT_ID`)와 `--dart-define` 동기화.

---

## 3. iOS — TestFlight / App Store

### 3.1 설정 (1회)

1. Apple Developer 계정 / Bundle ID `com.barmi.oncare` 생성.
2. App Store Connect 앱 등록.
3. Xcode → Runner → Signing & Capabilities → Team + Provisioning Profile.

### 3.2 빌드

```bash
flutter build ios --release \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://api.oncare.example.com

# 이후 Xcode 에서:
#   Product → Archive → Distribute App → App Store Connect (TestFlight)
```

### 3.3 사전 점검

- [ ] `Info.plist` Bundle ID / Display Name 확인.
- [ ] 소셜 SDK 추가 시 `Info.plist`에 URL Scheme / `LSApplicationQueriesSchemes` 등 추가.
- [ ] Apple Sign-In 사용 시 Capabilities → Sign In with Apple 활성화.

---

## 4. 버전 정책 (SemVer)

- `pubspec.yaml` `version: X.Y.Z+N` 형식.
  - `X.Y.Z` = 마케팅 버전 (앱 스토어 표시).
  - `N` = 빌드 번호 (Android `versionCode`, iOS `CFBundleVersion`).
- 메이저 (`X`): 호환되지 않는 변경 (API 큰 변동).
- 마이너 (`Y`): 신규 피처.
- 패치 (`Z`): 버그 수정.

릴리즈 태그: `vX.Y.Z+N` (예: `v0.1.0+1`).

```bash
git tag v0.1.0+1
git push origin v0.1.0+1
```

---

## 5. 릴리즈 절차 요약

1. 변경분이 `main`에 모두 머지됐는지 확인 (`git status`, `git log`).
2. `pubspec.yaml`의 `version`을 갱신.
3. [`CHANGELOG.md`](../CHANGELOG.md) 새 섹션 작성.
4. 릴리즈 PR 또는 직접 commit (`chore(release): v0.1.0`).
5. 태그 push.
6. Web은 자동 배포되며 라이브 URL 확인.
7. Android `.aab` 빌드 → Play Console 업로드.
8. iOS Archive → Distribute → TestFlight.
