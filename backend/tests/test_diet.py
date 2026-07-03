"""식단 사진분석(/diet/analyze) — DB 필요(로컬 skip, CI 실행).

CI 엔 GEMINI_API_KEY 가 없으므로 오프라인 스텁 인식기 경로를 검증한다
(이미지 내용과 무관하게 결정론적 식단 → 공공 영양 DB 매핑 → 저장).
"""
from __future__ import annotations

_JPEG = b"\xff\xd8\xff\xe0\x00\x10JFIF fake-image-bytes"


def test_analyze_offline_saves_and_reflects_in_today(client):
    r = client.post(
        "/v1/diet/analyze",
        files={"image": ("food.jpg", _JPEG, "image/jpeg")},
        data={"meal_type": "lunch"},
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["entry_id"]
    foods = body["analysis"]["foods"]
    assert foods  # 인식된 음식이 있어야
    # 공공 영양 DB 매핑으로 신뢰 수치가 채워짐(비빔밥/김치는 시드에 존재)
    assert body["analysis"]["total_calories"] > 0
    assert any(f["source"] == "db" for f in foods)

    today = client.get("/v1/diet/days/today")
    assert today.status_code == 200
    assert today.json()["total_calories"] > 0


def test_analyze_rejects_unsupported_mime(client):
    r = client.post(
        "/v1/diet/analyze",
        files={"image": ("note.txt", b"hello", "text/plain")},
        data={"meal_type": "lunch"},
    )
    assert r.status_code == 415


def test_analyze_rejects_empty_file(client):
    r = client.post(
        "/v1/diet/analyze",
        files={"image": ("food.jpg", b"", "image/jpeg")},
        data={"meal_type": "lunch"},
    )
    assert r.status_code == 400
