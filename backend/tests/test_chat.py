"""AI 코치 챗봇 (/ai-coach/chat) — DB 필요(로컬 skip, CI 실행).

CI 엔 LLM 키가 없으므로 검색 기반 폴백 경로를 검증한다(공공 가이드라인 시드에 근거).
"""
from __future__ import annotations


def test_chat_returns_grounded_reply(client):
    r = client.post("/v1/ai-coach/chat", json={"message": "나트륨을 줄이려면 어떻게 해야 하나요?"})
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["reply"].strip()          # 답변이 비어있지 않음
    assert isinstance(body["sources"], list)


def test_chat_accepts_history(client):
    r = client.post(
        "/v1/ai-coach/chat",
        json={
            "message": "그럼 운동은 어떻게 할까요?",
            "history": [
                {"role": "user", "content": "혈압이 높아요"},
                {"role": "coach", "content": "저염 식단이 도움이 됩니다."},
            ],
        },
    )
    assert r.status_code == 200, r.text
    assert r.json()["reply"].strip()


def test_chat_empty_message_400(client):
    r = client.post("/v1/ai-coach/chat", json={"message": "   "})
    assert r.status_code == 400
