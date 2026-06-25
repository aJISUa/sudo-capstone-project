"""
바이탈 API 스키마 — 프론트 계약(_vitals*) 정렬.

kind 별 value 구조가 다르므로 입력 모델을 분리:
  - weight         : { kg }
  - blood-pressure : { systolic, diastolic }
  - blood-sugar    : { mg_per_dl }

공통 응답: { id, kind, value(dict), recorded_at(ISO) }
"""
from __future__ import annotations

from datetime import datetime
from typing import Any, Optional
from pydantic import BaseModel, Field


# ---- 입력 ----
class WeightIn(BaseModel):
    kg: float = Field(..., gt=0, le=500)
    recorded_at: Optional[datetime] = None


class BloodPressureIn(BaseModel):
    systolic: int = Field(..., gt=0, le=300)
    diastolic: int = Field(..., gt=0, le=200)
    recorded_at: Optional[datetime] = None


class BloodSugarIn(BaseModel):
    mg_per_dl: float = Field(..., gt=0, le=1000)
    recorded_at: Optional[datetime] = None


# ---- 응답 ----
class VitalOut(BaseModel):
    id: str
    kind: str  # weight | blood-pressure | blood-sugar
    value: dict[str, Any]
    recorded_at: datetime
