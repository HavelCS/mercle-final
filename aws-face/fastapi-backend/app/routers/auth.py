from fastapi import APIRouter, HTTPException, Depends
from ..schemas.models import OTPStartReq, OTPVerifyReq, TokenRes
from ..services import twilio_verify
from ..core.jwt import create_jwt
from ..db.mongo import db
from datetime import datetime

router = APIRouter()

@router.post("/start-otp")
async def start_otp(payload: OTPStartReq):
    database = db()
    
    # Check if user already exists in main users collection
    existing_user = await database.users.find_one({"phone": payload.phone})
    
    # Check if user exists in pending registrations
    pending_user = await database.pending_registrations.find_one({"phone": payload.phone})
    
    # If user doesn't exist anywhere, verify invite code (new user)
    if not existing_user and not pending_user:
        invite_code_doc = await database.invite_codes.find_one({"code": payload.invite_code})
        if not invite_code_doc:
            raise HTTPException(status_code=400, detail="Invalid invite code")
    
    # Send OTP regardless of user status
    await twilio_verify.start_verify(payload.phone)
    return {"ok": True}

@router.post("/resend-otp")
async def resend_otp(payload: OTPStartReq):
    database = db()
    
    # Check if user already exists in main users collection
    existing_user = await database.users.find_one({"phone": payload.phone})
    
    # Check if user exists in pending registrations  
    pending_user = await database.pending_registrations.find_one({"phone": payload.phone})
    
    # If user doesn't exist anywhere, verify invite code (new user)
    if not existing_user and not pending_user:
        invite_code_doc = await database.invite_codes.find_one({"code": payload.invite_code})
        if not invite_code_doc:
            raise HTTPException(status_code=400, detail="Invalid invite code")
    
    # Resend OTP regardless of user status
    await twilio_verify.start_verify(payload.phone)
    return {"ok": True}

@router.post("/verify-otp", response_model=TokenRes)
async def verify_otp(payload: OTPVerifyReq):
    ok = await twilio_verify.check_verify(payload.phone, payload.code)
    if not ok:
        raise HTTPException(status_code=400, detail="Invalid code")
    # ensure user doc exists
    database = db()
    existing = await database.users.find_one({"phone": payload.phone})
    if not existing:
        print("user is created")
        await database.users.insert_one({
            "phone": payload.phone,
            "status": "new",
            "created_at": datetime.utcnow(),
            "last_seen": datetime.utcnow(),
            "access_count": 0,
        })
    token = create_jwt(sub=payload.phone)
    return TokenRes(access_token=token, expires_in=60*2*60) 