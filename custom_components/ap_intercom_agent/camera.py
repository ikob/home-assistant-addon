# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026, Katsushi Kobayashi

"""Camera platform for AP Intercom Agent."""

import asyncio
import logging
from typing import override

from aiohttp import ClientError

from homeassistant.components.camera import (
    Camera,
    CameraEntityCapabilities,
    CameraEntityFeature,
)
from homeassistant.config_entries import ConfigEntry
from homeassistant.const import CONF_NAME
from homeassistant.core import HomeAssistant
from homeassistant.helpers.aiohttp_client import async_get_clientsession
from homeassistant.helpers.device_registry import DeviceInfo
from homeassistant.helpers.entity_platform import AddConfigEntryEntitiesCallback

from .const import CONF_AGENT_URL, CONF_RTSP_URL, DOMAIN

_LOGGER = logging.getLogger(__name__)
_SNAPSHOT_TIMEOUT = 5


async def async_setup_entry(
    hass: HomeAssistant,
    entry: ConfigEntry,
    async_add_entities: AddConfigEntryEntitiesCallback,
) -> None:
    """Set up the AIPHONE camera."""
    async_add_entities([APIntercomCamera(hass, entry)])


class APIntercomCamera(Camera):
    """A WebRTC-capable AIPHONE camera with an RTSP backchannel."""

    _attr_supported_features = CameraEntityFeature.STREAM
    _attr_camera_entity_capabilities = CameraEntityCapabilities(two_way_audio=True)
    _attr_frame_interval = 0.5

    def __init__(self, hass: HomeAssistant, entry: ConfigEntry) -> None:
        """Initialize the camera."""
        super().__init__()
        self.hass = hass
        self._attr_name = entry.data[CONF_NAME]
        self._attr_unique_id = entry.entry_id
        self._agent_url = entry.data[CONF_AGENT_URL]
        self._rtsp_url = entry.data[CONF_RTSP_URL]
        self._last_image: bytes | None = None
        self._attr_device_info = DeviceInfo(
            identifiers={(DOMAIN, entry.entry_id)},
            name=entry.title,
            manufacturer="AIPHONE",
            model="IFBOX SIP bridge",
        )

    @override
    async def stream_source(self) -> str:
        """Return the direct RTSP source, preserving its backchannel."""
        return self._rtsp_url

    @override
    async def async_camera_image(
        self, width: int | None = None, height: int | None = None
    ) -> bytes | None:
        """Fetch the current JPEG snapshot from the agent."""
        session = async_get_clientsession(self.hass)
        try:
            async with asyncio.timeout(_SNAPSHOT_TIMEOUT):
                async with session.get(
                    f"{self._agent_url}/v1/camera.jpg"
                ) as response:
                    response.raise_for_status()
                    self._last_image = await response.read()
        except (TimeoutError, ClientError) as err:
            _LOGGER.debug("Unable to fetch AIPHONE snapshot: %s", err)
        return self._last_image
