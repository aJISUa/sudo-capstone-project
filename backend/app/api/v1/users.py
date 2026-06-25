"""
사용자 라우터 — 프론트 계약 정렬.

  GET  /users/me           -> { id, name, email }
  GET  /users/me/health    -> { profile, risk, indicators[], activity_points, activity_rank, settings[] }
  POST /auth/login         -> { access_token, token_type }   (Stage 4 대비)
  POST /auth/register      -> { id, name, email }             (Stage 4 대비)

데이터 엔드포인트(/users/me*)는 토큰 없으면 데모 사용자로 동작.
"""
from __future__ import annotations

import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser
from app.core.security import create_access_token, hash_password, verify_password
from app.db.session import get_db
from app.models.models import HealthProfile, User
from app.schemas.user import (
    HealthProfileBrief, RiskInfo, SettingItem, Token, UserHealth, UserMe, UserRegister,
)
from app.services.health_service import DEMO_SETTINGS, build_indicators_for_user

router = APIRouter(tags=["users"])


@router.get("/users/me", response_model=UserMe)
def get_me(current_user: CurrentUser) -> UserMe:
    return UserMe(id=current_user.id, name=current_user.name, email=current_user.email)


@router.get("/users/me/health", response_model=UserHealth)
def get_my_health(
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> UserHealth:
    profile = current_user.health_profile

    # risk: 저장된 프로필 있으면 사용, 없으면 데모 기본값(프론트 mock 과 동일)
    if profile and profile.risk_title:
        risk = RiskInfo(title=profile.risk_title, body=profile.risk_body, level=profile.risk_level)
        points = profile.activity_points
        rank = profile.activity_rank
    else:
        risk = RiskInfo(
            title="고혈압·당뇨 위험 주의",
            body="최근 혈압과 혈당 추세가 다소 높습니다. 식단·운동 관리에 신경 써주세요.",
            level="medium",
        )
        points = 1240
        rank = 14

    indicators = build_indicators_for_user(db, current_user.id)

    return UserHealth(
        profile=HealthProfileBrief(name=current_user.name, email=current_user.email),
        risk=risk,
        indicators=indicators,
        activity_points=points,
        activity_rank=rank,
        settings=[SettingItem(**s) for s in DEMO_SETTINGS],
    )


# ---- 인증 (Stage 4 대비, 지금도 동작) ----

@router.post("/auth/register", response_model=UserMe, status_code=status.HTTP_201_CREATED)
def register(payload: UserRegister, db: Annotated[Session, Depends(get_db)]) -> UserMe:
    exists = db.scalar(select(User).where(User.email == payload.email))
    if exists:
        raise HTTPException(status_code=409, detail="이미 가입된 이메일입니다.")
    user = User(
        id=f"user-{uuid.uuid4().hex[:12]}",
        email=payload.email,
        name=payload.name or payload.email.split("@")[0],
        hashed_password=hash_password(payload.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return UserMe(id=user.id, name=user.name, email=user.email)


@router.post("/auth/login", response_model=Token)
def login(
    form: Annotated[OAuth2PasswordRequestForm, Depends()],
    db: Annotated[Session, Depends(get_db)],
) -> Token:
    user = db.scalar(select(User).where(User.email == form.username))
    if not user or not verify_password(form.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="이메일 또는 비밀번호가 올바르지 않습니다.")
    return Token(access_token=create_access_token(user.id))
