"""보안 유틸(비밀번호 해싱 · JWT) 검증 — DB 불필요."""
from __future__ import annotations

import jwt
import pytest

from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_access_token,
    decode_refresh_token,
    hash_password,
    verify_password,
)


def test_password_hash_roundtrip():
    hashed = hash_password("s3cret!")
    assert hashed and hashed != "s3cret!"
    assert verify_password("s3cret!", hashed) is True
    assert verify_password("wrong-password", hashed) is False


def test_verify_empty_hash_is_false():
    assert verify_password("anything", "") is False


def test_jwt_roundtrip():
    token = create_access_token("user-123")
    assert decode_access_token(token) == "user-123"


def test_jwt_invalid_token_raises():
    with pytest.raises(jwt.InvalidTokenError):
        decode_access_token("not-a-valid-token")


def test_refresh_token_roundtrip():
    token = create_refresh_token("user-9")
    assert decode_refresh_token(token) == "user-9"


def test_access_token_rejected_as_refresh():
    """액세스 토큰을 refresh 로 쓰면 거부."""
    with pytest.raises(jwt.InvalidTokenError):
        decode_refresh_token(create_access_token("user-9"))


def test_refresh_token_rejected_as_access():
    """refresh 토큰을 액세스로 쓰면 거부(토큰 혼용 방지)."""
    with pytest.raises(jwt.InvalidTokenError):
        decode_access_token(create_refresh_token("user-9"))
