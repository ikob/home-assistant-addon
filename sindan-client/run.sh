#!/usr/bin/with-contenv bashio

export URL_CAMPAIGN=$(bashio::config 'url_campaign')
export URL_SINDAN=$(bashio::config 'url_sindan')

bashio::log.info "SINDAN add-on starting"
bashio::log.info "URL_CAMPAIGN=${URL_CAMPAIGN}"
bashio::log.info "URL_SINDAN=${URL_SINDAN}"

# Fetch the SINDAN client from the repo.
cd /app
git clone -b opensearch --depth 1 https://github.com/ikob/sindan-client.git && \
cd sindan-client/linux
./install.sh
ln -sf /app/sindan.conf /app/sindan-client/linux/sindan.conf
cd /app

# Measurement loop (produces log/*.json) and upload to the SINDAN server.
/app/sindan-loop.sh 1>/dev/null 2>/dev/null &
/app/sendlog-loop.sh &

tail -f /dev/null
