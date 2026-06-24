"""
장소 라우터 (온오프라인 연결) — 프론트 계약 정렬.

  GET /places/nearby?lat=&lng=&category=  -> 주변 장소 배열(거리순)

현재는 DB 에 시드된 장소를 거리 계산해 반환합니다.
카카오맵 실연동(developers.kakao.com 키 필요)은 _search_kakao() 자리에 채웁니다.
연동 후에도 응답 형식(PlaceOut)은 동일하므로 프론트는 영향 없음.
"""
from __future__ import annotations

import math
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser
from app.db.session import get_db
from app.models.models import Place
from app.schemas.misc_api import PlaceOut

router = APIRouter(tags=["places"])


def _haversine_m(lat1, lng1, lat2, lng2) -> int:
    """두 좌표 간 거리(m)."""
    r = 6371000
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp = math.radians(lat2 - lat1)
    dl = math.radians(lng2 - lng1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return int(r * 2 * math.asin(math.sqrt(a)))


@router.get("/places/nearby", response_model=list[PlaceOut])
def places_nearby(
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
    lat: float = Query(37.5665, description="기준 위도(기본: 서울시청)"),
    lng: float = Query(126.9780, description="기준 경도"),
    category: str | None = Query(None, description="medical|fitness|healthy_food|pharmacy"),
    radius_m: int = Query(3000, ge=100, le=20000),
) -> list[PlaceOut]:
    # TODO(카카오맵): 실연동 시 여기서 _search_kakao(lat,lng,category) 호출 후
    #                 결과를 PlaceOut 으로 변환. 현재는 DB 시드 데이터 사용.
    q = select(Place)
    if category:
        q = q.where(Place.category == category)
    rows = db.scalars(q).all()

    out: list[PlaceOut] = []
    for r in rows:
        if r.lat is None or r.lng is None:
            continue
        dist = _haversine_m(lat, lng, r.lat, r.lng)
        if dist > radius_m:
            continue
        out.append(PlaceOut(
            id=r.id, name=r.name, category=r.category, address=r.address,
            distance_meters=dist, lat=r.lat, lng=r.lng,
        ))
    out.sort(key=lambda p: p.distance_meters)
    return out
