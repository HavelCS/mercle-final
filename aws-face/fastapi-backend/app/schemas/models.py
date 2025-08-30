from pydantic import BaseModel, Field
from typing import Optional, Any
from datetime import datetime

class User(BaseModel):
    id: Optional[str] = None
    phone: str
    uid: Optional[str] = None          
    rekognition_face_id: Optional[str] = None
    s3_key: Optional[str] = None
    liveness_score: Optional[float] = None
    status: str = "verified"  # new, pending, verified, failed
    created_at: datetime = Field(default_factory=datetime.utcnow)
    last_seen: datetime = Field(default_factory=datetime.utcnow)
    access_count: int = 0

class OTPStartReq(BaseModel):
    phone: str
    invite_code: str

class OTPVerifyReq(BaseModel):
    phone: str
    code: str

class TokenRes(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int

class CreateSessionRes(BaseModel):
    sessionId: str

class ProcessResultsReq(BaseModel):
    sessionId: str

class LivenessProcessRes(BaseModel):
    success: bool
    isNewFace: bool | None = None
    uid: Optional[str] = None
    confidence: Optional[float] = None
    livenessScore: Optional[float] = None

class PendingRegistration(BaseModel):
    phone: str
    uid: str
    rekognition_face_id: str
    s3_key: Optional[str] = None
    liveness_score: float
    status: str = "pending"  # pending, verified, failed
    job_id: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    vector_embeddings: Optional[list] = None