# Intercom Entrance SIP Agent (Home Assistant Add-on)

# Description
Register with the Aiphone SIP service, automatically unlock configured
entrances, and save a JPEG from each incoming ring while `send_messages` is
enabled.

## Configuration

Set these installation-specific options:

- username
- password
- proxy (host:port)
- register_uri
- message_uri
- entrance_uri

The add-on reads `password` from Home Assistant's add-on configuration and
passes it directly to the agent. The core agent's local-development `.env` and
`AP_INTERCOM_PASSWORD` mechanism is not used inside the add-on.

The remaining options have defaults. `allowed_callers` defaults to
`interphone0` (the external/internal entrances) and `interphone1` (the
apartment door). The effective list must contain at least one non-empty entry;
the add-on stops instead of accepting calls from every caller if both the new
list and any legacy setting are empty.

`unlock_callers` is a separate safety allow-list and defaults to only
`interphone0`; `interphone1` is photographed but is never automatically
unlocked. An empty `unlock_callers` list disables automatic unlocking while
still allowing configured callers and ring-image capture.

For instructions on obtaining `jpeg_query_s`, see
[`Finding jpeg_query_s`](https://github.com/ikob/AP_intercom_agent#finding-jpeg_query_s)
in the AP Intercom Agent documentation.
`incoming_jpeg_max_files` limits retained ring images and defaults to 100. The
oldest image is removed when the limit is exceeded.

## Notes
- host_network: must be true

## Ring image storage

The add-on maps Home Assistant's media directory read/write and stores images
in `/media/ap_intercom_agent`. This directory is outside the container image,
so images survive add-on restarts and upgrades and are available through Home
Assistant's media storage. Files use a timestamp and SIP caller name, for
example:

```text
20261004T214123.123456789+0900_interphone0.jpg
```

Browse them from **Media > My media > ap_intercom_agent** in Home Assistant.

Only these timestamped ring images are subject to
`incoming_jpeg_max_files`; unrelated files are not removed. The directory is
dedicated to this add-on and its retention logic assumes one running add-on
instance writes to it.

Home Assistant can include Media in a full backup. Because these images are
transient and may contain visitors, consider excluding Media from automatic
backups unless retaining them in backups is intentional.

### Upgrading from 0.1.x

Version 0.2.0 replaces the single `allowed_caller` option with the
`allowed_callers` array. A saved legacy `allowed_caller` is merged into the new
array without duplicates so a custom 0.1.x caller keeps working. It remains
active until cleared from the add-on configuration, but it is never copied to
`unlock_callers`. After upgrading, copy any caller you still need into
`allowed_callers`, clear the legacy field, and review `unlock_callers`. In
particular, keep apartment-door callers out of `unlock_callers`.

## Home Assistant integration

Add the following REST switch to the Home Assistant
`/config/configuration.yaml` file:

```yaml
##########################################################################################
# Aiphone intercom agent
##########################################################################################
switch:
  - platform: rest
    name: "Intercom send_messages"
    resource: "http://127.0.0.1:18080/v1/state"
    body_on: '{"send_messages": true}'
    body_off: '{"send_messages": false}'
    is_on_template: "{{ value_json.send_messages }}"
    headers:
      Content-Type: application/json
    timeout: 5
```

If `switch:` is already defined in `configuration.yaml`, append only the
`- platform: rest` entry under the existing `switch:` section. Do not add a
second top-level `switch:` key.

The REST request intentionally changes only `send_messages`; it preserves the
`answer_calls` value selected in the add-on configuration. With
`answer_calls=true`, the agent captures the JPEG, answers the SIP call, waits
approximately one second, and sends BYE. This avoids the Busy/congestion result
observed with the tested intercom. With `answer_calls=false`, it captures the
JPEG and sends the configured final rejection instead, which the caller may
display as Busy or congestion. Restart Home Assistant after changing
`configuration.yaml`.

## How to build
```
docker build \
  --build-arg BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest \
  --build-arg REPO_URL=https://github.com/ikob/AP_intercom_agent.git \
  --build-arg REPO_REF=main \
  -t ap_intercom_agent:dev .

```
## How to test on local

```
mkdir -p /tmp/aiphone-rings

docker run --rm --net=host \
  -v /tmp/aiphone-rings:/media/ap_intercom_agent \
  -e SIP_USERNAME=cellphone0 \
  -e PASSWORD='<PASSWORD>' \
  -e PROXY=<IP_ADDRESS>:5060 \
  -e REGISTER_URI=sip:cellphone0@<IP_ADDRESS>:5060 \
  -e MESSAGE_URI=sip:housing@<IP_ADDRESS>:5060 \
  -e ENTRANCE_URI=sip:housing@<IP_ADDRESS>:5060 \
  -e ALLOWED_CALLERS=interphone0,interphone1 \
  -e UNLOCK_CALLERS=interphone0 \
  -e JPEG_QUERY_S=cd188d8e518cb12ad7a644f23928f64f \
  -e INCOMING_JPEG_DIR=/media/ap_intercom_agent \
  -e INCOMING_JPEG_MAX_FILES=100 \
  -e ANSWER_CALLS=true \
  -e SEND_MESSAGES=true \
  --entrypoint /usr/local/bin/run-test.sh \
  ap_intercom_agent:dev
```

## License

The add-on files are licensed under the
[Apache License 2.0](./LICENSE). The packaged agent and all third-party
components retain their respective licenses.
