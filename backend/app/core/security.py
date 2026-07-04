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


def _encode(subject: str, token_type: str, ttl: timedelta) -> str:
    now = datetime.now(timezone.utc)
    payload = {"sub": subject, "type": token_type, "iat": now, "exp": now + ttl}
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def create_access_token(subject: str) -> str:
    return _encode(subject, "access", timedelta(minutes=settings.access_token_expire_minutes))


def create_refresh_token(subject: str) -> str:
    return _encode(subject, "refresh", timedelta(days=settings.refresh_token_expire_days))


def decode_access_token(token: str) -> str:
    payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
    # refresh 토큰을 액세스로 오용하는 것을 차단 (구버전 토큰은 type 이 없어 허용)
    if payload.get("type") == "refresh":
        raise jwt.InvalidTokenError("refresh 토큰은 액세스로 사용할 수 없습니다.")
    sub = payload.get("sub")
    if sub is None:
        raise jwt.InvalidTokenError("sub 없음")
    return str(sub)


def decode_refresh_token(token: str) -> str:
    payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
    if payload.get("type") != "refresh":
        raise jwt.InvalidTokenError("refresh 토큰이 아닙니다.")
    sub = payload.get("sub")
    if sub is None:
        raise jwt.InvalidTokenError("sub 없음")
    return str(sub)
