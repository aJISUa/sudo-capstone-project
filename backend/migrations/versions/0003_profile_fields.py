"""profile & health-goal fields on health_profiles

내 프로필/온보딩/건강 목표 저장을 위해 health_profiles 에 개인정보·인구통계·
목표치 컬럼을 추가한다. 기존 행 보존을 위한 순수 추가(additive) 마이그레이션.

Revision ID: 0003_profile_fields
Revises: 0002_social_accounts
Create Date: 2026-07-03
"""
from __future__ import annotations

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "0003_profile_fields"
down_revision: str | Sequence[str] | None = "0002_social_accounts"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

# (컬럼명, 타입, nullable, server_default)
_COLUMNS = [
    ("phone", sa.String(20), False, ""),
    ("birth_date", sa.String(10), False, ""),
    ("gender", sa.String(10), False, ""),
    ("height_cm", sa.Float(), True, None),
    ("weight_kg", sa.Float(), True, None),
    ("goal_weight_kg", sa.Float(), True, None),
    ("goal_bp_systolic", sa.Integer(), True, None),
    ("goal_blood_sugar", sa.Integer(), True, None),
    ("daily_calories", sa.Integer(), True, None),
    ("daily_sodium_mg", sa.Integer(), True, None),
]


def upgrade() -> None:
    for name, type_, nullable, default in _COLUMNS:
        op.add_column(
            "health_profiles",
            sa.Column(name, type_, nullable=nullable, server_default=default),
        )
    op.add_column(
        "health_profiles",
        sa.Column("onboarded", sa.Boolean(), nullable=False, server_default=sa.false()),
    )


def downgrade() -> None:
    op.drop_column("health_profiles", "onboarded")
    for name, *_ in reversed(_COLUMNS):
        op.drop_column("health_profiles", name)
