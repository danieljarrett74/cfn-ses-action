#!/bin/sh -l

VERSION='1234567'
S3_BUCKET='cfn-ses-provider'
STACK_NAME='cfn-ses-provider'
AWS_ACCESS_KEY_ID=$1
AWS_SECRET_ACCESS_KEY=$2
AWS_DEFAULT_REGION=$3

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION



if aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then
  echo "bucket $S3_BUCKET exists."
else
  echo "bucket $S3_BUCKET doesn't exist."
  echo "creating s3 bucket..."
  aws s3api create-bucket --bucket $S3_BUCKET
  echo "$S3_BUCKET created." 
fi


aws s3 \
    cp \
    /lambda/lambda.zip \
    s3://$(S3_BUCKET)/lambdas/lambda.zip 

aws --region us-east-1 \
	cloudformation deploy --stack-name $STACK_NAME \
	--template-file /cloudformation.yml \
    --parameter-overrides LambdaS3Bucket=$S3_BUCKET
