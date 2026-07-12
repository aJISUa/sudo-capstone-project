"""Apple 로그인 검증 (스텁).

Apple 은 identity_token(JWT) 을 Apple 공개키(JWKS: https://appleid.apple.com/auth/keys)로
서명 검증하고 aud/iss 를 확인해야 한다. JWKS 캐싱·키 회전 처리가 필요해
별도 작업으로 구현한다(스텁 유지 — 호출 시 501 로 응답).
"""
from __future__ import annotations

from app.services.social.base import SocialIdentity, SocialVerifier


class AppleVerifier(SocialVerifier):
    provider = "apple"

    async def verify(self, token: str) -> SocialIdentity:
        raise NotImplementedError("Apple 로그인 검증은 이후 구현 예정입니다.")
