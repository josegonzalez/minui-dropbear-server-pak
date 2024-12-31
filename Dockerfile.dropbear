FROM golang:1.20.5-buster

ARG DROPBEAR_VERSION=DROPBEAR_2024.86
ENV DROPBEAR_VERSION=$DROPBEAR_VERSION

RUN git clone https://github.com/mkj/dropbear /go/src/github.com/mkj/dropbear && \
    git -C /go/src/github.com/mkj/dropbear checkout "tags/$DROPBEAR_VERSION"

WORKDIR /go/src/github.com/mkj/dropbear

ENV GOOS=linux
ENV GOARCH=arm64
ENV CGO_ENABLED=1
ENV CC=aarch64-linux-gnu-gcc

RUN apt-get update && apt-get install -y autoconf zlib1g-dev
RUN ./configure --prefix=/usr --host=aarch64-linux-gnu
RUN make PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp"

RUN apt-get update && apt-get install -y file

RUN ls -lah /go/src/github.com/mkj/dropbear
RUN file /go/src/github.com/mkj/dropbear/dropbear
