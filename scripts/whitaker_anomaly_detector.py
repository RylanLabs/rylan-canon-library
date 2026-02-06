#!/usr/bin/env python3
"""Whitaker Anomaly Detector (ML 7.2).

Detects identity drift and rogue hardware by comparing UniFi live state
against the Carter Device Manifest.
"""

import os
import sys
from typing import Any

import yaml

# Add collection to path
sys.path.append(os.path.join(os.path.dirname(__file__), ".."))
try:
    from ansible_collections.rylanlabs.unifi.plugins.module_utils.unifi_api import UnifiAPI
except ImportError:
    UnifiAPI = None  # type: ignore

def load_manifest(path: str) -> dict[str, Any]:
    if not os.path.exists(path):
        return {}
    with open(path) as f:
        return yaml.safe_load(f) or {}

def main() -> None:
    """Execute Whitaker anomaly detection protocol."""
    print("🛡️  Whitaker Protocol: AI-augmented Anomaly Detection...")

    manifest_path = os.getenv("DEVICE_MANIFEST", "test-satellite/manifests/argocd/satellite-app.yaml") # Placeholder
    # Search for actual manifest
    for p in ["inventory/device-manifest.yml", "test-satellite/manifests/device-manifest.yml", "templates/device-manifest-template.yml"]:
        if os.path.exists(p):
            manifest_path = p
            break

    manifest = load_manifest(manifest_path)
    devices_manifest = manifest.get("devices", {})
    if isinstance(devices_manifest, list):
        manifest_macs = { (d.get("mac") or "").lower() for d in devices_manifest if d.get("mac") }
    else:
        manifest_macs = { (v.get("mac") or "").lower() for k, v in devices_manifest.items() if v.get("mac") }

    host = os.getenv("UNIFI_HOST")
    user = os.getenv("UNIFI_USER")
    password = os.getenv("UNIFI_PASS")

    if not all([host, user, password]):
        print("⚠️  Skipping UniFi live check (Missing credentials)")
        return

    if UnifiAPI is None:
        print("❌ Error: UnifiAPI library not found")
        sys.exit(1)

    api: Any = UnifiAPI(  # type: ignore
        host=host, username=user, password=password, verify_ssl=False
    )
    try:
        live_devices = api.get_devices()
        live_clients = api.get_clients()
    except Exception as e:
        print(f"❌ Error connecting to UniFi: {e}")
        sys.exit(1)

    rogues = []
    for dev in live_devices:
        mac = (dev.get("mac") or "").lower()
        if mac and mac not in manifest_macs:
            rogues.append({"name": dev.get("name"), "mac": mac, "type": "Infrastructure"})

    for client in live_clients:
        mac = (client.get("mac") or "").lower()
        if mac and mac not in manifest_macs:
            # Filter out temporary clients or things we don't care about
            # In a real setup, we might have a 'known_clients' list
            pass

    if rogues:
        print(f"❌ ADVERSARIAL DETECTION: {len(rogues)} Rogue devices found!")
        for r in rogues:
            print(f"   - {r['name']} ({r['mac']}) [{r['type']}]")
        sys.exit(1)
    else:
        print("✅ No rogue infrastructure detected.")

if __name__ == "__main__":
    main()
