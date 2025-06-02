FROM ghcr.io/hassio-addons/ubuntu-base/aarch64:10.0.5

RUN mkdir /app
WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    make \
    iw \
    bc \
    iproute2 \
    iputils-ping \
    traceroute \
    netcat-openbsd \
    uuid-runtime \
    wireless-tools \
    ndisc6 \
    dnsutils \
    curl \
    chromium-browser \
    npm

RUN npm install puppeteer-core speedline

#RUN git clone -b HA-OS https://github.com/ikob/sindan-client.git && \
#    cd sindan-client/linux && ./install.sh

ADD sindan.conf /app/sindan.conf

ADD run.sh /run.sh
RUN chmod a+x /run.sh

ADD sindan-loop.sh /app/sindan-loop.sh
RUN chmod a+x /app/sindan-loop.sh

ADD sendlog-loop.sh /app/sendlog-loop.sh
RUN chmod a+x /app/sendlog-loop.sh

CMD [ "/run.sh" ]
