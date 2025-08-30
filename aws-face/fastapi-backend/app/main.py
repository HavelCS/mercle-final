from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import auth, liveness, users
from .core.config import settings
from .services.background_jobs import start_background_jobs
import asyncio
import logging

logger = logging.getLogger(__name__)

app = FastAPI(title="Face Liveness API")

@app.get("/")
async def root():
    """Health check endpoint"""
    return {"message": "Face Liveness API is running", "status": "healthy"}

@app.on_event("startup")
async def startup_event():
    """Start background jobs when the application starts"""
    logger.info("Starting background jobs...")
    # Start background jobs in a separate task
    asyncio.create_task(start_background_jobs())

origins = [o.strip() for o in settings.CORS_ORIGINS.split(",") if o.strip()]
allow_credentials = not (len(origins) == 1 and origins[0] == "*")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins if allow_credentials else ["*"],
    allow_credentials=allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-New-Access-Token"], 
)

app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(liveness.router, prefix="/api/faces", tags=["liveness"])
app.include_router(users.router, prefix="/api/users", tags=["users"])