#!/bin/sh -l

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
export AWS_DEFAULT_REGION=$3
aws \
	cloudformation deploy --stack-name test-stack \
	--template-file cloudformation.yml \

