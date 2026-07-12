"""coach_documents.embedding 차원 1536 → 768 (Gemini text-embedding-004)

RAG 임베딩 제공자를 Gemini(text-embedding-004, 768차원)로 확정(이슈 #155).
pgvector 컬럼 차원이 바뀌므로 embedding 컬럼을 재생성한다(기존 벡터는 무효 → NULL).
업그레이드 후 `python -m scripts.reembed` 로 재임베딩해야 검색이 동작한다.
(공공 가이드 8종은 init 시 멱등 시드되지만, 기존 DB 는 exists 체크로 재시드되지 않으므로 reembed 필요.)

Revision ID: 0007_coach_embedding_768
Revises: 0006_audit_logs
Create Date: 2026-07-12
"""
from __future__ import annotations

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa
from pgvector.sqlalchemy import Vector

revision: str = "0007_coach_embedding_768"
down_revision: str | Sequence[str] | None = "0006_audit_logs"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # 차원이 바뀌면 기존 1536 벡터는 무효이므로 컬럼을 재생성(내용 content 는 보존).
    op.drop_column("coach_documents", "embedding")
    op.add_column(
        "coach_documents",
        sa.Column("embedding", Vector(768), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("coach_documents", "embedding")
    op.add_column(
        "coach_documents",
        sa.Column("embedding", Vector(1536), nullable=True),
    )
