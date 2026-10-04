#!/usr/bin/with-contenv bash
set -euo pipefail

: "${SIP_USERNAME:?}"
: "${PASSWORD:?}"
: "${PROXY:?}"
: "${REGISTER_URI:?}"
: "${MESSAGE_URI:?}"
: "${ENTRANCE_URI:?}"
: "${ANSWER_CALLS:?}"
: "${SEND_MESSAGES:?}"

ALLOWED_CALLERS="${ALLOWED_CALLERS-interphone0,interphone1}"
UNLOCK_CALLERS="${UNLOCK_CALLERS-interphone0}"
JPEG_QUERY_S="${JPEG_QUERY_S:-cd188d8e518cb12ad7a644f23928f64f}"
INCOMING_JPEG_DIR="${INCOMING_JPEG_DIR:-/media/ap_intercom_agent}"
INCOMING_JPEG_MAX_FILES="${INCOMING_JPEG_MAX_FILES:-100}"

IFS=, read -r -a allowed_callers <<<"${ALLOWED_CALLERS}"
IFS=, read -r -a unlock_callers <<<"${UNLOCK_CALLERS}"

mkdir -p "${INCOMING_JPEG_DIR}"

ARGS=(
  -username "${SIP_USERNAME}"
  -password "${PASSWORD}"
  -proxy "${PROXY}"
  -register-uri "${REGISTER_URI}"
  -message-uri "${MESSAGE_URI}"
  -entrance-uri "${ENTRANCE_URI}"
  -answer-calls="${ANSWER_CALLS}"
  -send-messages="${SEND_MESSAGES}"
  -reject-code 486
  -reject-reason "Busy Here"
  -jpeg-query-s "${JPEG_QUERY_S}"
  -incoming-jpeg-dir "${INCOMING_JPEG_DIR}"
  -incoming-jpeg-max-files "${INCOMING_JPEG_MAX_FILES}"
  -unlock-caller=
)

allowed_count=0
if (( ${#allowed_callers[@]} > 0 )); then
  for caller in "${allowed_callers[@]}"; do
    [[ -n "${caller}" ]] || continue
    ARGS+=(-allowed-caller "${caller}")
    ((allowed_count += 1))
  done
fi
if (( allowed_count == 0 )); then
  echo "ALLOWED_CALLERS must contain at least one non-empty caller" >&2
  exit 2
fi

if (( ${#unlock_callers[@]} > 0 )); then
  for caller in "${unlock_callers[@]}"; do
    [[ -n "${caller}" ]] || continue
    ARGS+=(-unlock-caller "${caller}")
  done
fi

exec /usr/local/bin/intercom_agent "${ARGS[@]}"
