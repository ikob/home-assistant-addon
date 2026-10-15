# syntax=docker/dockerfile:1
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026, Katsushi Kobayashi

ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest

# ---- build stage ----
FROM golang:1.23-alpine AS builder
RUN apk add --no-cache git ca-certificates

WORKDIR /src

ARG BUILD_VERSION
RUN echo "Build version: ${BUILD_VERSION}"

ARG REPO_URL=https://github.com/ikob/AP_intercom_agent.git
ARG REPO_REF=0cf753487fe2b6c26110a4a1ad0fd5d6c298d3ff

RUN git clone "${REPO_URL}" . \
 && git checkout --detach "${REPO_REF}" \
 && test "$(git rev-parse HEAD)" = "${REPO_REF}"
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 \
    go build -trimpath -ldflags="-s -w" -o /out/intercom_agent .

ARG GO2RTC_VERSION=1.9.14
ARG GO2RTC_SHA256=359fabade8a7a51e81a55fe6df6b0ef81764a5e1d63179577534eaaa71904b50
RUN wget -qO /out/go2rtc \
      "https://github.com/AlexxIT/go2rtc/releases/download/v${GO2RTC_VERSION}/go2rtc_linux_arm64" \
 && echo "${GO2RTC_SHA256}  /out/go2rtc" | sha256sum -c - \
 && chmod 0755 /out/go2rtc \
 && wget -qO /out/go2rtc-LICENSE \
      "https://raw.githubusercontent.com/AlexxIT/go2rtc/v${GO2RTC_VERSION}/LICENSE"

# ---- runtime stage ----
FROM ${BUILD_FROM}

ARG BUILD_VERSION
ENV ADDON_VERSION="${BUILD_VERSION}"

RUN apk add --no-cache ca-certificates ffmpeg
COPY --from=builder /out/intercom_agent /usr/local/bin/intercom_agent
COPY --from=builder /out/go2rtc /usr/local/bin/go2rtc
COPY --from=builder /out/go2rtc-LICENSE /usr/share/licenses/go2rtc/LICENSE
COPY --from=builder /src/go2rtc.yaml /etc/go2rtc.yaml
COPY rootfs/ /

RUN if [ -f /etc/services.d/intercom_agent/run ]; then chmod +x /etc/services.d/intercom_agent/run; fi \
 && if [ -f /etc/services.d/go2rtc/run ]; then chmod +x /etc/services.d/go2rtc/run; fi \
 && if [ -f /usr/local/bin/run-test.sh ]; then chmod +x /usr/local/bin/run-test.sh; fi
