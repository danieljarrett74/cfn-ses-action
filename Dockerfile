# Container image that runs your code
FROM amazon/aws-cli

# Copies your code file from your action repository to the filesystem path `/` of the container
ADD entrypoint.sh /entrypoint.sh
ADD cloudformation.yml /cloudformation.yml


# RUN export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
#  && export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
#  && export AWS_DEFAULT_REGION=us-west-2

# aws configure
# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
