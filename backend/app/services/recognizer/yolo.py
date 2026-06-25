"""
YOLO + 영양 DB 2단계 파이프라인 (스텁).

비교실험 단계에서 채웁니다:
  1) YOLOv8 음식 탐지
  2) 공공데이터 식품영양성분 DB 매핑 (나트륨·당류 포함)
  3) 동일한 DietAnalysis(engine='yolo') 반환
"""
from __future__ import annotations

from app.schemas.diet import DietAnalysis
from app.services.recognizer.base import FoodRecognizer


class YoloPipelineRecognizer(FoodRecognizer):
    name = "yolo"

    async def recognize(self, image_bytes: bytes, mime_type: str) -> DietAnalysis:
        raise NotImplementedError(
            "YOLO 파이프라인은 비교실험 단계에서 구현합니다. "
            "반환 형식은 반드시 DietAnalysis(engine='yolo', ...) 여야 합니다."
        )
