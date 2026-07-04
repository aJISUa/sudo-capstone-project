"""users.is_admin (관리자 권한)

민감 엔드포인트(공공문서 업로드 등)를 관리자 전용으로 보호하기 위한 플래그.
기존 행 보존을 위한 추가형(additive) 마이그레이션.

Revision ID: 0005_user_is_admin
Revises: 0004_food_nutrients
Create Date: 2026-07-04
"""
from __future__ import annotations

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "0005_user_is_admin"
down_revision: str | Sequence[str] | None = "0004_food_nutrients"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "users",
        sa.Column("is_admin", sa.Boolean(), nullable=False, server_default=sa.false()),
    )


def downgrade() -> None:
    op.drop_column("users", "is_admin")
