"""
.env 의 RECOGNIZER 로 인식기를 선택하는 팩토리.
get_recognizer("yolo") 로 강제 지정 가능(비교실험).
"""
from __future__ import annotations

from functools import lru_cache

from app.core.config import get_settings
from app.services.recognizer.base import FoodRecognizer

_REGISTRY: dict[str, type[FoodRecognizer]] = {}


def _registry() -> dict[str, type[FoodRecognizer]]:
    if not _REGISTRY:
        from app.services.recognizer.gemini import GeminiVisionRecognizer
        from app.services.recognizer.yolo import YoloPipelineRecognizer

        _REGISTRY["gemini"] = GeminiVisionRecognizer
        _REGISTRY["yolo"] = YoloPipelineRecognizer
    return _REGISTRY


@lru_cache
def _build(name: str) -> FoodRecognizer:
    reg = _registry()
    if name not in reg:
        raise ValueError(f"알 수 없는 인식 엔진: '{name}'. 사용 가능: {list(reg.keys())}")
    return reg[name]()


def get_recognizer(name: str | None = None) -> FoodRecognizer:
    engine = (name or get_settings().recognizer).lower()
    return _build(engine)
