"""
바이탈 라우터 — 프론트 계약 정렬.

  POST /vitals/weight          body { kg, recorded_at? }
  POST /vitals/blood-pressure  body { systolic, diastolic, recorded_at? }
  POST /vitals/blood-sugar     body { mg_per_dl, recorded_at? }
  GET  /vitals/{kind}/latest   -> 최신 1건 또는 {}

저장된 vitals 는 /users/me/health 의 indicators 구성에 자동 사용됩니다
(health_service.build_indicators_for_user).
"""
from __future__ import annotations

import json
import uuid
from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser
from app.db.session import get_db
from app.models.models import Vital
from app.schemas.vitals_api import (
    BloodPressureIn, BloodSugarIn, VitalOut, WeightIn,
)
from app.services.coach.personal_ingest import record_vital

router = APIRouter(tags=["vitals"])

_VALID_KINDS = {"weight", "blood-pressure", "blood-sugar"}


def _save_vital(db: Session, user_id: str, kind: str, value: dict,
                recorded_at: datetime | None) -> Vital:
    if recorded_at is not None and recorded_at.tzinfo is None:
        recorded_at = recorded_at.replace(tzinfo=timezone.utc)
    row = Vital(
        id=f"vital-{uuid.uuid4().hex[:12]}",
        user_id=user_id,
        kind=kind,
        value_json=json.dumps(value, ensure_ascii=False),
        recorded_at=recorded_at or datetime.now(timezone.utc),
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    # 개인 RAG 문서로 적재(코치가 내 최근 혈압·혈당·체중을 검색하도록). best-effort.
    record_vital(db, user_id, kind=kind, value=value)
    return row


def _to_out(row: Vital) -> VitalOut:
    return VitalOut(
        id=row.id, kind=row.kind,
        value=json.loads(row.value_json) if row.value_json else {},
        recorded_at=row.recorded_at,
    )


@router.post("/vitals/weight", response_model=VitalOut, status_code=201)
def post_weight(
    payload: WeightIn,
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> VitalOut:
    row = _save_vital(db, current_user.id, "weight", {"kg": payload.kg}, payload.recorded_at)
    return _to_out(row)


@router.post("/vitals/blood-pressure", response_model=VitalOut, status_code=201)
def post_blood_pressure(
    payload: BloodPressureIn,
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> VitalOut:
    row = _save_vital(
        db, current_user.id, "blood-pressure",
        {"systolic": payload.systolic, "diastolic": payload.diastolic},
        payload.recorded_at,
    )
    return _to_out(row)


@router.post("/vitals/blood-sugar", response_model=VitalOut, status_code=201)
def post_blood_sugar(
    payload: BloodSugarIn,
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> VitalOut:
    row = _save_vital(
        db, current_user.id, "blood-sugar",
        {"mg_per_dl": payload.mg_per_dl}, payload.recorded_at,
    )
    return _to_out(row)


@router.get("/vitals/{kind}/latest")
def get_latest(
    kind: str,
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> dict:
    if kind not in _VALID_KINDS:
        raise HTTPException(status_code=400, detail=f"잘못된 kind: {kind}. 허용: {sorted(_VALID_KINDS)}")
    row = db.scalar(
        select(Vital)
        .where(Vital.user_id == current_user.id)
        .where(Vital.kind == kind)
        .order_by(Vital.recorded_at.desc())
        .limit(1)
    )
    if row is None:
        return {}  # 계약: 데이터 없으면 빈 객체
    return _to_out(row).model_dump(mode="json")
