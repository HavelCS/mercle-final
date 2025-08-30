from motor.motor_asyncio import AsyncIOMotorClient
from ..core.config import settings

_client: AsyncIOMotorClient | None = None

def get_client() -> AsyncIOMotorClient:
    global _client
    if _client is None:
        _client = AsyncIOMotorClient(settings.MONGODB_URI)
    return _client

def db():
    return get_client()[settings.MONGODB_DB]
