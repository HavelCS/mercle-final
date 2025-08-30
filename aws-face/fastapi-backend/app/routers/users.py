from fastapi import APIRouter, Depends, HTTPException, Header, Response
from ..db.mongo import db
from ..core.jwt import decode_jwt, maybe_issue_rolling_token

router = APIRouter()

def get_current_phone(
    response: Response,
    authorization: str | None = Header(default=None),
):
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")
    token = authorization.split()[1]
    try:
        payload = decode_jwt(token)
        sub = payload["sub"]
      
        new_token = maybe_issue_rolling_token(sub, payload)
        if new_token:
            response.headers["X-New-Access-Token"] = new_token
        return sub
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

@router.get("/me")
async def me(phone: str = Depends(get_current_phone)):
    database = db()
    
    # First check main users collection
    user = await database.users.find_one({"phone": phone}, {"_id": 0})
    if user:
        # Ensure status field exists (for backward compatibility)
        if "status" not in user:
            user["status"] = "verified" if user.get("uid") else "new"
        return user
    
    # If not found, check pending registrations
    pending_user = await database.pending_registrations.find_one({"phone": phone}, {"_id": 0})
    if pending_user:
        return {
            "phone": pending_user["phone"],
            "status": pending_user["status"],  # pending, verified, failed
            "uid": None,  # Not yet verified
            "pending": True  # Flag to indicate this is from pending collection
        }
    
    # If user not found in either collection, they haven't done face verification yet
    return {
        "phone": phone,
        "status": "new",
        "uid": None,
        "pending": False
    }