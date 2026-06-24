"""모든 식단 인식 엔진이 따르는 공통 인터페이스."""
from __future__ import annotations

from abc import ABC, abstractmethod

from app.schemas.diet import DietAnalysis


class FoodRecognizer(ABC):
    name: str = "base"

    @abstractmethod
    async def recognize(self, image_bytes: bytes, mime_type: str) -> DietAnalysis:
        raise NotImplementedError
