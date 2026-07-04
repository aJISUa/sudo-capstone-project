"""보안 유틸(비밀번호 해싱 · JWT) 검증 — DB 불필요."""
from __future__ import annotations

import jwt
import pytest

from app.core.security import (
    create_access_token,
    decode_access_token,
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
