# Container image that runs your code
FROM amazon/aws-cli

RUN yum update
RUN yum –y install python3
RUN yum –y install python3-pip
RUN pip3 –V

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

ENTRYPOINT ["/entrypoint.sh"]
