"""
알림 라우터 — 프론트 계약 정렬.

  GET  /notifications              -> 최신순 배열 (time_ago 포함)
  POST /notifications/{id}/read    -> 읽음 처리
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser
from app.db.session import get_db
from app.models.models import Notification
from app.schemas.misc_api import NotificationOut

router = APIRouter(tags=["notifications"])


def _time_ago(dt: datetime) -> str:
    now = datetime.now(timezone.utc)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    sec = (now - dt).total_seconds()
    if sec < 60:
        return "방금 전"
    if sec < 3600:
        return f"{int(sec // 60)}분 전"
    if sec < 86400:
        return f"{int(sec // 3600)}시간 전"
    return f"{int(sec // 86400)}일 전"


@router.get("/notifications", response_model=list[NotificationOut])
def list_notifications(
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> list[NotificationOut]:
    rows = db.scalars(
        select(Notification)
        .where(Notification.user_id == current_user.id)
        .order_by(Notification.created_at.desc())
    ).all()
    return [
        NotificationOut(
            id=r.id, title=r.title, body=r.body, category=r.category,
            read=r.read, created_at=r.created_at, time_ago=_time_ago(r.created_at),
        )
        for r in rows
    ]


@router.post("/notifications/{notification_id}/read", status_code=200)
def mark_read(
    notification_id: str,
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> dict:
    row = db.scalar(select(Notification).where(Notification.id == notification_id))
    if row is None or row.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="알림을 찾을 수 없습니다.")
    row.read = True
    db.commit()
    return {"id": notification_id, "read": True}
