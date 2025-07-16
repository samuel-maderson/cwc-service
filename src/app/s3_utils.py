import os
import boto3
import uuid
from werkzeug.utils import secure_filename

def upload_image_to_s3(file, bucket_name):
    """Upload image file to S3 and return the URL"""
    try:
        s3_client = boto3.client('s3', region_name=os.getenv('AWS_REGION', 'us-east-1'))
        
        # Generate unique filename
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4()}_{filename}"
        
        # Upload file
        s3_client.upload_fileobj(
            file,
            bucket_name,
            f"vehicles/{unique_filename}",
            ExtraArgs={'ContentType': file.content_type}
        )
        
        # Return S3 URL
        return f"https://{bucket_name}.s3.amazonaws.com/vehicles/{unique_filename}"
        
    except Exception as e:
        print(f"ERROR: S3 upload failed: {str(e)}")
        raise e