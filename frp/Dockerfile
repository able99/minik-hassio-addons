ARG BUILD_FROM
FROM $BUILD_FROM
ARG BUILD_ARCH
ARG FRP_VERSION=0.16.1
ARG FRP_ARCH="arm"

ENV TZ "Asia/Shanghai"
ENV LANG C.UTF-8

RUN echo 'http://mirrors.ustc.edu.cn/alpine/v3.5/main' > /etc/apk/repositories
RUN echo 'http://mirrors.ustc.edu.cn/alpine/v3.5/community' >> /etc/apk/repositories
RUN apk update && apk add --no-cache jq wget curl

RUN set -x 
RUN if [ $BUILD_ARCH == "armhf" ]; then FRP_ARCH="arm"; fi 
RUN if [ $BUILD_ARCH == "amd64" ]; then FRP_ARCH="amd64"; fi 
RUN if [ $BUILD_ARCH == "i386" ]; then FRP_ARCH="386"; fi 

RUN wget -T 120 -t 2 https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz \
    && tar -zxf frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz \
    && mv frp_${FRP_VERSION}_linux_${FRP_ARCH} /frp 

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
