"""Kakao 로그인 검증 — access_token 으로 사용자 정보 조회."""
from __future__ import annotations

import httpx

from app.services.social.base import SocialAuthError, SocialIdentity, SocialVerifier

_USERINFO = "https://kapi.kakao.com/v2/user/me"


class KakaoVerifier(SocialVerifier):
    provider = "kakao"

    async def verify(self, token: str) -> SocialIdentity:
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(_USERINFO, headers={"Authorization": f"Bearer {token}"})
        except httpx.HTTPError as exc:
            raise SocialAuthError(f"kakao 요청 실패: {exc}") from exc

        if resp.status_code != 200:
            raise SocialAuthError(f"kakao 토큰 검증 실패({resp.status_code})")

        data = resp.json()
        uid = str(data.get("id") or "")
        if not uid:
            raise SocialAuthError("kakao 사용자 id 없음")

        account = data.get("kakao_account") or {}
        profile = account.get("profile") or {}
        return SocialIdentity(
            provider="kakao",
            provider_user_id=uid,
            email=account.get("email") or "",
            name=profile.get("nickname") or "",
        )
