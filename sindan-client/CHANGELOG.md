# Changelog

## 0.1.5

- `exporter` now defaults to `false`. On a perfSONAR node, run the Wi-Fi
  exporter in the perfSONAR Testpoint add-on instead (`wifi_exporter`): it is
  served with perfSONAR's host metrics, and that add-on's node_exporter needs
  port 9100, which this exporter would otherwise hold. Existing installs keep
  their saved value; turn it off by hand there.

## 0.1.4

- Add a Prometheus exporter for the Wi-Fi neighbour scan
  (`sindan_exporter.sh`, served by node_exporter's textfile collector on the
  host network). Options: `exporter` (on/off), `exporter_port` (default 9100),
  `exporter_interval` (default 600 s; also the upper bound on how often a real
  scan is triggered). Runs in either upload mode.

## 0.1.3

- Install `sudo` in the image so `install.sh` (run at startup) works; it uses
  `sudo apt` to add the one package not baked into the image (`jq`).

## 0.1.2

- Add an `os_host` option: the stable observation-point / exporter "instance"
  label for the OpenSearch push. A fixed Wi-Fi sensor needs a stable id, not the
  ephemeral container hostname; if empty it falls back to `$(hostname)`.
- Uploader (`sendlog_opensearch.sh`) no longer emits `campaign` as a label
  (unbounded per-run cardinality); it stays only in `_id` for idempotency.

## 0.1.1

- Add a `mode` option: `SINDAN` uploads to the SINDAN server (`sendlog.sh`),
  `perfSONAR` pushes to OpenSearch (`sendlog_opensearch.sh`).
- Add OpenSearch options (`os_url`, `os_index_prefix`, `os_user`, `os_pass`,
  `os_insecure`); credentials come from the add-on options, not the source.

## 0.0.1

- Initial release.
