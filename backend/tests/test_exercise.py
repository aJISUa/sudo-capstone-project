"""운동 기록 추가/조회 — DB 필요(로컬 skip, CI 실행)."""
from __future__ import annotations

from uuid import uuid4


def _login(client) -> dict:
    email = f"ex-{uuid4().hex[:8]}@oncare.com"
    client.post("/v1/auth/register", json={"email": email, "password": "pw!", "name": "u"})
    token = client.post("/v1/auth/login", data={"username": email, "password": "pw!"}).json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_add_session_reflected_in_week(client):
    h = _login(client)
    r = client.post(
        "/v1/exercise/sessions",
        json={"type": "other", "minutes": 30, "calories": 120, "day_label": "월"},
        headers=h,
    )
    assert r.status_code == 201, r.text
    assert r.json()["type"] == "other"
    assert r.json()["minutes"] == 30

    week = client.get("/v1/exercise/weeks/current", headers=h)
    assert week.status_code == 200
    assert week.json()["total_minutes"] == 30


def test_add_session_rejects_unknown_type(client):
    h = _login(client)
    r = client.post("/v1/exercise/sessions", json={"type": "flying", "minutes": 10}, headers=h)
    assert r.status_code == 400


def test_add_session_rejects_nonpositive_minutes(client):
    h = _login(client)
    r = client.post("/v1/exercise/sessions", json={"type": "cardio", "minutes": 0}, headers=h)
    assert r.status_code == 400
