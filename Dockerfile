FROM node:9-alpine

RUN apk update && apk upgrade && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
    apk add --no-cache \
      chromium@edge \
      nss@edge

# Puppeteer v0.13.0 works with Chromium 64.
RUN yarn add puppeteer@0.13.0

RUN mkdir /app && mkdir /app/functions

# Add user so we don't need --no-sandbox.
RUN addgroup -S pptruser && adduser -S -g pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

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

USER pptruser

COPY package.json /app/

COPY functions/package.json /app/functions

RUN chown -R pptruser:pptruser /app

WORKDIR /app

RUN npm i
RUN cd functions && npm i
