"""
AI 코치 라우터 — 프론트 계약 정렬.

  GET /ai-coach/feedback  -> { greeting, suggestions[] }

도메인(식단/운동)별 코치를 각각 생성해 합친 결과.
STEP 7에서 내부가 RAG+LLM 으로 교체되지만 응답 형식은 동일.
"""
from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser
from app.db.session import get_db
from app.schemas.misc_api import AiCoachFeedback, ChatReply, ChatRequest
from app.services.coach.chat import answer
from app.services.coach_service import build_feedback

router = APIRouter(tags=["ai-coach"])


@router.get("/ai-coach/feedback", response_model=AiCoachFeedback)
def ai_coach_feedback(
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> AiCoachFeedback:
    return build_feedback(db, current_user.id, current_user.name)


@router.post("/ai-coach/chat", response_model=ChatReply)
def ai_coach_chat(
    payload: ChatRequest,
    current_user: CurrentUser,
    db: Annotated[Session, Depends(get_db)],
) -> ChatReply:
    """대화형 코칭: RAG 근거 기반 답변(개인/공공 격리). LLM 키 없으면 검색 기반 폴백."""
    message = payload.message.strip()
    if not message:
        raise HTTPException(status_code=400, detail="메시지가 비어 있습니다.")
    reply, sources = answer(db, current_user.id, message, payload.history)
    return ChatReply(reply=reply, sources=sources)
