"""비밀번호 해싱 + JWT 토큰."""
from __future__ import annotations

from datetime import datetime, timedelta, timezone

import jwt
from pwdlib import PasswordHash
from pwdlib.hashers.bcrypt import BcryptHasher

from app.core.config import get_settings

settings = get_settings()
_password_hash = PasswordHash((BcryptHasher(),))


def hash_password(plain: str) -> str:
    return _password_hash.hash(plain)


def verify_password(plain: str, hashed: str) -> bool:
    if not hashed:
        return False
    return _password_hash.verify(plain, hashed)


def create_access_token(subject: str) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": subject,
        "iat": now,
        "exp": now + timedelta(minutes=settings.access_token_expire_minutes),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_access_token(token: str) -> str:
    payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
    sub = payload.get("sub")
    if sub is None:
        raise jwt.InvalidTokenError("sub 없음")
    return str(sub)
