"""
시스템 엔드포인트 — 프론트 LocalApiInterceptor 의 _ping/_healthz/_version 과 정확히 일치.

프론트 기대 응답:
  GET /ping     -> { "message": "pong (...)" }
  GET /healthz  -> { "status": "ok", "backend": "..." }
  GET /version  -> { "api_version": "v1", "app_version": "..." }
"""
from __future__ import annotations

from fastapi import APIRouter

from app.core.config import get_settings

router = APIRouter(tags=["system"])
settings = get_settings()


@router.get("/ping")
def ping() -> dict[str, str]:
    return {"message": "pong"}


@router.get("/healthz")
def healthz() -> dict[str, str]:
    return {"status": "ok", "backend": "fastapi"}


@router.get("/version")
def version() -> dict[str, str]:
    return {"api_version": "v1", "app_version": settings.app_version}
