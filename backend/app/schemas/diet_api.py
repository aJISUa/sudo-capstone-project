"""
식단 API 응답 스키마 — 프론트 계약(_dietToday) 정렬.

GET /diet/days/today 응답:
  { entries[], total_calories, total_sodium_mg, total_sugar_g, macros, ai_coach_message }
entries[]: { id, meal_type, time_label, foods[], total_calories, sodium_mg, sugar_g }
"""
from __future__ import annotations

from typing import Any
from pydantic import BaseModel

from app.schemas.diet import DietAnalysis


class Macros(BaseModel):
    carbs_pct: int = 50
    protein_pct: int = 30
    fat_pct: int = 20


class DietEntryOut(BaseModel):
    id: str
    meal_type: str
    time_label: str
    foods: list[dict[str, Any]]  # [{name, calories}]
    total_calories: int
    sodium_mg: int
    sugar_g: int


class DietEntryUpdate(BaseModel):
    """PUT /diet/entries/{id} — 끼니 분류/시간 수정(부분 저장). 음식/영양은
    분석 결과라 여기서 바꾸지 않는다."""
    meal_type: str | None = None
    time_label: str | None = None


class DietTodayResponse(BaseModel):
    entries: list[DietEntryOut]
    total_calories: int
    total_sodium_mg: int
    total_sugar_g: int
    macros: Macros
    ai_coach_message: str


class DietAnalyzeResponse(BaseModel):
    """POST /diet/analyze 응답: 저장된 entry id + 분석 결과."""
    entry_id: str
    analysis: DietAnalysis
