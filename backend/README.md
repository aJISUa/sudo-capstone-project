# Backend — Vision AI Prototype

On-Care 백엔드 영역입니다. **현재는 Gemini Vision 기반 식단 분석 프로토타입(PoC)** 만 구현되어 있으며, FastAPI 서버화 및 Flutter 앱 연동은 **그로쓰 단계 예정**입니다.

> ✅ 동작: Gemini Vision 식단 분석 (실제 Gemini API 호출)  ·  🔵 설계: FastAPI 서버 · REST API · 앱 연동
>
> 이 PoC 는 **독립 실행 스크립트**로, 아직 Flutter 앱에는 연동되어 있지 않습니다. (앱은 mock / 로컬 seed 데이터로 동작)

## 구조

```
backend/
├── README.md
├── requirements.txt
└── services/
    ├── gemini_service.py     # Gemini Vision 식단 분석 PoC
    ├── .env.example          # 필요한 환경변수 템플릿
    ├── mymeal_1.jpg          # 테스트용 식단 사진
    └── mymeal_2.jpg
```

## 무엇을 하는가

음식 사진을 입력하면 Gemini Vision(`gemini-3-flash-preview`)이 다음을 **한국어로** 반환합니다.

1. 식단 구성 — 사진 속 음식명 나열
2. 칼로리 추정 — 음식별 + 총 칼로리
3. **고혈압 관점 식단평** — 나트륨 높은 음식 지적, DASH 식단 기준 장단점, 개선 제안

(On-Care 의 *고혈압·당뇨 위험군 특화* 방향과 일치하는 프롬프트 설계)

## 실행 (로컬)

**사전 요구**: Python 3.x · Google AI Studio 발급 API 키

```bash
cd backend
pip install -r requirements.txt

cd services
cp .env.example .env          # .env 를 열어 실제 GEMINI_API_KEY 입력
python gemini_service.py      # mymeal_1.jpg 를 분석해 결과를 출력
```

## 환경변수

| 변수 | 설명 |
|------|------|
| `GEMINI_API_KEY` | Google AI Studio 발급 키 — https://aistudio.google.com/apikey |

`.env` 는 `.gitignore` 처리되어 **커밋되지 않습니다.** 실제 키는 절대 커밋하지 말고, 공유는 `.env.example` 의 placeholder 로만 하세요.

## 로드맵 (그로쓰 단계)

- [ ] FastAPI 로 래핑 → `POST /diet/analyze` REST 엔드포인트
- [ ] YOLOv8 음식 필터 단계 추가 (2-stage: 음식 판별 → Gemini 분석)
- [ ] 공공데이터 식품영양성분 DB 매핑으로 한국 음식 정확도 보정
- [ ] Flutter 앱 연동 (`flutter run --dart-define=USE_MOCK_API=false`)
