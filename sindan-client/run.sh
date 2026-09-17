#!/usr/bin/with-contenv bashio

# Operation mode: "SINDAN" (upload to the SINDAN server) or
# "perfSONAR" (push to OpenSearch). Set in the add-on options.
MODE=$(bashio::config 'mode')

export URL_CAMPAIGN=$(bashio::config 'url_campaign')
export URL_SINDAN=$(bashio::config 'url_sindan')

bashio::log.info "SINDAN add-on starting (mode=${MODE})"
bashio::log.info "URL_CAMPAIGN=${URL_CAMPAIGN}"
bashio::log.info "URL_SINDAN=${URL_SINDAN}"

# Fetch the SINDAN client from the repo.
cd /app
git clone -b opensearch --depth 1 https://github.com/ikob/sindan-client.git && \
cd sindan-client/linux
./install.sh
ln -sf /app/sindan.conf /app/sindan-client/linux/sindan.conf
cd /app

# Always run the measurement loop (it produces log/*.json).
/app/sindan-loop.sh 1>/dev/null 2>/dev/null &

# The upload path depends on the mode.
case "${MODE}" in
  perfSONAR)
    bashio::log.info "upload target: OpenSearch (perfSONAR)"
    /app/sendlog-opensearch-loop.sh &
    ;;
  SINDAN)
    bashio::log.info "upload target: SINDAN server"
    /app/sendlog-loop.sh &
    ;;
  *)
    bashio::log.warning "unknown mode '${MODE}', defaulting to SINDAN server"
    /app/sendlog-loop.sh &
    ;;
esac

tail -f /dev/null
