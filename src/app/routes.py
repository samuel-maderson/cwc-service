import os
from flask import Blueprint, jsonify, request, current_app
from app.models import db, Vehicle
from app.auth import token_required, generate_token, authenticate_user
from app.s3_utils import upload_image_to_s3

bp = Blueprint('main', __name__)

@bp.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@bp.route('/login', methods=['POST'])
def login():
    """Authenticate user and return JWT token"""
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({'error': 'Username and password required'}), 400
            
        if authenticate_user(username, password):
            token = generate_token(username)
            return jsonify({'token': token})
        else:
            return jsonify({'error': 'Invalid credentials'}), 401
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/vehicles')
@token_required
def get_vehicles():
    """Get all vehicles from catalog"""
    if current_app.config.get('DB_CONNECTION_ERROR'):
        return jsonify({
            'error': 'Database connection unavailable',
            'message': 'Please check database connectivity'
        }), 503
    
    try:
        vehicles = Vehicle.query.all()
        return jsonify({
            'vehicles': [vehicle.to_dict() for vehicle in vehicles],
            'count': len(vehicles)
        })
    except Exception as e:
        print(f"ERROR: Database query failed: {str(e)}")
        return jsonify({
            'error': 'Database query failed',
            'message': 'Unable to retrieve vehicles'
        }), 503

@bp.route('/vehicles/<int:vehicle_id>')
@token_required
def get_vehicle(vehicle_id):
    """Get specific vehicle by ID"""
    if current_app.config.get('DB_CONNECTION_ERROR'):
        return jsonify({
            'error': 'Database connection unavailable',
            'message': 'Please check database connectivity'
        }), 503
    
    try:
        vehicle = Vehicle.query.get_or_404(vehicle_id)
        return jsonify(vehicle.to_dict())
    except Exception as e:
        print(f"ERROR: Database query failed: {str(e)}")
        return jsonify({
            'error': 'Database query failed',
            'message': f'Unable to retrieve vehicle {vehicle_id}'
        }), 503

@bp.route('/vehicles', methods=['POST'])
@token_required
def create_vehicle():
    """Create new vehicle with optional image upload"""
    if current_app.config.get('DB_CONNECTION_ERROR'):
        return jsonify({
            'error': 'Database connection unavailable',
            'message': 'Please check database connectivity'
        }), 503
    
    try:
        # Handle both JSON and form data
        if request.content_type and 'multipart/form-data' in request.content_type:
            data = request.form.to_dict()
            image_file = request.files.get('image')
        else:
            data = request.get_json() or {}
            image_file = None
        
        # Upload image to S3 if provided
        image_url = None
        if image_file and image_file.filename:
            bucket_name = os.getenv('S3_BUCKET_NAME')
            if bucket_name:
                image_url = upload_image_to_s3(image_file, bucket_name)
            else:
                return jsonify({
                    'error': 'S3 bucket not configured',
                    'message': 'Image upload unavailable'
                }), 500
        
        vehicle = Vehicle(
            make=data.get('make'),
            model=data.get('model'),
            year=int(data.get('year')) if data.get('year') else None,
            price=float(data.get('price')) if data.get('price') else None,
            image_url=image_url or data.get('image_url')
        )
        db.session.add(vehicle)
        db.session.commit()
        return jsonify(vehicle.to_dict()), 201
    except Exception as e:
        print(f"ERROR: Vehicle creation failed: {str(e)}")
        db.session.rollback()
        return jsonify({
            'error': 'Vehicle creation failed',
            'message': str(e)
        }), 500

@bp.route('/vehicles/<int:vehicle_id>', methods=['PUT'])
@token_required
def update_vehicle(vehicle_id):
    """Update existing vehicle"""
    if current_app.config.get('DB_CONNECTION_ERROR'):
        return jsonify({
            'error': 'Database connection unavailable',
            'message': 'Please check database connectivity'
        }), 503
    
    try:
        vehicle = Vehicle.query.get_or_404(vehicle_id)
        data = request.get_json()
        
        for field in ['make', 'model', 'year', 'price', 'image_url']:
            if field in data:
                setattr(vehicle, field, data[field])
        
        db.session.commit()
        return jsonify(vehicle.to_dict())
    except Exception as e:
        print(f"ERROR: Database operation failed: {str(e)}")
        db.session.rollback()
        return jsonify({
            'error': 'Database operation failed',
            'message': f'Unable to update vehicle {vehicle_id}'
        }), 503

@bp.route('/vehicles/<int:vehicle_id>', methods=['DELETE'])
@token_required
def delete_vehicle(vehicle_id):
    """Delete vehicle"""
    if current_app.config.get('DB_CONNECTION_ERROR'):
        return jsonify({
            'error': 'Database connection unavailable',
            'message': 'Please check database connectivity'
        }), 503
    
    try:
        vehicle = Vehicle.query.get_or_404(vehicle_id)
        db.session.delete(vehicle)
        db.session.commit()
        return jsonify({'message': 'Vehicle deleted successfully'})
    except Exception as e:
        print(f"ERROR: Database operation failed: {str(e)}")
        db.session.rollback()
        return jsonify({
            'error': 'Database operation failed',
            'message': f'Unable to delete vehicle {vehicle_id}'
        }), 503