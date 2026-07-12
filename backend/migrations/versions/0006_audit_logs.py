"""audit_logs table (보안 감사 로그)

인증(로그인 성공/실패·가입·소셜)·관리자 액션을 추적하기 위한 감사 테이블.

Revision ID: 0006_audit_logs
Revises: 0005_user_is_admin
Create Date: 2026-07-04
"""
from __future__ import annotations

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "0006_audit_logs"
down_revision: str | Sequence[str] | None = "0005_user_is_admin"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "audit_logs",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("event", sa.String(50), nullable=False),
        # FK 없음: 사용자가 삭제돼도 감사 기록은 남는다
        sa.Column("user_id", sa.String(64), nullable=True),
        sa.Column("ip", sa.String(64), nullable=False, server_default=""),
        sa.Column("success", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("detail", sa.Text(), nullable=False, server_default=""),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_audit_logs_event", "audit_logs", ["event"])
    op.create_index("ix_audit_logs_user_id", "audit_logs", ["user_id"])


def downgrade() -> None:
    op.drop_index("ix_audit_logs_user_id", table_name="audit_logs")
    op.drop_index("ix_audit_logs_event", table_name="audit_logs")
    op.drop_table("audit_logs")
