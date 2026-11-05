# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026, Katsushi Kobayashi

"""Constants for AP Intercom Agent."""

from typing import Final

from homeassistant.const import Platform

DOMAIN: Final = "ap_intercom_agent"
PLATFORMS: Final = [Platform.CAMERA]

CONF_AGENT_URL: Final = "agent_url"
CONF_RTSP_URL: Final = "rtsp_url"

DEFAULT_NAME: Final = "AIPHONE Intercom"
DEFAULT_AGENT_URL: Final = "http://127.0.0.1:18080"
DEFAULT_RTSP_URL: Final = "rtsp://127.0.0.1:8554/intercom?backchannel=1"
