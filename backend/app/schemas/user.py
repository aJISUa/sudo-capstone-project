"""
사용자 응답 스키마 — 프론트 계약(_usersMe, _usersMeHealth)에 정확히 맞춤.

모든 필드는 snake_case (프론트 case_mapper 가 camelCase 로 변환).
"""
from __future__ import annotations

from typing import Optional
from pydantic import BaseModel


# ---- GET /users/me ----
class UserMe(BaseModel):
    id: str
    name: str
    email: str


# ---- GET /users/me/health ----
class HealthProfileBrief(BaseModel):
    name: str
    email: str


class RiskInfo(BaseModel):
    title: str
    body: str
    level: str  # low | medium | high


class RecentRecord(BaseModel):
    label: str
    value: str


class HealthIndicator(BaseModel):
    kind: str  # weight | blood-pressure | blood-sugar
    label: str
    latest_value: str
    unit: str
    delta_text: str
    improving: bool
    last_7_days: list[float]
    chart_values: list[float]
    chart_min_y: float
    chart_max_y: float
    chart_interval: float
    recent_records: list[RecentRecord]


class SettingItem(BaseModel):
    label: str
    icon: str
    kind: str


class UserHealth(BaseModel):
    profile: HealthProfileBrief
    risk: RiskInfo
    indicators: list[HealthIndicator]
    activity_points: int
    activity_rank: Optional[int]
    settings: list[SettingItem]


# ---- 인증(로그인) ----
class Token(BaseModel):
    access_token: str
    refresh_token: str = ""
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    refresh_token: str


class SocialLoginRequest(BaseModel):
    # provider 가 준 토큰 (kakao/naver=access_token, google=id_token)
    token: str


class UserRegister(BaseModel):
    email: str
    password: str
    name: str = ""
