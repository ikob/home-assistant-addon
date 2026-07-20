# Intercom Entrance SIP Agent (Home Assistant Add-on)

# Description
Invoke SIP REGISTER. Receiving INVITE, send a registered MESSAGE.

## Configuration
You must set:
- username
- password
- proxy (host:port)
- register_uri
- message_uri
- entrance_uri
- allowed_caller
- answer_calls
- send_messages

## Notes
- host_network: must be true

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
    body_on: '{"answer_calls": false, "send_messages": true}'
    body_off: '{"answer_calls": false, "send_messages": false}'
    is_on_template: "{{ value_json.send_messages }}"
    headers:
      Content-Type: application/json
    timeout: 5
```

If `switch:` is already defined in `configuration.yaml`, append only the
`- platform: rest` entry under the existing `switch:` section. Do not add a
second top-level `switch:` key.

For unlock-only operation, answering the incoming SIP call is not required.
Turning the switch on enables SIP MESSAGE sending while keeping
`answer_calls` disabled, avoiding an established call that would need to be
torn down. Turning it off disables MESSAGE sending. Set `answer_calls` to
`true` only if incoming-call answering is explicitly needed. Restart Home
Assistant after changing `configuration.yaml`.

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
docker run --rm --net=host \
  -e USERNAME=cellphone0 \
  -e PASSWORD='<PASSWORD>' \
  -e PROXY=<IP_ADDRESS>:5060 \
  -e REGISTER_URI=sip:cellphone0@<IP_ADDRESS>:5060 \
  -e MESSAGE_URI=sip:housing@<IP_ADDRESS>:5060 \
  -e ENTRANCE_URI=sip:housing@<IP_ADDRESS>:5060 \
  -e ALLOWED_CALLER=interphone0 \
  -e ANSWER_CALLS=false \
  -e SEND_MESSAGES=true \
  --entrypoint /usr/local/bin/run-test.sh \
  ap_intercom_agent:dev
```
