"""
운동 라우터 — 프론트 계약 정렬.

  GET  /exercise/weeks/current   -> 이번 주 운동 집계(요일별/타입별 + streak + 코칭)
  POST /exercise/sessions        -> 운동 기록 추가 (집계에 반영)
"""
from __future__ import annotations

import uuid
from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser
from app.db.session import get_db
from app.models.models import ExerciseSession
from app.schemas.exercise_api import (
    ExerciseSessionCreate, ExerciseSessionOut, ExerciseWeekResponse,
)
from app.services.exercise_service import (
    WEEKDAY_LABELS, build_current_week, monday_of_this_week_str,
)

router = APIRouter(tags=["exercise"])

_ALLOWED_TYPES = {"cardio", "strength", "yoga", "walking", "stretching"}


@router.get("/exercise/weeks/current", response_model=ExerciseWeekResponse)
def current_week(
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> ExerciseWeekResponse:
    week_start = monday_of_this_week_str()
    rows = db.scalars(
        select(ExerciseSession)
        .where(ExerciseSession.user_id == current_user.id)
        .where(ExerciseSession.week_start == week_start)
    ).all()
    data = build_current_week(list(rows))
    return ExerciseWeekResponse(
        sessions=[ExerciseSessionOut(**s) for s in data.pop("sessions")],
        **data,
    )


@router.post("/exercise/sessions", response_model=ExerciseSessionOut, status_code=201)
def add_session(
    payload: ExerciseSessionCreate,
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> ExerciseSessionOut:
    if payload.type not in _ALLOWED_TYPES:
        raise HTTPException(status_code=400, detail=f"허용되지 않는 운동 타입: {payload.type}")
    if payload.minutes <= 0:
        raise HTTPException(status_code=400, detail="minutes 는 1 이상이어야 합니다.")

    day_label = payload.day_label or WEEKDAY_LABELS[datetime.now().weekday()]
    if day_label not in WEEKDAY_LABELS:
        raise HTTPException(status_code=400, detail=f"잘못된 요일 라벨: {day_label}")

    row = ExerciseSession(
        id=f"ex-{uuid.uuid4().hex[:12]}",
        user_id=current_user.id,
        week_start=monday_of_this_week_str(),
        day_label=day_label,
        type=payload.type,
        minutes=payload.minutes,
        calories=payload.calories,
    )
    db.add(row)
    db.commit()
    db.refresh(row)

    # 단건 응답도 프론트 표시 형식(date_label/time_label/items)을 채워 반환
    one = build_current_week([row])["sessions"][0]
    return ExerciseSessionOut(**one)
