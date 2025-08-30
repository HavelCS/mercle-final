import asyncio
import logging
from datetime import datetime
from ..db.mongo import db
from ..services.face_matching import get_face_matching_result

logger = logging.getLogger(__name__)

async def process_pending_face_matching_jobs():
    """Background job to check pending face matching jobs every 2 minutes"""
    logger.info("Starting background job for pending face matching")
    
    while True:
        try:
            database = db()
            
            # Find all pending jobs
            pending_jobs = await database.pending_registrations.find(
                {"status": "pending", "job_id": {"$exists": True, "$ne": None}}
            ).to_list(length=None)
            
            logger.info(f"Found {len(pending_jobs)} pending face matching jobs")
            
            for job in pending_jobs:
                try:
                    phone = job["phone"]
                    job_id = job["job_id"]
                    
                    # Get result from face matching service
                    result = await get_face_matching_result(job_id)
                    
                    if result.get("status") == "COMPLETED":
                        logger.info(f"Job {job_id} completed for phone {phone}")
                        
                        # Update status to verified in pending_registrations
                        await database.pending_registrations.update_one(
                            {"phone": phone, "job_id": job_id},
                            {"$set": {"status": "verified"}}
                        )
                        
                        # Move to main users collection
                        user_data = {
                            "phone": phone,
                            "uid": job["uid"],
                            "rekognition_face_id": job["rekognition_face_id"],
                            "liveness_score": job["liveness_score"],
                            "status": "verified",
                            "last_seen": datetime.utcnow(),
                            "access_count": 1
                        }
                        
                        # Add s3_key if it exists
                        if job.get("s3_key"):
                            user_data["s3_key"] = job["s3_key"]
                        
                        # Add created_at if it exists, otherwise use current time
                        if job.get("created_at"):
                            user_data["created_at"] = job["created_at"]
                        else:
                            user_data["created_at"] = datetime.utcnow()
                        
                        await database.users.update_one(
                            {"phone": phone},
                            {"$set": user_data},
                            upsert=True
                        )
                        
                        logger.info(f"Successfully verified and moved user {phone} to main collection")
                        
                    elif result.get("status") in ["PENDING"]:
                        # Still pending, continue waiting
                        logger.info(f"Job {job_id} still pending for phone {phone}")
                        
                    elif result.get("status") in ["NOT_FOUND"]:
                        # Job not found, mark as failed
                        logger.warning(f"Job {job_id} not found for phone {phone}, marking as failed")
                        await database.pending_registrations.update_one(
                            {"phone": phone, "job_id": job_id},
                            {"$set": {"status": "failed"}}
                        )
                        
                except Exception as e:
                    logger.error(f"Error processing job {job.get('job_id', 'unknown')} for phone {job.get('phone', 'unknown')}: {str(e)}")
                    continue
            
        except Exception as e:
            logger.error(f"Error in background job processing: {str(e)}")
        
        # Wait 2 minutes before next check
        await asyncio.sleep(120)

async def start_background_jobs():
    """Start all background jobs"""
    logger.info("Starting background jobs")
    
    # Create tasks for background jobs
    tasks = [
        asyncio.create_task(process_pending_face_matching_jobs())
    ]
    
    # Run all tasks concurrently
    await asyncio.gather(*tasks)