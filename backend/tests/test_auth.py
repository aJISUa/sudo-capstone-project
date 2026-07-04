"""인증(회원가입 · 로그인 · 토큰) — DB 필요(로컬 skip, CI 실행)."""
from __future__ import annotations

from uuid import uuid4


def test_register_login_and_me(client):
    email = f"tester-{uuid4().hex[:8]}@oncare.com"
    password = "pw-12345!"

    r = client.post(
        "/v1/auth/register",
        json={"email": email, "password": password, "name": "테스터"},
    )
    assert r.status_code == 201, r.text
    user_id = r.json()["id"]

    r2 = client.post("/v1/auth/login", data={"username": email, "password": password})
    assert r2.status_code == 200, r2.text
    token = r2.json()["access_token"]
    assert token

    # 발급 토큰으로 인증된 /users/me 는 가입한 사용자를 반환해야 한다
    r3 = client.get("/v1/users/me", headers={"Authorization": f"Bearer {token}"})
    assert r3.status_code == 200
    assert r3.json()["id"] == user_id


def test_login_wrong_password_401(client):
    email = f"tester-{uuid4().hex[:8]}@oncare.com"
    client.post("/v1/auth/register", json={"email": email, "password": "correct-pw!", "name": "x"})
    r = client.post("/v1/auth/login", data={"username": email, "password": "wrong-pw"})
    assert r.status_code == 401


def test_duplicate_register_conflicts_409(client):
    email = f"dup-{uuid4().hex[:8]}@oncare.com"
    r1 = client.post("/v1/auth/register", json={"email": email, "password": "pw!", "name": "a"})
    assert r1.status_code == 201
    r2 = client.post("/v1/auth/register", json={"email": email, "password": "pw!", "name": "a"})
    assert r2.status_code == 409
