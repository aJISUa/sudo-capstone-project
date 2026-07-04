"""baseline schema (9 tables + pgvector)

현재 ORM 모델(app/models/models.py)과 1:1 대응하는 최초 베이스라인.
기존에는 Base.metadata.create_all() 로 생성하던 스키마를 마이그레이션으로 고정한다.

Revision ID: 0001_baseline
Revises:
Create Date: 2026-07-03
"""
from __future__ import annotations

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from pgvector.sqlalchemy import Vector

revision: str = "0001_baseline"
down_revision: str | Sequence[str] | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

# 임베딩 차원(현재 기본값). 차원 변경은 별도 마이그레이션 + 재임베딩으로 처리.
EMBED_DIM = 1536
_now = sa.text("now()")
_user_fk = lambda: sa.ForeignKey("users.id", ondelete="CASCADE")  # noqa: E731


def upgrade() -> None:
    # RAG 임베딩 검색용 확장 (coach_documents.embedding 이전에 필요)
    op.execute("CREATE EXTENSION IF NOT EXISTS vector")

    op.create_table(
        "users",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("email", sa.String(255), nullable=False),
        sa.Column("name", sa.String(100), nullable=False, server_default=""),
        sa.Column("hashed_password", sa.String(255), nullable=False, server_default=""),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=_now),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)

    op.create_table(
        "health_profiles",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("user_id", sa.String(64), _user_fk(), nullable=False, unique=True),
        sa.Column("risk_title", sa.String(200), nullable=False, server_default=""),
        sa.Column("risk_body", sa.Text(), nullable=False, server_default=""),
        sa.Column("risk_level", sa.String(20), nullable=False, server_default="low"),
        sa.Column("conditions", sa.Text(), nullable=False, server_default=""),
        sa.Column("goals", sa.Text(), nullable=False, server_default=""),
        sa.Column("activity_points", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("activity_rank", sa.Integer(), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=_now),
    )

    op.create_table(
        "diet_entries",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("user_id", sa.String(64), _user_fk(), nullable=False),
        sa.Column("date", sa.String(10), nullable=False),
        sa.Column("meal_type", sa.String(20), nullable=False),
        sa.Column("time_label", sa.String(10), nullable=False, server_default=""),
        sa.Column("foods_json", sa.Text(), nullable=False, server_default="[]"),
        sa.Column("total_calories", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("sodium_mg", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("sugar_g", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("engine", sa.String(20), nullable=False, server_default=""),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=_now),
    )
    op.create_index("ix_diet_entries_user_id", "diet_entries", ["user_id"])
    op.create_index("ix_diet_entries_date", "diet_entries", ["date"])

    op.create_table(
        "exercise_sessions",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("user_id", sa.String(64), _user_fk(), nullable=False),
        sa.Column("week_start", sa.String(10), nullable=False),
        sa.Column("day_label", sa.String(4), nullable=False),
        sa.Column("type", sa.String(20), nullable=False),
        sa.Column("minutes", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("calories", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=_now),
    )
    op.create_index("ix_exercise_sessions_user_id", "exercise_sessions", ["user_id"])
    op.create_index("ix_exercise_sessions_week_start", "exercise_sessions", ["week_start"])

    op.create_table(
        "vitals",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("user_id", sa.String(64), _user_fk(), nullable=False),
        sa.Column("kind", sa.String(20), nullable=False),
        sa.Column("value_json", sa.Text(), nullable=False, server_default="{}"),
        sa.Column("recorded_at", sa.DateTime(timezone=True), nullable=False, server_default=_now),
    )
    op.create_index("ix_vitals_user_id", "vitals", ["user_id"])
    op.create_index("ix_vitals_kind", "vitals", ["kind"])

    op.create_table(
        "schedule_events",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("user_id", sa.String(64), _user_fk(), nullable=False),
        sa.Column("date", sa.String(10), nullable=False),
        sa.Column("time", sa.String(10), nullable=False, server_default=""),
        sa.Column("title", sa.String(200), nullable=False),
        sa.Column("category", sa.String(20), nullable=False),
        sa.Column("emoji", sa.String(10), nullable=False, server_default=""),
        sa.Column("color_hex", sa.String(10), nullable=False, server_default="#E0F2F7"),
    )
    op.create_index("ix_schedule_events_user_id", "schedule_events", ["user_id"])
    op.create_index("ix_schedule_events_date", "schedule_events", ["date"])

    op.create_table(
        "notifications",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("user_id", sa.String(64), _user_fk(), nullable=False),
        sa.Column("title", sa.String(200), nullable=False),
        sa.Column("body", sa.Text(), nullable=False, server_default=""),
        sa.Column("category", sa.String(20), nullable=False),
        sa.Column("read", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=_now),
    )
    op.create_index("ix_notifications_user_id", "notifications", ["user_id"])

    op.create_table(
        "coach_documents",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        # 공공 문서는 NULL(전체 공유), 개인 문서는 특정 user_id
        sa.Column("user_id", sa.String(64), _user_fk(), nullable=True),
        sa.Column("source", sa.String(50), nullable=False, server_default=""),
        sa.Column("domain", sa.String(20), nullable=False, server_default="general"),
        sa.Column("title", sa.String(300), nullable=False, server_default=""),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("embedding", Vector(EMBED_DIM), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=_now),
    )
    op.create_index("ix_coach_documents_user_id", "coach_documents", ["user_id"])
    op.create_index("ix_coach_documents_domain", "coach_documents", ["domain"])

    op.create_table(
        "places",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("name", sa.String(200), nullable=False),
        sa.Column("category", sa.String(30), nullable=False),
        sa.Column("address", sa.String(300), nullable=False, server_default=""),
        sa.Column("lat", sa.Float(), nullable=True),
        sa.Column("lng", sa.Float(), nullable=True),
        sa.Column("kakao_place_id", sa.String(50), nullable=False, server_default=""),
    )


def downgrade() -> None:
    op.drop_table("places")
    op.drop_index("ix_coach_documents_domain", table_name="coach_documents")
    op.drop_index("ix_coach_documents_user_id", table_name="coach_documents")
    op.drop_table("coach_documents")
    op.drop_index("ix_notifications_user_id", table_name="notifications")
    op.drop_table("notifications")
    op.drop_index("ix_schedule_events_date", table_name="schedule_events")
    op.drop_index("ix_schedule_events_user_id", table_name="schedule_events")
    op.drop_table("schedule_events")
    op.drop_index("ix_vitals_kind", table_name="vitals")
    op.drop_index("ix_vitals_user_id", table_name="vitals")
    op.drop_table("vitals")
    op.drop_index("ix_exercise_sessions_week_start", table_name="exercise_sessions")
    op.drop_index("ix_exercise_sessions_user_id", table_name="exercise_sessions")
    op.drop_table("exercise_sessions")
    op.drop_index("ix_diet_entries_date", table_name="diet_entries")
    op.drop_index("ix_diet_entries_user_id", table_name="diet_entries")
    op.drop_table("diet_entries")
    op.drop_table("health_profiles")
    op.drop_index("ix_users_email", table_name="users")
    op.drop_table("users")
    # vector 확장은 다른 객체가 쓸 수 있어 남겨둔다.
