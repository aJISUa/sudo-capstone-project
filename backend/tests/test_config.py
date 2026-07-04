"""설정(Settings) 검증 — DB 불필요."""
from __future__ import annotations

import pytest
from pydantic import ValidationError

from app.core.config import DEFAULT_JWT_SECRET, Settings


def test_dev_defaults():
    s = Settings(_env_file=None)
    assert s.env == "dev"
    assert s.is_prod is False
    assert s.auto_create_tables is True
    assert s.api_v1_prefix == "/v1"


def test_prod_blocks_default_secret():
    """운영에서 기본 JWT_SECRET 을 쓰면 기동이 막혀야 한다(fail-fast)."""
    with pytest.raises(ValidationError):
        Settings(_env_file=None, env="prod", jwt_secret=DEFAULT_JWT_SECRET)


def test_prod_ok_with_real_secret():
    s = Settings(_env_file=None, env="prod", jwt_secret="a-strong-random-secret-value")
    assert s.is_prod is True
