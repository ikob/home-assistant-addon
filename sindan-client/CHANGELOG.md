# Changelog

## 0.1.1

- Add a `mode` option: `SINDAN` uploads to the SINDAN server (`sendlog.sh`),
  `perfSONAR` pushes to OpenSearch (`sendlog_opensearch.sh`).
- Add OpenSearch options (`os_url`, `os_index_prefix`, `os_user`, `os_pass`,
  `os_insecure`); credentials come from the add-on options, not the source.

## 0.0.1

- Initial release.
