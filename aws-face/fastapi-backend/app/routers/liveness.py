from fastapi import APIRouter, Depends, HTTPException, Header, Response
from ..schemas.models import CreateSessionRes, ProcessResultsReq, LivenessProcessRes, PendingRegistration
from ..services.liveness import create_liveness_session, get_liveness_results, download_from_s3
from ..services.face_registry import search_existing_face, register_new_face
from ..services.face_matching import generate_face_embeddings, enqueue_face_matching_job
from ..db.mongo import db
from ..core.jwt import decode_jwt, maybe_issue_rolling_token
from datetime import datetime

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

@router.post("/liveness/create-session", response_model=CreateSessionRes)
async def create_session(_: str = Depends(get_current_phone)):
    sid = create_liveness_session()
    return CreateSessionRes(sessionId=sid)

@router.post("/liveness/process-results", response_model=LivenessProcessRes)
async def process_results(body: ProcessResultsReq, phone: str = Depends(get_current_phone)):
    database = db()
    user = await database.users.find_one({"phone": phone})
    if user and user.get("uid"):
        return LivenessProcessRes(success=True, isNewFace=False, uid=user["uid"], livenessScore=user.get("liveness_score"))

    results = get_liveness_results(body.sessionId)
    if not results["is_live"]:
        return LivenessProcessRes(success=False, isNewFace=None, uid=None, confidence=results["confidence"], livenessScore=results["confidence"])

    img = results["reference_bytes"] or (download_from_s3(results["s3_object"]) if results["s3_object"] else None)
    if not img:
        raise HTTPException(status_code=400, detail="No reference image available")

    search = await search_existing_face(img)
    if search["found"]:
        # Check if this face is already registered to a different phone number
        existing_user = await database.users.find_one({"rekognition_face_id": search["rekognition_face_id"]})
        if existing_user and existing_user.get("phone") != phone:
            raise HTTPException(status_code=409, detail="This face is already registered to another account")
        
       
        try:
            vector_embeddings = await generate_face_embeddings(search["rekognition_face_id"])
            job_id = await enqueue_face_matching_job(phone, vector_embeddings)
            
            # Store in pending with job_id for background processing
            pending_data = {
                "phone": phone,
                "uid": search["rekognition_face_id"],
                "rekognition_face_id": search["rekognition_face_id"],
                "liveness_score": results["confidence"],
                "status": "pending",
                "job_id": job_id,
                "created_at": datetime.utcnow(),
                "vector_embeddings": vector_embeddings
            }
            await database.pending_registrations.insert_one(pending_data)
            return LivenessProcessRes(success=False, isNewFace=None, uid=None, confidence=search.get("similarity"), livenessScore=results["confidence"])
                
        except Exception as e:
            print(f"Error in face matching process: {str(e)}")
            return LivenessProcessRes(success=False, isNewFace=None, uid=None, confidence=search.get("similarity"), livenessScore=results["confidence"])


    reg = await register_new_face(img)
    

    try:
        vector_embeddings = await generate_face_embeddings(reg["rekognition_face_id"])
        job_id = await enqueue_face_matching_job(phone, vector_embeddings)
        
        # Store in pending with job_id for background processing
        pending_data = {
            "phone": phone,
            "uid": reg["face_id"],
            "rekognition_face_id": reg["rekognition_face_id"],
            "s3_key": reg.get("s3_key"),
            "liveness_score": results["confidence"],
            "status": "pending",
            "job_id": job_id,
            "created_at": datetime.utcnow(),
            "vector_embeddings": vector_embeddings
        }
        await database.pending_registrations.insert_one(pending_data)
        return LivenessProcessRes(success=False, isNewFace=True, uid=None, livenessScore=results["confidence"])
            
    except Exception as e:
        print(f"Error in face matching process for new face: {str(e)}")
        return LivenessProcessRes(success=False, isNewFace=True, uid=None, livenessScore=results["confidence"])