from flask import Blueprint, jsonify
import time

health_bp = Blueprint('health', __name__)

@health_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for ALB"""
    return jsonify({
        'status': 'healthy',
        'timestamp': int(time.time()),
        'service': 'cwc-vehicle-catalog'
    }), 200

@health_bp.route('/health/ready', methods=['GET'])
def readiness_check():
    """Readiness check endpoint"""
    return jsonify({
        'status': 'ready',
        'timestamp': int(time.time())
    }), 200