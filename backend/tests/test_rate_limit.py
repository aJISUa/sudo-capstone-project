"""인증 엔드포인트 rate limit.

fastapi 가 필요하므로 로컬(venv, fastapi 미설치)에서는 이 모듈을 통째로 skip 하고,
CI(전체 의존성)에서 실행한다. 엔드포인트 테스트는 추가로 DB(client)가 필요하다.
"""
from __future__ import annotations

from uuid import uuid4

import pytest

pytest.importorskip("fastapi")


def test_rate_limiter_unit_blocks_over_limit():
    from fastapi import HTTPException

    from app.core.rate_limit import RateLimiter

    rl = RateLimiter()
    for _ in range(3):
        rl.check("k", 3, 60.0)  # 3회 허용
    with pytest.raises(HTTPException):
        rl.check("k", 3, 60.0)  # 4회째 429
    rl.clear()
    rl.check("k", 3, 60.0)  # clear 후 다시 허용


def test_register_is_rate_limited(client):
    # 기본 한도 10/분 → 11번째 요청은 429 (per-test 로 limiter 초기화됨)
    last = None
    for _ in range(11):
        last = client.post(
            "/v1/auth/register",
            json={"email": f"rl-{uuid4().hex[:10]}@oncare.com", "password": "pw!", "name": "u"},
        )
    assert last.status_code == 429, last.text
    assert "Retry-After" in last.headers
