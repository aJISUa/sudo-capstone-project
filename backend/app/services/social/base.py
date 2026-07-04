"""소셜 로그인 검증 추상화.

각 provider(kakao/google/naver/apple)는 SocialVerifier 를 구현해,
클라이언트가 넘긴 토큰을 provider 에 확인하고 정규화된 SocialIdentity 를 돌려준다.
recognizer/embedder 와 동일한 factory 패턴.
"""
from __future__ import annotations

from dataclasses import dataclass


class SocialAuthError(Exception):
    """소셜 토큰 검증 실패(무효 토큰 등)."""


@dataclass
class SocialIdentity:
    provider: str            # kakao|google|naver|apple
    provider_user_id: str    # provider 내 고유 사용자 id
    email: str = ""
    name: str = ""


class SocialVerifier:
    provider: str = ""

    async def verify(self, token: str) -> SocialIdentity:
        raise NotImplementedError
