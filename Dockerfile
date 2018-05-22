FROM node:7.9.0-alpine

# Set environment variable
ARG RUN_AS=node
ARG HUGO_VERSION=0.39
ARG HUGO_BINARY="hugo_${HUGO_VERSION}_Linux-64bit"

RUN apk add --no-cache tzdata

RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

RUN apk update && apk add py-pygments chromium && rm -rf /var/cache/apk/*
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
