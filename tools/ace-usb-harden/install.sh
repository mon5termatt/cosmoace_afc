#!/bin/sh
# Install ACE USB harden package on a running COSMOS printer.
# Run as root from this directory, or:
#   sh /etc/klipper/plugins/AFC_ACE/tools/ace-usb-harden/install.sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

[ "$(id -u)" -eq 0 ] || { echo "Run as root." >&2; exit 1; }
[ -f "$SCRIPT_DIR/deploy-live.sh" ] || { echo "Missing deploy-live.sh next to install.sh" >&2; exit 1; }

echo "Installing ace-usb-harden (udev, usbcore quirks, power + recover daemons)..."
sh "$SCRIPT_DIR/deploy-live.sh" "$SCRIPT_DIR"

if [ -x /tmp/ace-usb-harden/verify-live.sh ] || [ -f "$SCRIPT_DIR/verify-live.sh" ]; then
    echo "Verifying..."
    sh "$SCRIPT_DIR/verify-live.sh" || true
fi

echo "Done. Hubs should show power/control=on; ace-usb-power / ace-usb-recover should be running."
echo "Bootargs quirks fully apply after a Cosmos image that includes the u-boot env change,"
echo "or reboot after fw_setenv — live sysfs quirks are already applied best-effort."
