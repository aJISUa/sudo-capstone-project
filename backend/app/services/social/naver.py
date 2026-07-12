"""Naver 로그인 검증 — access_token 으로 프로필 조회."""
from __future__ import annotations

import httpx

from app.services.social.base import SocialAuthError, SocialIdentity, SocialVerifier

_USERINFO = "https://openapi.naver.com/v1/nid/me"


class NaverVerifier(SocialVerifier):
    provider = "naver"

    async def verify(self, token: str) -> SocialIdentity:
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(_USERINFO, headers={"Authorization": f"Bearer {token}"})
        except httpx.HTTPError as exc:
            raise SocialAuthError(f"naver 요청 실패: {exc}") from exc

        if resp.status_code != 200:
            raise SocialAuthError(f"naver 토큰 검증 실패({resp.status_code})")

        body = resp.json()
        profile = body.get("response") or {}
        uid = str(profile.get("id") or "")
        if not uid:
            raise SocialAuthError("naver 사용자 id 없음")

        return SocialIdentity(
            provider="naver",
            provider_user_id=uid,
            email=profile.get("email") or "",
            name=profile.get("name") or profile.get("nickname") or "",
        )
