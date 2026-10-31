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

echo "Patching U-Boot bootargs for ACE USB quirks (survives reboot)..."
sh "$SCRIPT_DIR/patch-bootargs.sh"

if [ -f "$SCRIPT_DIR/verify-live.sh" ]; then
    echo "Verifying..."
    sh "$SCRIPT_DIR/verify-live.sh" || true
fi

echo "Done. Reboot the printer after power-cycling a wedged ACE so bootargs apply."
