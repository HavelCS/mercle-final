import time, jwt
from .config import settings

ALGO = "HS256"

def create_jwt(sub: str, extra: dict | None = None) -> str:
    now = int(time.time())
    exp = now + settings.JWT_EXPIRE_MINUTES * 60
    payload = {"sub": sub, "iat": now, "exp": exp}
    if extra:
        payload.update(extra)
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=ALGO)

def decode_jwt(token: str) -> dict:
    return jwt.decode(token, settings.JWT_SECRET, algorithms=[ALGO])

def seconds_remaining(token_payload: dict) -> int:
    """Return seconds until expiry (may be negative)."""
    now = int(time.time())
    return int(token_payload.get("exp", 0)) - now

def maybe_issue_rolling_token(sub: str, payload: dict) -> str | None:
    """
    If rolling is enabled and remaining seconds <= threshold, mint a fresh token.
    Return the new token or None.
    """
    if not settings.JWT_ROLLING:
        return None
    remaining = seconds_remaining(payload)
    threshold = settings.JWT_ROLLING_THRESHOLD_MINUTES * 60
    if remaining <= threshold:
        return create_jwt(sub=sub)
    return None