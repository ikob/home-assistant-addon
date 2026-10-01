#!/usr/bin/with-contenv bashio

# Prometheus exporter for the non-aggressive Wi-Fi measurements.
# sindan_exporter.sh writes sindan_wifi.prom into TEXTFILE_DIR every
# exporter_interval seconds; node_exporter serves it (textfile collector only)
# on exporter_port. The add-on uses the host network, so the port is open on
# the HA host itself. Runs independently of the upload mode.

export TEXTFILE_DIR=/tmp/sindan-metrics
# Same Wi-Fi interface as the SINDAN measurement (DEVNAME in sindan.conf).
export WLAN_IF=$(. /app/sindan.conf; echo "${DEVNAME:-wlan0}")
PORT=$(bashio::config 'exporter_port')
INTERVAL=$(bashio::config 'exporter_interval')

mkdir -p "${TEXTFILE_DIR}"

bashio::log.info "Prometheus exporter: :${PORT}/metrics (interface ${WLAN_IF}, every ${INTERVAL}s)"

# Only the textfile collector: the HA host's own metrics are not our concern.
prometheus-node-exporter \
  --web.listen-address=":${PORT}" \
  --web.disable-exporter-metrics \
  --collector.disable-defaults \
  --collector.textfile \
  --collector.textfile.directory="${TEXTFILE_DIR}" &

# The interval is also the upper bound on how often a real scan is triggered.
while true
do
  /app/sindan-client/linux/sindan_exporter.sh
  sleep "${INTERVAL}"
done
