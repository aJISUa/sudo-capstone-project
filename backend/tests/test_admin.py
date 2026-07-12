"""관리자 권한 — 공공문서 업로드 보호.

- admin_email_set 파싱은 순수(로컬 실행).
- 엔드포인트 보호(201/403/401)는 DB 필요(로컬 skip, CI 실행).
"""
from __future__ import annotations

from uuid import uuid4


def test_admin_email_set_parsing():
    from app.core.config import Settings

    s = Settings(_env_file=None, admin_emails="A@x.com, b@Y.com ,")
    assert s.admin_email_set == {"a@x.com", "b@y.com"}


def _register_login(client, email: str) -> str:
    client.post("/v1/auth/register", json={"email": email, "password": "pw!", "name": "u"})
    return client.post("/v1/auth/login", data={"username": email, "password": "pw!"}).json()["access_token"]


def test_admin_can_upload_public_doc(client, db_session):
    from sqlalchemy import select

    from app.models.models import User

    email = f"admin-{uuid4().hex[:8]}@oncare.com"
    token = _register_login(client, email)

    # 관리자로 승격(운영에선 ADMIN_EMAILS 로 부팅 시 승격)
    user = db_session.scalar(select(User).where(User.email == email))
    user.is_admin = True
    db_session.commit()

    r = client.post(
        "/v1/coach/documents/public",
        json={
            "content": "물을 충분히 마시면 혈압 관리에 도움이 됩니다. 하루 6잔 이상을 권장합니다.",
            "domain": "general",
            "title": "수분 섭취 팁",
        },
        headers={"Authorization": f"Bearer {token}"},
    )
    assert r.status_code == 201, r.text
    assert r.json()["ingested_chunks"] >= 1


def test_non_admin_is_forbidden(client):
    email = f"user-{uuid4().hex[:8]}@oncare.com"
    token = _register_login(client, email)
    r = client.post(
        "/v1/coach/documents/public",
        json={"content": "test", "title": "t"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert r.status_code == 403


def test_unauthenticated_is_rejected(client):
    # require_admin 은 데모 폴백을 쓰지 않으므로 토큰 없으면 401
    r = client.post("/v1/coach/documents/public", json={"content": "test", "title": "t"})
    assert r.status_code == 401
