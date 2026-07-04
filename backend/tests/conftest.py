"""pytest 공통 설정.

- 순수 유닛 테스트(test_config, test_security)는 DB 없이 실행됩니다.
- DB/엔드포인트 테스트는 `client` 픽스처를 쓰며, DB 연결이 안 되면 자동 skip 됩니다
  (로컬은 skip, CI 의 Postgres(pgvector) 서비스에서 실행).
"""
from __future__ import annotations

import os

import pytest
from sqlalchemy import create_engine, text

DATABASE_URL = os.environ.get(
    "DATABASE_URL", "postgresql+psycopg://oncare:oncare@localhost:5432/oncare"
)


def _db_available() -> bool:
    try:
        engine = create_engine(DATABASE_URL, pool_pre_ping=True)
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        engine.dispose()
        return True
    except Exception:
        return False


@pytest.fixture(scope="session")
def client():
    """FastAPI TestClient. DB 가 없으면 skip."""
    if not _db_available():
        pytest.skip("DB 연결 불가 — CI(Postgres 서비스)에서 실행됩니다.")
    from fastapi.testclient import TestClient

    from app.main import app

    with TestClient(app) as c:  # lifespan → init_db (vector extension / create_all / seed)
        yield c
