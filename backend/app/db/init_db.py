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
    with engine.connect() as conn:
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
        conn.commit()

    Base.metadata.create_all(bind=engine)

    if get_settings().seed_demo_data:
        _seed_demo_user()


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
