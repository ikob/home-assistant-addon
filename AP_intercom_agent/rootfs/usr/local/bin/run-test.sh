#!/bin/sh
set -eu

: "${USERNAME:?}"
: "${PASSWORD:?}"
: "${PROXY:?}"
: "${REGISTER_URI:?}"
: "${MESSAGE_URI:?}"
: "${ENTRANCE_URI:?}"
: "${ALLOWED_CALLER:?}"

: "${ANSWER_CALLS:?}"
: "${SEND_MESSAGES:?}"

exec /usr/local/bin/intercom_agent \
  -username "${USERNAME}" \
  -password "${PASSWORD}" \
  -proxy "${PROXY}" \
  -allowed-caller "${ALLOWED_CALLER}" \
  -register-uri "${REGISTER_URI}" \
  -message-uri "${MESSAGE_URI}" \
  -entrance-uri "${ENTRANCE_URI}" \
  -answer-calls="${ANSWER_CALLS}" \
  -send-messages="${SEND_MESSAGES}"
