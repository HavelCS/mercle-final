from ..aws.rekog import rekognition, s3
from ..core.config import settings

def create_liveness_session():
    params = {}
    if settings.S3_BUCKET_NAME:
        params["Settings"] = {"OutputConfig": {"S3Bucket": settings.S3_BUCKET_NAME}}
    resp = rekognition.create_face_liveness_session(**params)
    return resp["SessionId"]

def get_liveness_results(session_id: str):
    resp = rekognition.get_face_liveness_session_results(SessionId=session_id)
    ref = resp.get("ReferenceImage", {})
    bytes_ = None
    s3obj = None
    if isinstance(ref, dict):
        bytes_ = ref.get("Bytes")
        s3obj = ref.get("S3Object")
    return {
        "confidence": float(resp.get("Confidence", 0.0)),
        "is_live": float(resp.get("Confidence", 0.0)) > 80.0,
        "reference_bytes": bytes_,
        "s3_object": s3obj,
        "raw": resp,
    }

def download_from_s3(s3_object: dict) -> bytes:
    bucket = s3_object.get("Bucket")
    key = s3_object.get("Name")
    obj = s3.get_object(Bucket=bucket, Key=key)
    return obj["Body"].read()