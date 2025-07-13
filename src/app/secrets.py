import boto3
import json
from botocore.exceptions import ClientError

def get_secret(secret_name, region_name):
    """Retrieve secret from AWS Secrets Manager"""
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    
    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])
        return secret
    except ClientError as e:
        raise e

def get_db_credentials(config):
    """Get database credentials from Secrets Manager"""
    secret = get_secret(config.SECRET_NAME, config.AWS_REGION)
    return {
        'username': secret['username'],
        'password': secret['password'],
        'host': secret.get('host', ''),
        'port': secret.get('port', 3306),
        'database': config.DATABASE_NAME
    }