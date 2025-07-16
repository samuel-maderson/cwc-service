#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <encryption_key>"
    echo "Example: $0 'your-encryption-key'"
    exit 1
fi

ENCRYPTION_KEY="$1"

echo "Decrypting API auth secrets..."

# Decrypt main.tf for api_auth module
if [ -f "infrastructure/modules/api_auth/main.tf.enc" ]; then
    openssl enc -aes-256-cbc -d -salt -in infrastructure/modules/api_auth/main.tf.enc -out infrastructure/modules/api_auth/main.tf -k "$ENCRYPTION_KEY"
    echo "API auth secrets decrypted successfully"
else
    echo "Encrypted file not found: infrastructure/modules/api_auth/main.tf.enc"
    exit 1
fi