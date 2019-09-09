FROM golang:alpine
LABEL maintainer.name="bauidch"

ENV TANIA_VERSION 1.7.1

# hadolint ignore=DL3018
RUN apk add --no-cache \
        bash \
        unzip \
        git \
        curl \
        gcc \
        g++ \
        musl-dev \
        npm && \
    rm -f /var/cache/apk/*

WORKDIR $GOPATH/src/github.com/Tanibox/tania-core
# hadolint ignore=DL3003
RUN git clone https://github.com/Tanibox/tania-core.git ./ && \
    git checkout tags/${TANIA_VERSION} -b v${TANIA_VERSION} && \
    mv conf.json.example conf.json && \
    go get && \
    npm install && \
    npm run prod && \
    go build && \
    ls -lha

ENTRYPOINT ["tania-core"]
