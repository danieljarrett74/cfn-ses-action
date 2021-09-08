#!/bin/sh -l


export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
export AWS_DEFAULT_REGION=$3
echo "$AWS_ACCESS_KEY_ID "

aws --region us-east-1 \
	cloudformation deploy --stack-name test-stack \
	--template-file ./cloudformation.yml

