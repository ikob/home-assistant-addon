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
