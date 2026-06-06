<div align="center">

<img src="docs/assets/oncare-banner.png" alt="On-Care Banner" width="900"/>

<br/><br/>


# On-care <img src="docs/assets/oncare-logo-name.png" alt="On-Care Logo" width="150" align="left"/>

***HealthMate AI: 불규칙한 생활 속 2030을 위한<br> 고혈압·당뇨 위험군 대상 식단 인식·코칭 통합 헬스케어 플랫폼***

<br/>

[![Intro Page](https://img.shields.io/badge/Intro_Page-소개페이지-185079?style=for-the-badge&logo=googlechrome&logoColor=white)](https://ewhasudo.zapto.org/)
[![Web](https://img.shields.io/badge/Web-서비스_바로가기-3eafdf?style=for-the-badge&logo=flutter&logoColor=white)](https://ewhasudo.zapto.org/frontend/#/dashboard)
[![YouTube Demo](https://img.shields.io/badge/YouTube-데모_영상_보기-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C4ivM_dlAww?si=8iOWmOpSxcpQmlU3)

<br/><br/>

</div>

---

## Why On-Care

> 2030 세대의 만성질환 유병률이 구조적으로 급증하고 있다. 그러나 시장의 헬스케어 앱들은 여전히 *기록의 번거로움*, *맥락 없는 획일적 조언*, *온·오프라인의 단절* 이라는 세 가지 한계를 벗어나지 못한다.

On-Care 는 이 세 가지 마찰을 정면으로 해결하기 위해 만들어진 **AI 헬스케어 플랫폼**입니다. 사진 한 장으로 식단을 자동 분석하고, 사용자의 모든 누적 이력을 RAG 로 참조하는 AI 코치가 *내 데이터를 아는* 맞춤 조언을 제공하며, 식단·운동·헬스장·일정·상담을 단일 앱에서 통합 제공합니다.

<br/>

## Problem

20~30대를 대상으로 한 국민건강보험공단·자체 사용자 인터뷰 결과, 다음의 다섯 가지 페인 포인트가 일관되게 관찰되었습니다.

| # | 페인 포인트 | 본질 |
|---|-------------|------|
| 1 | **수치적 위험은 급증, 도구는 정체** | 최근 5년 2030 당뇨 +38%, 고혈압 +28%. 그러나 기존 앱은 여전히 수동 검색 / 바코드 입력 방식. |
| 2 | **기록 → 행동 변화 단절** | 매끼 입력은 요구하지만, 누적 데이터 기반의 *맥락 있는* 피드백이 없어 사용자는 3일 안에 이탈. |
| 3 | **개인화 부재** | 칼로리 알림 수준. 만성질환자에게 진짜 필요한 건 *얼마나 먹었나* 가 아니라 *무엇을 피해야 하나*. |
| 4 | **다이어트 패러다임의 한계** | 시장 대부분이 체중 감량·소셜 챌린지 중심. 질환 관리에 부적합. |
| 5 | **온·오프라인 분리** | 트레이너·헬스장 연결이 없어 사용자가 앱 밖으로 이탈. 정보 흐름의 연속성 부재. |

**한 줄 요약** — 기존 헬스케어 앱은 *기록 중심 · 비개인화 · 파편화* 된 구조로 인해, 만성질환 위험군의 지속적 건강 관리와 실제 행동 변화를 만들어내지 못한다.

<br/>

## Solution

On-Care 는 위 다섯 가지 마찰을 다음의 네 가지 기술적 의사결정으로 제거합니다.

| 마찰 | On-Care 의 해법 |
|------|----------------|
| 기록의 번거로움 | **Vision AI 2-stage 파이프라인** — YOLOv8 음식 필터 + Gemini Vision 영양 분석 + 공공데이터 영양성분 DB 매핑 |
| 맥락 없는 조언 | **RAG 기반 AI 코치** — 사용자 인바디·식단·운동·질환 이력을 Pinecone 에 임베딩, GPT-4o 에 실시간 컨텍스트로 주입 |
| 질환 무관 설계 | **2030 고혈압·당뇨 위험군 도메인 특화** — 나트륨 추적·GI 분류·불규칙 식사 패턴 감지 |
| 온·오프라인 분리 | **O2O 통합** — 카카오맵 기반 헬스장 검색·예약, 트레이너 인앱 채팅, 건강 요약 자동 전달 |

**핵심 가치** — *기록 도구가 아닌, 행동 변화를 만드는 앱.*

<br/>

## Current MVP Status

> ⚠️ **본 프로젝트는 현재 Flutter 기반의 크로스플랫폼 Frontend MVP 중심**으로 구현되어 있습니다. AI 엔진 및 백엔드 서버는 상세 아키텍처 설계 및 핵심 API 프로토타이핑 단계이며, 향후 순차적으로 통합될 예정입니다.

### Currently Implemented (구현 완료 항목)
* **Flutter 기반 반응형 UI/UX**: 모바일 및 웹 환경을 모두 지원하는 크로스플랫폼 인터페이스 구축
* **사용자 흐름 및 핵심 시나리오 구현**: 식단 기록, 운동 가이드, 통합 대시보드, 헬스장 검색 등 주요 기능의 프론트엔드 인터랙션 완성
* **웹 기반 MVP 데모 배포**: 타깃 유저 대상 사용성 테스트(UT)가 가능한 실구동 웹 데모 운영
* **시나리오 기반 검증**: 프론트엔드 목업(Mock) 데이터를 활용한 유저 인터뷰 및 핵심 가치 제안 검증

### In Progress / Planned (설계 및 개발 예정 항목)
* **FastAPI 기반 백엔드**: Docker 기반 컨테이너화 및 JWT 인증 시스템, REST API 규격 설계
* **Vision AI Pipeline**: YOLOv8 단일 객체 탐지 엔진 연동 및 Gemini Vision 영양성분 매핑 로직 구현 예정
* **RAG AI Coach**: Pinecone Vector DB 인덱싱 아키텍처 및 LangChain 기반 대화형 파이프라인 연동 예정

<br/>

## Key Features

| 기능 | 설명 | 핵심 기술 |
|------|------|-----------|
| **Vision AI 식단 자동 인식** | 음식 사진 1장으로 식품 종류·영양소를 분석 및 기록하는 시나리오 구현 (*핵심 엔진 설계 단계*) | Flutter (UI) <br> *(YOLOv8 · Gemini API 연동 예정)* |
| **RAG 기반 AI 헬스 챗봇** | 사용자 건강 이력을 실시간 컨텍스트로 주입하여 개인 맞춤 코칭을 제공하는 대화형 UX | Flutter (UI) <br> *(LangChain · Pinecone · GPT-4o 연동 예정)* |
| **AI 맞춤 운동 코칭** | 체력·목적·건강 상태 기반 운동 루틴 생성 및 동적 재조정 화면 인터랙션 | Flutter (UI) |
| **헬스장 검색 & 트레이너 연동** | 위치 기반 검색·예약·트레이너 인앱 채팅 화면 및 정보 연속성 흐름 설계 | 카카오맵 API (연동 예정) |
| **통합 건강 일정 관리** | 식단·운동·병원 예약 캘린더 통합 및 대시보드 실시간 푸시 알림 연동 | Flutter Local State |
| **Streak 보상 시스템** | 활동 포인트·연속 달성 보상 UI 및 동기부여 메커니즘 검증 | Flutter Local State |

<br/>

## Vision AI Pipeline
> 💡 **Architecture Design (시스템 설계안)**
> 본 파이프라인은 Vision AI 연동을 위한 아키텍처 설계 단계이며, YOLOv8 푸드 필터와 Gemini Vision API의 2-Stage 구조로 기획되었습니다.

사진 한 장이 어떻게 영양 정보로 변환되는지 (파이프라인 설계안):

<p align="center">
  <img src="docs/diagrams/vision-pipeline.svg" alt="Vision AI 식단 인식 파이프라인" width="720"/>
</p>

> **2-stage 구조의 핵심** — YOLOv8 로 음식 여부를 먼저 판별해 불필요한 Gemini 호출을 차단하고, 음식으로 확인된 이미지에 한해 Gemini Vision 으로 세밀한 영양 분석을 수행합니다. 결과는 그대로 사용하지 않고 공공데이터 식품영양성분 DB 와 매핑하여 한국 음식 정확도를 확보합니다.

<br/>

## RAG Pipeline
> 📌 **Architecture Design 핵심 요약**
> 본 파이프라인은 사용자 건강 기록을 기반으로 개인화된 코칭을 제공하기 위한 RAG 아키텍처 설계안입니다. Pinecone Vector DB 기반 검색 결과를 GPT-4o에 실시간 컨텍스트로 주입하는 구조로 설계되었습니다.

사용자의 질문이 어떻게 개인화된 답변으로 변환되는지:

<p align="center">
  <img src="docs/diagrams/rag-pipeline.svg" alt="RAG 기반 AI 코칭 파이프라인" width="900"/>
</p>

> 단순 일반 정보가 아닌 ***내 이번 주 기록 기준*** 맞춤 조언이 핵심 차별점입니다. 한국영양학회 등 공인 데이터만 인덱싱하는 Closed-domain RAG + 프롬프트 가드레일로 의료 행위 위험을 차단합니다.

<br/>

## System Architecture
> 💡 **Architecture & Infrastructure Design (시스템 아키텍처 설계안)**
> 본 구조는 서비스 고도화를 위한 전체 시스템 아키텍처 및 인프라 설계안입니다. 현재 MVP 단계 이후 FastAPI 백엔드 및 AWS 데이터베이스 인프라를 순차적으로 연동할 예정입니다.

<p align="center">
  <img src="docs/diagrams/system-architecture.svg" alt="On-Care 시스템 아키텍처" width="960"/>
</p>

<br/>

## Tech Stack

**Mobile**

![Flutter](https://img.shields.io/badge/Flutter-Cross_Platform-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State-00AAFF?style=flat-square)
![GoRouter](https://img.shields.io/badge/go__router-Navigation-027DFD?style=flat-square)
![Drift](https://img.shields.io/badge/Drift-Local_DB-0175C2?style=flat-square)

**Backend (Designed & Planned)**

![FastAPI](https://img.shields.io/badge/FastAPI-Async_REST-009688?style=flat-square&logo=fastapi&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-AWS_RDS-4479A1?style=flat-square&logo=mysql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?style=flat-square&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF?style=flat-square&logo=githubactions&logoColor=white)

**AI / ML (Designed & Planned)**

![YOLOv8](https://img.shields.io/badge/YOLOv8-Image_Filter-FF6B35?style=flat-square)
![Gemini](https://img.shields.io/badge/Gemini_Vision-Nutrition-4285F4?style=flat-square)
![GPT-4o](https://img.shields.io/badge/GPT--4o-LLM-412991?style=flat-square)
![LangChain](https://img.shields.io/badge/LangChain-RAG-1C3C3C?style=flat-square)
![Pinecone](https://img.shields.io/badge/Pinecone-Vector_DB-00B4A2?style=flat-square)
![PyTorch](https://img.shields.io/badge/PyTorch-Inference-EE4C2C?style=flat-square&logo=pytorch&logoColor=white)

**Platform & APIs**

![Firebase](https://img.shields.io/badge/Firebase_FCM-Push-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Kakao Map](https://img.shields.io/badge/Kakao_Map-Location-FFCD00?style=flat-square&logo=kakao&logoColor=black)
![공공데이터](https://img.shields.io/badge/공공데이터포털-식품영양성분_DB-0066CC?style=flat-square)

<br/>

## Competitive Analysis

기존 헬스케어 플랫폼의 공백을 정확히 공략합니다.

| 비교 항목 | 삼성헬스 | 필라이즈 | 밀리그램 / 인아웃 | **On-Care** |
| :--- | :--- | :--- | :--- | :--- |
| **식단 기록 방식** | 직접 검색 · 수동 입력 | 사진 기반 AI 인식 | 사진 저장 · 빠른 입력 위주 | **사진 1장 → YOLOv8 필터링 + Gemini Vision 분석 + 공공데이터 자동 매핑 (설계)** |
| **한국 음식 정확도** | 보통 | 보통 | 낮음 (사용자 등록 의존) | **높음 (공공데이터 식품영양성분 DB 검증 예정)** |
| **AI 코칭 방식** | 활동 데이터 단편 해석 | AI 코치 + 전문가 Q&A | 소셜·챌린지 동기부여 | **RAG 기반 누적 이력 실시간 참조 맥락 코칭 (설계)** |
| **만성질환 특화** | 없음 (범용) | 일부 (혈당 연동 등) | 없음 (다이어트 중심) | **2030 고혈압·당뇨 위험군 도메인 특화** |
| **오프라인 연결** | 없음 | 없음 | 없음 | **헬스장 검색·예약·트레이너 채팅 + 건강 요약 자동 전달 (O2O 설계)** |
| **플랫폼 독립성** | 갤럭시 생태계 종속 | iOS / Android | iOS / Android | **Flutter 단일 코드베이스 iOS / Android 동일 경험** |

세부 분석은 [`docs/competitive_analysis.md`](docs/competitive_analysis.md) 참조.

<br/>

## Development Roadmap

On-Care는 Ideation 단계를 넘어 크로스플랫폼 Flutter MVP 개발 및 AI 파이프라인 엔진 통합을 순차적으로 진행하고 있습니다.

| Stage | 개발 범위 | 상태 |
| :--- | :--- | :--- |
| **S0 · Ideation** | 사용자 인터뷰 · 시장 분석 · 도메인 Pain Point 검증 | ✅ 완료 |
| **S1 · Prototype** | Flutter 웹 프로토타입 설계 및 핵심 UX 흐름 검증 | ✅ 완료 |
| **S2 · Flutter MVP** | 디자인 시스템 구축 · Riverpod 상태 관리 · MVP 핵심 화면 구현 | 🚧 진행 중 |
| **S3 · FastAPI Backend** | Docker 기반 서버 구축 · JWT 인증 및 REST API 설계 | 📅 예정 |
| **S4 · Vision AI** | YOLOv8 푸드 필터 · Gemini Vision 영양성분 DB 매핑 파이프라인 | 📅 예정 |
| **S5 · RAG Coach** | Pinecone Vector DB 기반 GPT-4o 개인화 맥락 코칭 엔진 | 📅 예정 |
| **S6 · O2O & Reward** | 카카오맵 헬스장 연동 · 트레이너 채팅 · Streak 보상 시스템 | 📅 예정 |

<br/>

## 사용자 인터뷰 및 MVP 평가 (User Interview & UT Feedback)

On-Care 서비스의 실질적인 유효성을 검증하기 위해, 핵심 타깃층인 2030 고혈압·당뇨 위험군 실제 사용자 3인을 대상으로 진행한 인터뷰 및 MVP 사용성 테스트(UT) 요약입니다. <br>

세부 내용은 [`docs/user_interview.md`](docs/user_interview.md) 참조.

* **인터뷰 참여자 정보 (Target Users)**
  * **참여자 A (25세, 대학원생)**: 불규칙한 식습관으로 최근 검진에서 '당뇨 전단계(공복혈당 주의)' 판정을 받음
  * **참여자 B (28세, 회사원)**: 부모님 모두 고혈압 약을 복용 중이신 '가족력 유의군'이며, 혈압 관리가 필요한 상태
  * **참여자 C (31세, 프리랜서)**: 만성적인 운동 부족으로 검진에서 '혈압 주의 및 고지혈증 위험군'으로 분류됨
* **MVP 핵심 피드백 (What Welcomed)**
  * **Vision AI 식단 자동 인식**: *"사진 한 장으로 나트륨과 당류 같은 성분이 자동 계산되어 수동 입력의 번거로움과 기록 마찰이 획기적으로 줄었습니다." (참여자 A)*
  * **RAG 기반 AI 코칭 챗봇**: **"AI 코치가 내 주간 기록을 기반으로 맥락 있는 피드백을 제공하는 흐름이 기존 앱보다 더 개인화되어 있다고 느껴졌습니다."* (참여자 B)*
  * **통합 건강 일정 관리**: *"병원 정기검진일과 헬스장 스케줄을 단일 캘린더로 합쳐주고 메인 대시보드와 실시간 동기화해 주니 일상 속 실천을 지속하는 데 큰 도움이 됩니다." (참여자 C)*
* **사용자 피드백 기반 한계점 (Limitations)**
  * 조리 방식이나 양념에 숨겨진 영양성분의 정확한 추정 오차 가능성이 지적됨
  * 혈당·혈압 수치를 수동 입력해야 하는 번거로움과 실시간 생체 지표 변화 감지의 한계가 존재함
  * 현재의 O2O 솔루션이 건강 요약본을 트레이너에게 일방향으로 '전송'하는 수준에 머물러 있음

> 💡 위 세 가지 핵심 기술적 한계점을 극복하기 위한 On-Care의 구체적인 향후 발전 방향은 아래 **What's Next** 아키텍처 확장 계획안에서 다룹니다.

<br/>

## Repository Structure

```
sudo-capstone-project/
├── frontend/flutter/           # Flutter 앱 (iOS / Android / Web)
│   ├── lib/
│   │   ├── app/                # 라우팅 · 부트스트랩
│   │   ├── core/               # 네트워크 · 스토리지 · 에러 처리
│   │   ├── design_system/      # 토큰 · 위젯 · 차트
│   │   ├── features/           # 도메인 모듈 (dashboard / diet / exercise / my_health / ...)
│   │   └── shared/             # 공통 위젯 · 모달
│   └── test/                   # 단위 · 위젯 · golden · 통합 테스트
├── backend/services/           # 백엔드 서비스 (현재는 Gemini Vision 데모)
├── docs/                       # 프로젝트 문서 · 발표 자료 · 다이어그램
├── .github/                    # PR 템플릿 · 배포 워크플로우
└── README.md
```


<br/>

<br/>

## Getting Started (Run Locally)

### Prerequisites
* Flutter SDK (v3.x 권장)
* Dart SDK (v3.x 권장)

### Installation & Execution
```bash
# 1. 저장소 복제
git clone https://github.com/CSE-Sudo-26/sudo-capstone-project.git

# 2. Flutter 프로젝트 디렉토리 이동
cd sudo-capstone-project/frontend/flutter

# 3. 의존성 설치
flutter pub get

# 4. Web 실행
flutter run -d chrome
```

## What's Next

| 방향 | 설명 | 기대효과 |
|------|------|----------|
| **연속혈당측정기 및 웨어러블 연동** | CGM(연속혈당측정기) API 및 스마트워치(Galaxy Watch / Apple Watch)의 SDK 를 연동 | 수동 입력 마찰 완전 제거, **식후 혈당 스파이크·급격한 혈압 상승을 실시간 감지** 하여 즉각적인 AI 위험 경고 트리거 구축 |
| **3D Depth 기술 기반 식단 인식 고도화** | 스마트폰의 LiDAR 센서나 Depth 정보를 활용하여 음식의 3차원 부피(Volume) 를 정밀 추정하는 모델 도입 | 공공데이터 식품영양성분 DB 매핑 정확도 극대화, **칼로리·성분 오차 범위 5% 이내로 축소** |
| **쌍방향 O2O 피드백 루프 및 가상 트레이닝** | 트레이너 전용 웹 대시보드를 구축하여 트레이너가 처방한 운동 루틴이 유저의 'AI 맞춤 운동 코칭 엔진' 에 즉시 동적 반영되도록 아키텍처 확장 | **진정한 온·오프라인 하이브리드 헬스케어 생태계 완성** |

> 웨어러블 연동, 3D 식단 인식, 트레이너 연계를 통해 실시간 건강 예측과 개인 맞춤 코칭이 가능한 통합 헬스케어 생태계를 구축하는 것을 목표로 합니다.

<br/>

## Team


|                                                         최지수                                                          |                                                            박서연                                                            |                                                           신수빈                                                           |
|:--------------------------------------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------------:|
| <img src="https://github.com/aJISUa.png" width="100"><br/><img src="docs/assets/spacer.png" width="200" height="1"/> | <img src="https://github.com/seoyeon0516.png" width="100"><br/><img src="docs/assets/spacer.png" width="200" height="1"/> | <img src="https://github.com/subin21cc.png" width="100"><br/><img src="docs/assets/spacer.png" width="200" height="1"/> |
|                                         [@aJISUa](https://github.com/aJISUa)                                         |                                      [@seoyeon0516](https://github.com/seoyeon0516)                                       |                                       [@subin21cc](https://github.com/subin21cc)                                        |
|                                               Data Analyst & Back-end                                                |                                                     DevOps & Back-end                                                     |                                                     AI & Front-end                                                      |


<br/>

## License

본 프로젝트는 [MIT License](LICENSE) 하에 배포됩니다. 자세한 내용은 [`LICENSE`](LICENSE) 파일을 참고하세요.

> Copyright © 2026 On-Care Team (CSE-Sudo-26: 최지수 · 박서연 · 신수빈)

<br/>

---

<div align="center">

**2026 이화여자대학교 캡스톤디자인**

*Team 02 Sudo — Jisu Choi · Seoyeon Park · Subin Shin*

</div>
