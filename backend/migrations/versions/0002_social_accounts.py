"""social_accounts table (소셜 로그인 연결)

Revision ID: 0002_social_accounts
Revises: 0001_baseline
Create Date: 2026-07-03
"""
from __future__ import annotations

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "0002_social_accounts"
down_revision: str | Sequence[str] | None = "0001_baseline"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "social_accounts",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column(
            "user_id", sa.String(64),
            sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False,
        ),
        sa.Column("provider", sa.String(20), nullable=False),
        sa.Column("provider_user_id", sa.String(128), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("provider", "provider_user_id", name="uq_social_provider_uid"),
    )
    op.create_index("ix_social_accounts_user_id", "social_accounts", ["user_id"])
    op.create_index("ix_social_accounts_provider", "social_accounts", ["provider"])


def downgrade() -> None:
    op.drop_index("ix_social_accounts_provider", table_name="social_accounts")
    op.drop_index("ix_social_accounts_user_id", table_name="social_accounts")
    op.drop_table("social_accounts")
