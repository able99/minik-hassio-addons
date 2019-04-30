ARG BUILD_FROM
FROM $BUILD_FROM

ENV TZ "Asia/Shanghai"
ENV LANG C.UTF-8

RUN apk update
RUN apk add --no-cache jq samba-server samba-common-tools

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
