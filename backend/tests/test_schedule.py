"""일정 조회(월/일)/생성 — DB 필요(로컬 skip, CI 실행).

schedule 라우터는 데모 폴백(CurrentUser)을 쓰므로 무인증으로 데모 사용자에
붙는다. 공유 사용자라 먼 미래(2031)의 고유 날짜로 격리해 검증한다.
"""
from __future__ import annotations


def _create(client, *, date: str, title: str) -> dict:
    return client.post(
        "/v1/schedule/events",
        json={"date": date, "title": title, "category": "hospital"},
    ).json()


def test_month_filter_returns_events_in_that_month(client):
    a = _create(client, date="2031-03-05", title="검진 A")
    b = _create(client, date="2031-03-20", title="검진 B")
    _create(client, date="2031-04-01", title="다른 달")

    res = client.get("/v1/schedule/events", params={"month": "2031-03"})
    assert res.status_code == 200
    ids = {r["id"] for r in res.json()}
    assert a["id"] in ids
    assert b["id"] in ids
    titles = {r["title"] for r in res.json()}
    assert "다른 달" not in titles


def test_date_filter_still_works(client):
    e = _create(client, date="2031-05-09", title="단일 날짜")
    res = client.get("/v1/schedule/events", params={"date": "2031-05-09"})
    ids = {r["id"] for r in res.json()}
    assert e["id"] in ids
