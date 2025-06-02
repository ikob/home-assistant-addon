#!/usr/bin/with-contenv bashio

export URL_CAMPAIGN=$(bashio::config 'url_campaign')
export URL_SINDAN=$(bashio::config 'url_sindan')
export SSH4_SRVS=$(bashio::config 'ssh4_srvs')_ed25519
export SSH6_SRVS=$(bashio::config 'ssh6_srvs')_ed25519

while true
do
/app/sindan-client/linux/sendlog.sh
sleep 300
done
