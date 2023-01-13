# TODO: refactor entrypoint to Go, build it statically and just use FROM scratch...
FROM python:3.9-slim

ARG BIN_VERSION=2.8.6

RUN apt update \
 && apt install -y wget unzip \
 && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/projectdiscovery/nuclei/releases/download/v${BIN_VERSION}/nuclei_${BIN_VERSION}_linux_amd64.zip \
 && unzip nuclei_${BIN_VERSION}_linux_amd64.zip \
 && rm nuclei_${BIN_VERSION}_linux_amd64.zip \
 && chmod a+x nuclei \
 && mv nuclei /usr/bin/

RUN nuclei -ut

COPY ppbtemplates /root/nuclei-templates/ppb

VOLUME /input
VOLUME /output

ADD entrypoint.py /

ENTRYPOINT ["python3", "-u", "/entrypoint.py"]
