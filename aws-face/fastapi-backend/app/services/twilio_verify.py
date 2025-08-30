import httpx
from ..core.config import settings

BASE = "https://verify.twilio.com/v2/Services"

async def start_verify(phone: str) -> None:
    url = f"{BASE}/{settings.TWILIO_VERIFY_SERVICE_SID}/Verifications"
    async with httpx.AsyncClient(auth=(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)) as c:
        r = await c.post(url, data={"To": phone, "Channel": "sms"})
        r.raise_for_status()

async def check_verify(phone: str, code: str) -> bool:
    url = f"{BASE}/{settings.TWILIO_VERIFY_SERVICE_SID}/VerificationCheck"
    async with httpx.AsyncClient(auth=(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)) as c:
        r = await c.post(url, data={"To": phone, "Code": code})
        r.raise_for_status()
        data = r.json()
        return data.get("status") == "approved"
