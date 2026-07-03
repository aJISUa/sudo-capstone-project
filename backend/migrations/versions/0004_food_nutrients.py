"""food_nutrients table (공공 식품영양성분 DB 매핑용)

Vision 인식 결과의 음식명을 공공 식품영양성분 DB(식약처/국가표준)에 매핑해
신뢰 가능한 영양 수치로 교체하기 위한 참조 테이블.

Revision ID: 0004_food_nutrients
Revises: 0003_profile_fields
Create Date: 2026-07-04
"""
from __future__ import annotations

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "0004_food_nutrients"
down_revision: str | Sequence[str] | None = "0003_profile_fields"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "food_nutrients",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("name_norm", sa.String(100), nullable=False, server_default=""),
        sa.Column("category", sa.String(30), nullable=False, server_default=""),
        sa.Column("serving_size_g", sa.Float(), nullable=True),
        sa.Column("calories", sa.Float(), nullable=False, server_default="0"),
        sa.Column("sodium_mg", sa.Float(), nullable=False, server_default="0"),
        sa.Column("sugar_g", sa.Float(), nullable=False, server_default="0"),
        sa.Column("carbs_g", sa.Float(), nullable=True),
        sa.Column("protein_g", sa.Float(), nullable=True),
        sa.Column("fat_g", sa.Float(), nullable=True),
        sa.Column("source", sa.String(20), nullable=False, server_default="mfds"),
    )
    op.create_index("ix_food_nutrients_name", "food_nutrients", ["name"])
    op.create_index("ix_food_nutrients_name_norm", "food_nutrients", ["name_norm"])


def downgrade() -> None:
    op.drop_index("ix_food_nutrients_name_norm", table_name="food_nutrients")
    op.drop_index("ix_food_nutrients_name", table_name="food_nutrients")
    op.drop_table("food_nutrients")
