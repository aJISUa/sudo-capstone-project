"""
ORM 모델 — 프론트 계약(LocalApiInterceptor + drift 스키마)에 맞춤.

핵심 정렬 사항:
- 사용자 id 는 문자열(예: 'user-demo')
- 식단은 나트륨(sodium_mg)·당류(sugar_g)를 1급 지표로 (고혈압·당뇨 특화)
- vitals 는 kind(weight|blood-pressure|blood-sugar) + value(JSON)
- drift 테이블(diet_entries, exercise_sessions, schedule_events, notifications)과 1:1 대응

이번 STEP 1 에서는 테이블 생성만 검증하고, 살은 이후 STEP 에서 채웁니다.
"""
from __future__ import annotations

from datetime import datetime

from pgvector.sqlalchemy import Vector
from sqlalchemy import (
    Boolean, DateTime, Float, ForeignKey, Integer, String, Text, func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base

EMBED_DIM = 1536


class User(Base):
    __tablename__ = "users"

    # 계약상 문자열 id
    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(100), default="")
    hashed_password: Mapped[str] = mapped_column(String(255), default="")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    health_profile: Mapped["HealthProfile | None"] = relationship(
        back_populates="user", uselist=False, cascade="all, delete-orphan"
    )


class HealthProfile(Base):
    """건강 위험 정보 — /users/me/health 의 risk + 메타."""
    __tablename__ = "health_profiles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), unique=True)

    risk_title: Mapped[str] = mapped_column(String(200), default="")
    risk_body: Mapped[str] = mapped_column(Text, default="")
    risk_level: Mapped[str] = mapped_column(String(20), default="low")  # low|medium|high
    conditions: Mapped[str] = mapped_column(Text, default="")  # "고혈압, 당뇨 전단계"
    goals: Mapped[str] = mapped_column(Text, default="")
    activity_points: Mapped[int] = mapped_column(Integer, default=0)
    activity_rank: Mapped[int | None] = mapped_column(Integer, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped["User"] = relationship(back_populates="health_profile")


class DietEntry(Base):
    """식단 기록 — drift DietEntries 대응. 나트륨·당류 포함."""
    __tablename__ = "diet_entries"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    date: Mapped[str] = mapped_column(String(10), index=True)  # YYYY-MM-DD
    meal_type: Mapped[str] = mapped_column(String(20))  # breakfast|lunch|dinner|snack
    time_label: Mapped[str] = mapped_column(String(10), default="")
    foods_json: Mapped[str] = mapped_column(Text, default="[]")  # [{name, calories}]
    total_calories: Mapped[int] = mapped_column(Integer, default=0)
    sodium_mg: Mapped[int] = mapped_column(Integer, default=0)
    sugar_g: Mapped[int] = mapped_column(Integer, default=0)
    engine: Mapped[str] = mapped_column(String(20), default="")  # 인식 엔진(gemini|yolo)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class ExerciseSession(Base):
    """운동 기록 — drift ExerciseSessions 대응."""
    __tablename__ = "exercise_sessions"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    week_start: Mapped[str] = mapped_column(String(10), index=True)  # 월요일 YYYY-MM-DD
    day_label: Mapped[str] = mapped_column(String(4))  # 월/화/...
    type: Mapped[str] = mapped_column(String(20))  # cardio|strength|yoga|walking
    minutes: Mapped[int] = mapped_column(Integer, default=0)
    calories: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class Vital(Base):
    """체중/혈압/혈당 — drift Vitals 대응."""
    __tablename__ = "vitals"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    kind: Mapped[str] = mapped_column(String(20), index=True)  # weight|blood-pressure|blood-sugar
    value_json: Mapped[str] = mapped_column(Text, default="{}")
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class ScheduleEvent(Base):
    """일정 — drift ScheduleEvents 대응."""
    __tablename__ = "schedule_events"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    date: Mapped[str] = mapped_column(String(10), index=True)
    time: Mapped[str] = mapped_column(String(10), default="")
    title: Mapped[str] = mapped_column(String(200))
    category: Mapped[str] = mapped_column(String(20))  # hospital|exercise|meal|medication|other
    emoji: Mapped[str] = mapped_column(String(10), default="")
    color_hex: Mapped[str] = mapped_column(String(10), default="#E0F2F7")


class Notification(Base):
    """알림 — drift NotificationItems 대응."""
    __tablename__ = "notifications"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    title: Mapped[str] = mapped_column(String(200))
    body: Mapped[str] = mapped_column(Text, default="")
    category: Mapped[str] = mapped_column(String(20))  # reminder|health_check|achievement|system
    read: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class CoachDocument(Base):
    """RAG 코치용 문서 + 임베딩 (STEP 7)."""
    __tablename__ = "coach_documents"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    source: Mapped[str] = mapped_column(String(50), default="")
    content: Mapped[str] = mapped_column(Text)
    embedding: Mapped[list[float] | None] = mapped_column(Vector(EMBED_DIM), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class Place(Base):
    """온오프라인 연결: 장소 — /places/nearby. 카카오맵 연동 자리."""
    __tablename__ = "places"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    name: Mapped[str] = mapped_column(String(200))
    category: Mapped[str] = mapped_column(String(30))  # medical|fitness|healthy_food|pharmacy
    address: Mapped[str] = mapped_column(String(300), default="")
    lat: Mapped[float | None] = mapped_column(Float, nullable=True)
    lng: Mapped[float | None] = mapped_column(Float, nullable=True)
    kakao_place_id: Mapped[str] = mapped_column(String(50), default="")
