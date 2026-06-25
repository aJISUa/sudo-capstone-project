"""코치 LLM 공통 인터페이스. 토큰 사용량 기록(모델 비교용)."""
from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field


@dataclass
class LLMResult:
    text: str
    model: str
    prompt_tokens: int = 0
    completion_tokens: int = 0
    total_tokens: int = 0
    extra: dict = field(default_factory=dict)


class CoachLLM(ABC):
    name: str = "base"

    @abstractmethod
    def generate(self, system_prompt: str, user_prompt: str) -> LLMResult:
        raise NotImplementedError
