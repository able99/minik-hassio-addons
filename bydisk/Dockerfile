ARG BUILD_FROM
FROM $BUILD_FROM

ENV TZ "Asia/Shanghai"
ENV LANG C.UTF-8

RUN apk update
RUN apk add --no-cache python python-dev py-pip
RUN pip install bypy -i https://mirrors.aliyun.com/pypi/simple/

COPY run.py /
RUN chmod a+x /run.py

CMD [ "python", "-u", "/run.py" ]
