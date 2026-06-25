"""
AI 코치 라우터 — 프론트 계약 정렬.

  GET /ai-coach/feedback  -> { greeting, suggestions[] }

도메인(식단/운동)별 코치를 각각 생성해 합친 결과.
STEP 7에서 내부가 RAG+LLM 으로 교체되지만 응답 형식은 동일.
"""
from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser
from app.db.session import get_db
from app.schemas.misc_api import AiCoachFeedback
from app.services.coach_service import build_feedback

router = APIRouter(tags=["ai-coach"])


@router.get("/ai-coach/feedback", response_model=AiCoachFeedback)
def ai_coach_feedback(
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> AiCoachFeedback:
    return build_feedback(db, current_user.id, current_user.name)
