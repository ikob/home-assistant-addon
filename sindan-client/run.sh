#!/usr/bin/with-contenv bashio

# import HA-OS config parameters
export URL_CAMPAIGN=$(bashio::config 'url_campaign')
export URL_SINDAN=$(bashio::config 'url_sindan')

bashio::log.info "${URL_CAMPAIGN}"
bashio::log.info "${URL_SINDAN}"

# Fetch from repo.
cd /app
git clone -b HA-OS --depth 1 https://github.com/ikob/sindan-client.git && \
cd sindan-client/linux
./install.sh
ln -s /app/sindan.conf /app/sindan-client/linux/sindan.conf

#/app/sindan-loop.sh &
#/app/sendlog-loop.sh &
#/app/sindan-loop.sh 1>/dev/null 2>/dev/null &
#/app/sendlog-loop.sh 1>/dev/null 2>/dev/null &
/app/sindan-loop.sh 1>/dev/null /dev/null &
/app/sendlog-loop.sh 1>/dev/null /dev/null &

tail -f /dev/null
