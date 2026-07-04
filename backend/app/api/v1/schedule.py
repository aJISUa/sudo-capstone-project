"""
일정 라우터 — 프론트 계약 정렬.

  GET  /schedule/events?date=YYYY-MM-DD  -> 해당 날짜 일정 배열 (date 생략 시 오늘)
  POST /schedule/events                  -> 일정 추가
"""
from __future__ import annotations

import uuid
from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser
from app.db.session import get_db
from app.models.models import ScheduleEvent
from app.schemas.misc_api import ScheduleEventCreate, ScheduleEventOut

router = APIRouter(tags=["schedule"])


@router.get("/schedule/events", response_model=list[ScheduleEventOut])
def list_events(
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
    date: str | None = Query(None, description="YYYY-MM-DD. 생략 시 오늘."),
    month: str | None = Query(None, description="YYYY-MM. 지정 시 그 달 전체(캘린더용)."),
) -> list[ScheduleEvent]:
    stmt = select(ScheduleEvent).where(ScheduleEvent.user_id == current_user.id)
    if month:
        stmt = stmt.where(ScheduleEvent.date.like(f"{month}-%"))
    else:
        target = date or datetime.now().strftime("%Y-%m-%d")
        stmt = stmt.where(ScheduleEvent.date == target)
    rows = db.scalars(
        stmt.order_by(ScheduleEvent.date.asc(), ScheduleEvent.time.asc())
    ).all()
    return list(rows)


@router.post("/schedule/events", response_model=ScheduleEventOut, status_code=201)
def create_event(
    payload: ScheduleEventCreate,
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> ScheduleEvent:
    row = ScheduleEvent(
        id=f"evt-{uuid.uuid4().hex[:12]}",
        user_id=current_user.id,
        date=payload.date,
        time=payload.time,
        title=payload.title,
        category=payload.category,
        emoji=payload.emoji,
        color_hex=payload.color_hex,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row
