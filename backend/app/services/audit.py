"""보안 감사 로그 기록 (best-effort).

인증/관리자 이벤트를 audit_logs 에 남긴다. 감사 기록 실패가 요청을 깨뜨리면 안 되므로
best-effort(실패 시 rollback 후 무시)로 처리한다.
"""
from __future__ import annotations

import logging

from fastapi import Request
from sqlalchemy.orm import Session

from app.models.models import AuditLog

log = logging.getLogger(__name__)


def client_ip(request: Request) -> str:
    """클라이언트 IP. 프록시 뒤면 X-Forwarded-For 첫 IP 사용."""
    xff = request.headers.get("x-forwarded-for")
    if xff:
        return xff.split(",")[0].strip()[:64]
    return (request.client.host if request.client else "")[:64]


def record(
    db: Session, *, event: str, user_id: str | None = None,
    ip: str = "", success: bool = True, detail: str = "",
) -> None:
    try:
        db.add(AuditLog(
            event=event, user_id=user_id, ip=ip, success=success, detail=detail[:2000],
        ))
        db.commit()
    except Exception as e:  # noqa: BLE001 — 감사 실패가 요청을 깨면 안 됨
        log.warning("감사 로그 기록 실패(무시): %s", e)
        try:
            db.rollback()
        except Exception:  # noqa: BLE001
            pass
