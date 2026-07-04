"""
DB 초기화 + 데모 데이터 시드.

프론트 계약상 사용자 id 는 문자열. 데모 사용자 'user-demo' 를 시드합니다
(프론트 mock 의 _usersMe 가 'user-demo' / '김민수' / 'minsu@oncare.com' 를 쓰므로 호환).
이후 STEP 들에서 이 사용자에 식단/운동/건강 데이터를 붙입니다.
"""
from __future__ import annotations

from sqlalchemy import select, text
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.db.session import Base, SessionLocal, engine
from app.models import models  # noqa: F401

DEMO_USER_ID = "user-demo"


def init_db() -> None:
    settings = get_settings()

    with engine.connect() as conn:
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
        conn.commit()

    # 개발 편의: create_all(멱등). 운영은 Alembic(`alembic upgrade head`)을 정답으로 삼고
    # AUTO_CREATE_TABLES=false 로 꺼둔다.
    if settings.auto_create_tables:
        Base.metadata.create_all(bind=engine)

    if settings.seed_demo_data:
        _seed_demo_user()
        _seed_demo_places()
        _seed_demo_notifications()


def _seed_demo_user() -> None:
    db: Session = SessionLocal()
    try:
        existing = db.scalar(select(models.User).where(models.User.id == DEMO_USER_ID))
        if existing is None:
            user = models.User(
                id=DEMO_USER_ID,
                email="minsu@oncare.com",
                name="김민수",
                hashed_password="",  # 데모용. 로그인은 Stage 4.
            )
            db.add(user)
            db.commit()
    finally:
        db.close()


def _seed_demo_places() -> None:
    """서울시청 인근 데모 장소 (카카오맵 실연동 전까지 사용)."""
    db: Session = SessionLocal()
    try:
        if db.scalar(select(models.Place).limit(1)):
            return
        demo = [
            ("place-1", "온케어 내과의원", "medical", "서울 중구 세종대로 110", 37.5660, 126.9785),
            ("place-2", "헬스플러스 피트니스", "fitness", "서울 중구 을지로 50", 37.5663, 126.9820),
            ("place-3", "그린샐러드 키친", "healthy_food", "서울 중구 명동길 20", 37.5638, 126.9850),
            ("place-4", "건강약국", "pharmacy", "서울 중구 태평로 30", 37.5650, 126.9770),
            ("place-5", "한강공원 러닝트랙", "fitness", "서울 영등포구 여의동로 330", 37.5283, 126.9325),
        ]
        for pid, name, cat, addr, lat, lng in demo:
            db.add(models.Place(id=pid, name=name, category=cat, address=addr, lat=lat, lng=lng))
        db.commit()
    finally:
        db.close()


def _seed_demo_notifications() -> None:
    db: Session = SessionLocal()
    try:
        if db.scalar(select(models.Notification).where(models.Notification.user_id == DEMO_USER_ID).limit(1)):
            return
        demo = [
            ("noti-1", "오늘의 혈압을 기록해 주세요", "정기 측정 시간이에요.", "reminder"),
            ("noti-2", "이번 주 운동 목표 80% 달성!", "조금만 더 힘내세요!", "achievement"),
            ("noti-3", "건강검진 예약 안내", "다음 주 화요일 검진 일정이 있어요.", "health_check"),
        ]
        for nid, title, body, cat in demo:
            db.add(models.Notification(
                id=nid, user_id=DEMO_USER_ID, title=title, body=body, category=cat, read=False,
            ))
        db.commit()
    finally:
        db.close()
