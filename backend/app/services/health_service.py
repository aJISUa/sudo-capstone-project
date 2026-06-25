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


# kind 별 표시 메타 (라벨/단위/차트 범위/대표값 추출 방식)
_KIND_META = {
    "weight": {
        "label": "체중", "unit": "kg",
        "chart_min_y": 50, "chart_max_y": 100, "chart_interval": 10,
        "scalar": lambda v: v.get("kg"),
        "lower_is_better": True,
    },
    "blood-pressure": {
        "label": "혈압", "unit": "mmHg",
        "chart_min_y": 80, "chart_max_y": 160, "chart_interval": 20,
        # 혈압은 수축기(systolic)를 대표값으로
        "scalar": lambda v: v.get("systolic"),
        "lower_is_better": True,
    },
    "blood-sugar": {
        "label": "혈당", "unit": "mg/dL",
        "chart_min_y": 70, "chart_max_y": 160, "chart_interval": 20,
        "scalar": lambda v: v.get("mg_per_dl"),
        "lower_is_better": True,
    },
}

# 데모 폴백을 kind 로 빠르게 찾기 위한 매핑
_DEMO_BY_KIND = {ind.kind: ind for ind in _DEMO_INDICATORS}


def _indicator_from_vitals(kind: str, rows: list) -> HealthIndicator | None:
    """특정 kind 의 vital row 들(시간순)로 HealthIndicator 구성. 부족하면 None."""
    import json

    meta = _KIND_META[kind]
    points: list[tuple] = []  # (recorded_at, scalar_value, raw_value_dict)
    for r in rows:
        try:
            v = json.loads(r.value_json) if r.value_json else {}
        except json.JSONDecodeError:
            continue
        s = meta["scalar"](v)
        if s is None:
            continue
        points.append((r.recorded_at, float(s), v))

    if not points:
        return None

    points.sort(key=lambda p: p[0])  # 시간 오름차순
    values = [p[1] for p in points]
    latest = values[-1]

    # delta: 처음 대비 변화
    first = values[0]
    diff = latest - first
    improving = (diff < 0) if meta["lower_is_better"] else (diff > 0)
    if len(values) >= 2 and abs(diff) > 0:
        delta_text = f"{diff:+.0f}{meta['unit']} (기록 시작 대비)"
    else:
        delta_text = "추세를 보려면 기록을 더 쌓아보세요"

    # 차트용: 최근 최대 14개
    chart_values = [round(v, 1) for v in values[-14:]]

    # last_7_days: 최근 7개를 0~1 로 정규화(없으면 채움)
    recent = values[-7:]
    lo, hi = min(recent), max(recent)
    span = (hi - lo) or 1.0
    last_7 = [round((v - lo) / span, 2) for v in recent]
    while len(last_7) < 7:
        last_7.insert(0, last_7[0] if last_7 else 0.0)

    # recent_records: 최근 5건 (최신 먼저)
    def _fmt(val_dict) -> str:
        if kind == "blood-pressure":
            return f"{val_dict.get('systolic')}/{val_dict.get('diastolic')} {meta['unit']}"
        s = meta["scalar"](val_dict)
        return f"{s:g} {meta['unit']}"

    labels = ["오늘", "1일 전", "2일 전", "3일 전", "4일 전"]
    recent_records = []
    for i, (_, _, raw) in enumerate(reversed(points[-5:])):
        recent_records.append(RecentRecord(label=labels[i] if i < len(labels) else f"{i}일 전",
                                            value=_fmt(raw)))

    # latest_value 표시
    if kind == "blood-pressure":
        latest_value = str(points[-1][2].get("systolic"))
    else:
        latest_value = f"{latest:g}"

    return HealthIndicator(
        kind=kind, label=meta["label"], latest_value=latest_value, unit=meta["unit"],
        delta_text=delta_text, improving=improving,
        last_7_days=last_7, chart_values=chart_values,
        chart_min_y=meta["chart_min_y"], chart_max_y=meta["chart_max_y"],
        chart_interval=meta["chart_interval"], recent_records=recent_records,
    )


def build_indicators_for_user(db, user_id: str) -> list[HealthIndicator]:
    """
    사용자의 vitals 로 지표 구성.
    - 해당 kind 의 기록이 있으면 실제 데이터로 지표 생성
    - 없으면 그 kind 만 데모 지표로 폴백 (화면이 비지 않도록)
    순서는 항상 weight → blood-pressure → blood-sugar (프론트 기대 순서).
    """
    from app.models.models import Vital

    indicators: list[HealthIndicator] = []
    for kind in ("weight", "blood-pressure", "blood-sugar"):
        rows = db.scalars(
            select_vitals(Vital, user_id, kind)
        ).all()
        built = _indicator_from_vitals(kind, list(rows)) if rows else None
        indicators.append(built or _DEMO_BY_KIND[kind])
    return indicators


def select_vitals(Vital, user_id: str, kind: str):
    """kind 의 모든 vital 을 가져오는 select (최근 30건)."""
    from sqlalchemy import select
    return (
        select(Vital)
        .where(Vital.user_id == user_id)
        .where(Vital.kind == kind)
        .order_by(Vital.recorded_at.desc())
        .limit(30)
    )
