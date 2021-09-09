# Container image that runs your code
FROM amazon/aws-cli

RUN yum update -y \
  && yum install -y amazon-linux-extras \
  && yum clean all

RUN amazon-linux-extras | grep -i python
RUN amazon-linux-extras enable python3.8
RUN yum install -y python3.8 \
    && yum install -y python3-pip

ADD entrypoint.sh /entrypoint.sh
ADD cloudformation.yml /cloudformation.yml

WORKDIR /lambda

ADD requirements.txt /tmp
RUN pip3 install --quiet -t /lambda -r /tmp/requirements.txt

ADD src/ /lambda/
RUN python -m compileall -q /lambda

RUN find /lambda -type d | xargs -I {} chmod ugo+rx "{}" && \
    find /lambda -type f | xargs -I {} chmod ugo+r "{}"


ARG ZIPFILE=lambda.zip
RUN zip --quiet -9r /${ZIPFILE}  .

ENTRYPOINT ["/entrypoint.sh"]
