#!/usr/bin/with-contenv bashio

# Upload loop for MODE=perfSONAR: push measurement results to OpenSearch.
# All OpenSearch settings come from the add-on options (kept out of git).

# The SINDAN-server URLs / SSH servers are not used when pushing to OpenSearch;
# only the OS_* settings matter here.
export OS_URL=$(bashio::config 'os_url')
export OS_INDEX_PREFIX=$(bashio::config 'os_index_prefix')
export OS_AUTH="$(bashio::config 'os_user'):$(bashio::config 'os_pass')"
if bashio::config.true 'os_insecure'; then
  export OS_INSECURE=yes
else
  export OS_INSECURE=no
fi

# Stable observation-point identity (the exporter/Prometheus "instance" label).
# This is a FIXED Wi-Fi sensor, so it needs a stable id -- NOT the ephemeral
# container hostname (<hash>-sindan-client), which changes on every rebuild and
# would break the time series. Set os_host in the add-on options; if left empty
# sendlog_opensearch.sh falls back to $(hostname).
export PROM_HOST=$(bashio::config 'os_host')

bashio::log.info "OpenSearch target: ${OS_URL} (index ${OS_INDEX_PREFIX}-*, host=${PROM_HOST:-<hostname>}, insecure=${OS_INSECURE})"

while true
do
  /app/sindan-client/linux/sendlog_opensearch.sh
  sleep 300
done
