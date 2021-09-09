# Container image that runs your code
FROM python:3.9
RUN apt-get update && apt-get install -y zip \
    && apt-get install -y awscli

ADD entrypoint.sh /entrypoint.sh
ADD cloudformation.yml /cloudformation.yml

WORKDIR /lambda

ADD requirements.txt /tmp
RUN pip install --quiet -t /lambda -r /tmp/requirements.txt

ADD src/ /lambda/
RUN python -m compileall -q /lambda

RUN find /lambda -type d | xargs -I {} chmod ugo+rx "{}" && \
    find /lambda -type f | xargs -I {} chmod ugo+r "{}"


ARG ZIPFILE=lambda.zip
RUN zip --quiet -9r /${ZIPFILE}  .
RUN pwd && ls

ENTRYPOINT ["/entrypoint.sh"]
