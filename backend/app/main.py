"""
FastAPI 진입점 (STEP 1: 골격 재구성).

프론트 계약에 맞춰 /v1 prefix 로 라우터를 마운트합니다.
실행: uvicorn app.main:app --reload
문서: http://localhost:8000/docs
"""
from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1 import system
from app.core.config import get_settings
from app.db.init_db import init_db

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    yield


app = FastAPI(
    title="On-Care Backend",
    description="만성질환(고혈압·당뇨) 위험군 헬스케어 플랫폼 — 프론트 계약 정렬판",
    version=settings.app_version,
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[o.strip() for o in settings.cors_allow_origins.split(",")],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# /v1 prefix 로 마운트 (프론트 base URL 이 /v1 을 포함하는 계약)
app.include_router(system.router, prefix=settings.api_v1_prefix)
