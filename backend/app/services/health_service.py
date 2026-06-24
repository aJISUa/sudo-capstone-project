"""
건강 지표 구성 서비스.

/users/me/health 의 indicators 를 만듭니다.
- 저장된 vitals 가 있으면 그것으로 구성 (STEP 5에서 vitals 입력이 붙으면 자동 반영)
- 없으면 프론트 mock 과 동일한 데모 지표를 반환 (지금 단계에서 화면이 비지 않게)

데모 지표 값은 프론트 LocalApiInterceptor._usersMeHealth 와 동일하게 맞췄습니다.
"""
from __future__ import annotations

from app.schemas.user import HealthIndicator, RecentRecord

# 프론트 mock 과 동일한 데모 지표 (체중 / 혈압 / 혈당)
_DEMO_INDICATORS: list[HealthIndicator] = [
    HealthIndicator(
        kind="weight", label="체중", latest_value="72", unit="kg",
        delta_text="-10kg (2주 전 대비)", improving=True,
        last_7_days=[0.62, 0.58, 0.52, 0.45, 0.36, 0.28, 0.20],
        chart_values=[82, 80, 79, 78, 78, 77, 77, 76, 75, 75, 74, 73, 73, 72],
        chart_min_y=70, chart_max_y=75, chart_interval=1,
        recent_records=[
            RecentRecord(label="오늘", value="72 kg"),
            RecentRecord(label="1일 전", value="72 kg"),
            RecentRecord(label="2일 전", value="73 kg"),
            RecentRecord(label="3일 전", value="73 kg"),
            RecentRecord(label="4일 전", value="74 kg"),
        ],
    ),
    HealthIndicator(
        kind="blood-pressure", label="혈압", latest_value="124", unit="mmHg",
        delta_text="-21mmHg (2주 전 대비)", improving=True,
        last_7_days=[0.80, 0.74, 0.66, 0.55, 0.42, 0.28, 0.16],
        chart_values=[145, 144, 142, 140, 140, 138, 136, 134, 132, 130, 129, 127, 126, 124],
        chart_min_y=100, chart_max_y=140, chart_interval=10,
        recent_records=[
            RecentRecord(label="오늘", value="124 mmHg"),
            RecentRecord(label="1일 전", value="125 mmHg"),
            RecentRecord(label="2일 전", value="126 mmHg"),
            RecentRecord(label="3일 전", value="127 mmHg"),
            RecentRecord(label="4일 전", value="128 mmHg"),
        ],
    ),
    HealthIndicator(
        kind="blood-sugar", label="혈당", latest_value="96", unit="mg/dL",
        delta_text="-32mg/dL (2주 전 대비)", improving=True,
        last_7_days=[0.78, 0.70, 0.60, 0.50, 0.40, 0.30, 0.18],
        chart_values=[128, 124, 120, 118, 116, 113, 110, 108, 106, 104, 102, 100, 98, 96],
        chart_min_y=80, chart_max_y=140, chart_interval=20,
        recent_records=[
            RecentRecord(label="오늘", value="96 mg/dL"),
            RecentRecord(label="1일 전", value="98 mg/dL"),
            RecentRecord(label="2일 전", value="99 mg/dL"),
            RecentRecord(label="3일 전", value="100 mg/dL"),
            RecentRecord(label="4일 전", value="102 mg/dL"),
        ],
    ),
]

# 프론트 mock 과 동일한 설정 메뉴
DEMO_SETTINGS = [
    {"label": "내 프로필", "icon": "👤", "kind": "my-profile"},
    {"label": "건강 목표", "icon": "📊", "kind": "health-goal"},
    {"label": "알림 설정", "icon": "🔔", "kind": "notification"},
    {"label": "고객 지원", "icon": "💬", "kind": "support"},
]


def build_indicators_for_user(db, user_id: str) -> list[HealthIndicator]:
    """
    사용자의 vitals 로 지표 구성. 데이터가 없으면 데모 지표 반환.

    STEP 5(vitals 입력)가 붙으면 이 함수가 실제 데이터로 지표를 만들도록 확장합니다.
    지금은 vitals 가 비어 있으므로 데모로 폴백합니다.
    """
    from app.models.models import Vital

    has_any = db.query(Vital.id).filter(Vital.user_id == user_id).first()
    if has_any is None:
        return _DEMO_INDICATORS
    # TODO(STEP 5): 실제 vitals 집계로 HealthIndicator 구성
    return _DEMO_INDICATORS
