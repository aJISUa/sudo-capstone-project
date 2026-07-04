"""Google 로그인 검증 — id_token 을 tokeninfo 로 확인.

운영 규모에서는 Google JWKS 로컬 검증(google-auth)이 권장되나,
MVP 단계에서는 tokeninfo 엔드포인트로 검증한다.
"""
from __future__ import annotations

import httpx

from app.services.social.base import SocialAuthError, SocialIdentity, SocialVerifier

_TOKENINFO = "https://oauth2.googleapis.com/tokeninfo"


class GoogleVerifier(SocialVerifier):
    provider = "google"

    async def verify(self, token: str) -> SocialIdentity:
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(_TOKENINFO, params={"id_token": token})
        except httpx.HTTPError as exc:
            raise SocialAuthError(f"google 요청 실패: {exc}") from exc

        if resp.status_code != 200:
            raise SocialAuthError(f"google 토큰 검증 실패({resp.status_code})")

        data = resp.json()
        uid = str(data.get("sub") or "")
        if not uid:
            raise SocialAuthError("google 사용자 id(sub) 없음")

        return SocialIdentity(
            provider="google",
            provider_user_id=uid,
            email=data.get("email") or "",
            name=data.get("name") or "",
        )
