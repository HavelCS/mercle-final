import boto3
from ..core.config import settings

session = boto3.session.Session(
    aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
    aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
    region_name=settings.AWS_REGION,
)
rekognition = session.client("rekognition")
s3 = session.client("s3")