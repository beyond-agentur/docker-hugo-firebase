FROM node:9-alpine

RUN apk update && \
    apk upgrade && \
    apk add --update ca-certificates && \
    apk add chromium --update-cache --repository http://nl.alpinelinux.org/alpine/edge/community && \
    rm -rf /var/cache/apk/*

# Set environment variable
ARG RUN_AS=node
ARG HUGO_VERSION=0.39
ARG HUGO_BINARY="hugo_${HUGO_VERSION}_Linux-64bit"

RUN apk update && \
    apk upgrade && \
    apk add --no-cache tzdata && \
    rm -rf /var/cache/apk/*

RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

RUN apk add --no-cache python py-pygments && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache

# Download and install hugo
RUN mkdir /usr/local/hugo

ADD https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY}.tar.gz \
    /usr/local/hugo/

RUN tar xzf /usr/local/hugo/${HUGO_BINARY}.tar.gz -C /usr/local/hugo/ \
    && ln -s /usr/local/hugo/hugo /usr/local/bin/hugo \
    && rm /usr/local/hugo/${HUGO_BINARY}.tar.gz

RUN npm install -g gulp hugulp firebase-tools

RUN mkdir /app && mkdir /app/functions

COPY package.json /app/

COPY functions/package.json /app/functions

WORKDIR /app

RUN npm i
RUN cd functions && npm i
