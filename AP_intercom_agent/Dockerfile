# syntax=docker/dockerfile:1

ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest

# ---- build stage ----
FROM golang:1.23-alpine AS builder
RUN apk add --no-cache git ca-certificates

WORKDIR /src

ARG BUILD_VERSION
RUN echo "Build version: ${BUILD_VERSION}"

ARG REPO_URL=https://github.com/ikob/AP_intercom_agent.git
ARG REPO_REF=main

RUN git clone --depth 1 --branch "${REPO_REF}" "${REPO_URL}" .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 \
    go build -trimpath -ldflags="-s -w" -o /out/intercom_agent .

# ---- runtime stage ----
FROM ${BUILD_FROM}

RUN apk add --no-cache ca-certificates
COPY --from=builder /out/intercom_agent /usr/local/bin/intercom_agent
COPY rootfs/ /

RUN if [ -f /etc/services.d/intercom_agent/run ]; then chmod +x /etc/services.d/intercom_agent/run; fi \
 && if [ -f /usr/local/bin/run-test.sh ]; then chmod +x /usr/local/bin/run-test.sh; fi
