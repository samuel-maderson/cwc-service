import jwt
import os
from datetime import datetime, timedelta
from functools import wraps
from flask import request, jsonify, current_app
from app.secrets import get_secret

def get_api_users():
    """Get API users from Secrets Manager"""
    secret_name = os.getenv('API_AUTH_SECRET_NAME')
    if not secret_name:
        raise ValueError('API_AUTH_SECRET_NAME environment variable not set')
    
    secret = get_secret(secret_name, os.getenv('AWS_REGION', 'us-east-1'))
    return {
        secret['admin_username']: secret['admin_password'],
        secret['user_username']: secret['user_password']
    }

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({'error': 'Token missing'}), 401
            
        if not token.startswith('Bearer '):
            return jsonify({'error': 'Invalid token format'}), 401
            
        try:
            token = token[7:]  # Remove 'Bearer ' prefix
            data = jwt.decode(token, current_app.config['SECRET_KEY'], algorithms=['HS256'])
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401
            
        return f(*args, **kwargs)
    return decorated

def generate_token(username):
    payload = {
        'username': username,
        'exp': datetime.utcnow() + timedelta(hours=24)
    }
    return jwt.encode(payload, current_app.config['SECRET_KEY'], algorithm='HS256')

def authenticate_user(username, password):
    users = get_api_users()
    return users.get(username) == password