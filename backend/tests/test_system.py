"""시스템 엔드포인트 스모크 — DB 필요(로컬 skip, CI 실행)."""
from __future__ import annotations


def test_ping(client):
    r = client.get("/v1/ping")
    assert r.status_code == 200


def test_healthz(client):
    r = client.get("/v1/healthz")
    assert r.status_code == 200


def test_version(client):
    r = client.get("/v1/version")
    assert r.status_code == 200
    body = r.json()
    assert body["api_version"] == "v1"
    assert "app_version" in body
