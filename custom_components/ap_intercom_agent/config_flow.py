# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026, Katsushi Kobayashi

"""Config flow for AP Intercom Agent."""

from typing import Any, override

import probatio
from yarl import URL

from homeassistant.config_entries import ConfigFlow, ConfigFlowResult
from homeassistant.const import CONF_NAME

from .const import (
    CONF_AGENT_URL,
    CONF_RTSP_URL,
    DEFAULT_AGENT_URL,
    DEFAULT_NAME,
    DEFAULT_RTSP_URL,
    DOMAIN,
)


def _normalize_url(value: str, schemes: set[str]) -> str:
    """Validate an absolute URL and normalize its trailing slash."""
    url = URL(value)
    if not url.is_absolute() or url.scheme not in schemes or not url.host:
        raise ValueError
    return str(url)


class APIntercomAgentConfigFlow(ConfigFlow, domain=DOMAIN):
    """Handle an AP Intercom Agent config flow."""

    VERSION = 1

    @override
    async def async_step_user(
        self, user_input: dict[str, Any] | None = None
    ) -> ConfigFlowResult:
        """Create the local camera entity."""
        errors: dict[str, str] = {}
        if user_input is not None:
            try:
                agent_url = _normalize_url(
                    user_input[CONF_AGENT_URL].rstrip("/"), {"http", "https"}
                )
            except (TypeError, ValueError):
                errors[CONF_AGENT_URL] = "invalid_url"
            try:
                rtsp_url = URL(
                    _normalize_url(user_input[CONF_RTSP_URL], {"rtsp", "rtsps"})
                ).update_query(backchannel="1")
            except (TypeError, ValueError):
                errors[CONF_RTSP_URL] = "invalid_url"

            if not errors:
                await self.async_set_unique_id(DOMAIN)
                self._abort_if_unique_id_configured()
                data = {
                    CONF_NAME: user_input[CONF_NAME],
                    CONF_AGENT_URL: agent_url,
                    CONF_RTSP_URL: str(rtsp_url),
                }
                return self.async_create_entry(title=user_input[CONF_NAME], data=data)

        schema = probatio.Schema(
            {
                probatio.Required(CONF_NAME, default=DEFAULT_NAME): str,
                probatio.Required(CONF_AGENT_URL, default=DEFAULT_AGENT_URL): str,
                probatio.Required(CONF_RTSP_URL, default=DEFAULT_RTSP_URL): str,
            }
        )
        return self.async_show_form(step_id="user", data_schema=schema, errors=errors)
