#!/bin/bash

echo "🚀 Setting up AWS and Backend Credentials"
echo "========================================="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed."
    echo "Please install it: brew install awscli"
    exit 1
fi

echo "📋 You need to provide the following AWS credentials:"
echo "   1. AWS Access Key ID"
echo "   2. AWS Secret Access Key"
echo "   3. AWS Region (default: us-east-1)"
echo ""
echo "🔑 You can get these from:"
echo "   - AWS Console > IAM > Users > [Your User] > Security Credentials"
echo "   - Or create new Access Keys if needed"
echo ""

read -p "Enter AWS Access Key ID: " aws_access_key
read -s -p "Enter AWS Secret Access Key: " aws_secret_key
echo ""
read -p "Enter AWS Region [us-east-1]: " aws_region
aws_region=${aws_region:-us-east-1}

echo ""
echo "🔧 Configuring AWS CLI..."
aws configure set aws_access_key_id "$aws_access_key"
aws configure set aws_secret_access_key "$aws_secret_key" 
aws configure set region "$aws_region"

echo "✅ Testing AWS connection..."
if aws sts get-caller-identity &> /dev/null; then
    echo "✅ AWS credentials configured successfully!"
else
    echo "❌ AWS credentials test failed. Please check your keys."
    exit 1
fi

echo ""
echo "📝 Updating backend .env file..."

# Update the .env file
env_file="/Users/havel/Desktop/mercle-app/fastapi-backend/.env"

# Use sed to update the values
sed -i "" "s/AWS_ACCESS_KEY_ID=.*/AWS_ACCESS_KEY_ID=$aws_access_key/" "$env_file"
sed -i "" "s/AWS_SECRET_ACCESS_KEY=.*/AWS_SECRET_ACCESS_KEY=$aws_secret_key/" "$env_file"
sed -i "" "s/AWS_REGION=.*/AWS_REGION=$aws_region/" "$env_file"

echo "✅ Backend .env file updated!"

echo ""
echo "🎯 Next steps:"
echo "   1. Verify AWS Rekognition permissions in AWS Console"
echo "   2. Create or verify S3 bucket exists"
echo "   3. Run the backend: cd fastapi-backend && python -m uvicorn app.main:app --reload"
echo "   4. Switch Flutter to real endpoints"

echo ""
echo "🔍 Checking AWS permissions..."
echo "Testing S3 access..."
aws s3 ls &> /dev/null && echo "✅ S3 access OK" || echo "⚠️  S3 access may be limited"

echo "Testing Rekognition access..."
aws rekognition list-collections --region "$aws_region" &> /dev/null && echo "✅ Rekognition access OK" || echo "⚠️  Rekognition access may be limited"

echo ""
echo "✅ Setup completed!"
