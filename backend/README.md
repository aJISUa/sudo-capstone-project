# On-Care Backend (프론트 기준 재작업판)

> 프론트엔드(Flutter)의 `LocalApiInterceptor` 를 **정답 **으로 삼아 백엔드를 맞춥니다.
> 계약 전체는 `API_CONTRACT.md` 참조.

## 재작업 로드맵
- **STEP 0** ✅ API 계약 명세 (API_CONTRACT.md)
- **STEP 1** ✅ 골격 재구성: /v1 prefix · 문자열 id · snake_case · 시스템 엔드포인트 · DB/Docker
- **STEP 2** ✅ 사용자/인증: /users/me, /users/me/health (토큰→유저 / 무토큰→데모 폴백)
- **STEP 3** ✅ 식단: /diet/days/today + POST /diet/analyze (Gemini, DASH/나트륨·당류 관점, 엔진 교체 가능)
- **STEP 4** ✅ 운동: /exercise/weeks/current + POST /exercise/sessions (요일별/타입별 집계, streak, 주간 코칭)
- **STEP 5** ✅ 바이탈: /vitals/{weight|blood-pressure|blood-sugar} + /vitals/{kind}/latest (→ /users/me/health indicators 자동 연결)
- **STEP 6** ✅ 일정/알림/장소/AI코치: /schedule/events · /notifications · /places/nearby · /ai-coach/feedback (도메인별 코치 분리, RAG 진입점)
- **STEP 7** ✅ RAG 코치: 임베더/LLM factory(교체 가능), 개인·공공 문서 격리, 도메인 필터, 청킹(설정값), 토큰 기록, 규칙 기반 폴백, 적재/재임베딩 스크립트

## STEP 1 에서 동작하는 것
- `GET /v1/ping` · `GET /v1/healthz` · `GET /v1/version` — 프론트 계약과 정확히 일치
- 9개 테이블 생성 (프론트 drift 스키마 정렬: diet_entries 에 sodium_mg/sugar_g 포함)
- 사용자 id = 문자열, 데모 유저 'user-demo'(김민수) 시드

## 실행
```bash
cp .env.example .env          # JWT_SECRET 교체
docker compose up --build
```
→ http://localhost:8000/docs  (경로는 모두 /v1/...)

## DB 마이그레이션 (Alembic)
스키마는 **Alembic 마이그레이션**으로 관리합니다(베이스라인: `migrations/versions/0001_baseline.py`, 9테이블 + pgvector).
DB URL 은 `.env` 의 `DATABASE_URL` 을 그대로 사용합니다(`migrations/env.py` 가 app 설정에서 읽음).

```bash
cd backend
alembic upgrade head          # 최신 스키마로 반영 (운영/CI 는 이 명령으로 스키마 생성)
alembic revision --autogenerate -m "설명"   # 모델 변경 후 새 마이그레이션 생성
alembic downgrade -1          # 한 단계 롤백
```
> 개발 편의를 위해 앱 기동 시 `create_all()` 로도 테이블을 만들지만(멱등), **운영은 `alembic upgrade head`** 를 정답으로 삼습니다.
> (운영에서 `create_all` 을 끄려면 `AUTO_CREATE_TABLES=false` — 설정 항목은 이후 커밋에서 추가)

## 프론트 연동 (실서버 전환)
프론트에서:
```bash
flutter run --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://localhost:8000/v1
```
(LocalApiInterceptor 가 꺼지고 실제 /v1 서버로 요청)

## 준비물
- Docker Desktop (무료, 가입 없음)
- (STEP 3~) Gemini / OpenAI 키