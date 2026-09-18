# Changelog

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
