"""오프라인 스텁 인식기 — Gemini 키 없이도 /diet/analyze 데모가 동작.

실제 이미지를 보지 않고 결정론적 예시 식단을 반환한다. 엔드포인트의 enrich_analysis 가
공공 식품영양성분 DB로 신뢰 수치를 채우므로, 키 없는 데모에서도 그럴듯한 영양 결과가 나온다.
운영에서 GEMINI_API_KEY 가 있으면 factory 가 실제 Gemini 인식기를 쓴다.
"""
from __future__ import annotations

from app.schemas.diet import DietAnalysis, RecognizedFood
from app.services.recognizer.base import FoodRecognizer


class StubFoodRecognizer(FoodRecognizer):
    name = "stub"

    async def recognize(self, image_bytes: bytes, mime_type: str) -> DietAnalysis:  # noqa: ARG002
        foods = [
            RecognizedFood(name="비빔밥", calories=600, sodium_mg=900, sugar_g=8, confidence=0.9),
            RecognizedFood(name="김치", calories=15, sodium_mg=300, sugar_g=1, confidence=0.8),
        ]
        return DietAnalysis(
            engine=self.name,
            foods=foods,
            coach_comment="비빔밥은 채소가 풍부해 좋아요. 다만 나트륨이 다소 높으니 "
            "고추장·간장을 조금 줄이면 혈압 관리에 더 도움이 됩니다.",
        ).compute_totals()
