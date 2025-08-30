from ..aws.rekog import rekognition, s3
from ..core.config import settings
from uuid import uuid4

async def search_existing_face(image_bytes: bytes):
    try:
        resp = rekognition.search_faces_by_image(
            CollectionId=settings.REKOG_COLLECTION_ID,
            Image={"Bytes": image_bytes},
            MaxFaces=1,
            FaceMatchThreshold=95,
        )
        matches = resp.get("FaceMatches", [])
        if matches:
            return {
                "found": True,
                "rekognition_face_id": matches[0]["Face"]["FaceId"],
                "similarity": float(matches[0]["Similarity"]),
            }
        return {"found": False}
    except rekognition.exceptions.InvalidParameterException:
        return {"found": False}

async def register_new_face(image_bytes: bytes):
    face_id = str(uuid4())
    s3_key = f"faces/{face_id}.jpg"

    if settings.S3_BUCKET_NAME:
        s3.put_object(Bucket=settings.S3_BUCKET_NAME, Key=s3_key, Body=image_bytes, ContentType="image/jpeg")
    else:
        print(f"⚠️  S3_BUCKET_NAME not set - face image not uploaded to S3: {s3_key}")

    idx = rekognition.index_faces(
        CollectionId=settings.REKOG_COLLECTION_ID,
        Image={"Bytes": image_bytes},
        ExternalImageId=face_id,
        DetectionAttributes=["DEFAULT"],
    )
    records = idx.get("FaceRecords", [])
    if not records:
        raise ValueError("No face detected")
    rekog_face_id = records[0]["Face"]["FaceId"]
    return {"face_id": face_id, "rekognition_face_id": rekog_face_id, "s3_key": s3_key}
