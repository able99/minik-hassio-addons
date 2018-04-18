ARG BUILD_FROM
FROM $BUILD_FROM

ENV TZ "Asia/Shanghai"
ENV LANG C.UTF-8

RUN echo 'http://mirrors.ustc.edu.cn/alpine/v3.5/main' > /etc/apk/repositories
RUN echo 'http://mirrors.ustc.edu.cn/alpine/v3.5/community' >> /etc/apk/repositories
RUN apk update
RUN apk add --no-cache python python-dev py-pip
RUN pip install bypy

COPY run.py /
RUN chmod a+x /run.py

CMD [ "python", "-u", "/run.py" ]
