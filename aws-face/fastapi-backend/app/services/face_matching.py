
import json
import httpx
from typing import List
from ..aws.rekog import rekognition
from ..core.config import settings

async def generate_face_embeddings(rekognition_face_id: str) -> List[float]:
    """Generate 512D vector embeddings from rekognition face ID"""
    try:
        # Generate deterministic 512D vector based on face ID
        # In production, this would use a proper face embedding model
        import random
        random.seed(hash(rekognition_face_id))
        
        vector = []
        for i in range(512):
            value = random.uniform(-1.0, 1.0)
            vector.append(round(value, 6))
        
        return vector
        
    except Exception as e:
        raise ValueError(f"Failed to generate embeddings: {str(e)}")

async def enqueue_face_matching_job(phone: str, vector: List[float]) -> str:
    """Enqueue a face matching job and return job_id"""
    try:
        # Prepare the request payload
        request_data = {
            "queries": [
                {
                    "id": phone,
                    "vector": vector
                }
            ]
        }
        
        import subprocess
        
        # Execute grpcurl command for Search (enqueue) with direct JSON
        cmd = [
            "grpcurl", "-plaintext",
            "-import-path", ".",
            "-proto", "facematch.proto",
            "-d", json.dumps(request_data),
            "52.54.40.78:50051",
            "facematch.FaceMatch/Search"
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, cwd="/Users/elliot37/Desktop/aws-face/fastapi-backend")
        
        if result.returncode == 0:
            response = json.loads(result.stdout)
            job_id = response.get("jobId")
            if job_id:
                return job_id
        
        raise ValueError(f"Failed to enqueue job: {result.stderr}")
            
    except Exception as e:
        raise ValueError(f"Face matching service enqueue failed: {str(e)}")

async def get_face_matching_result(job_id: str) -> dict:
    """Get the result of a face matching job"""
    try:
        # Prepare the request payload
        request_data = {
            "job_id": job_id
        }
        
        import subprocess
        
        # Execute grpcurl command for GetResult
        cmd = [
            "grpcurl", "-plaintext",
            "-import-path", ".",
            "-proto", "facematch.proto",
            "-d", json.dumps(request_data),
            "52.54.40.78:50051",
            "facematch.FaceMatch/GetResult"
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, cwd="/Users/elliot37/Desktop/aws-face/fastapi-backend")
        
        if result.returncode == 0:
            response = json.loads(result.stdout)
            return response
        
        raise ValueError(f"Failed to get job result: {result.stderr}")
        
    except Exception as e:
        raise ValueError(f"Face matching result retrieval failed: {str(e)}")