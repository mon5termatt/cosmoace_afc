#!/bin/sh
# Remove ace-usb-harden live install from a COSMOS printer.
set -eu

[ "$(id -u)" -eq 0 ] || { echo "Run as root." >&2; exit 1; }

for svc in ace-usb-power ace-usb-recover; do
    if [ -f "/etc/init.d/${svc}" ]; then
        "/etc/init.d/${svc}" stop 2>/dev/null || true
        rm -f "/etc/init.d/${svc}" /etc/rc*.d/S*"${svc}" /etc/rc*.d/K*"${svc}"
    fi
done

rm -f /user-resource/ace-addon/ace-usb-power.sh \
      /user-resource/ace-addon/ace-usb-recover.sh \
      /etc/udev/rules.d/98-ace-usb.rules \
      /etc/modprobe.d/usbcore-ace.conf \
      /var/run/ace-usb-power.pid /var/run/ace-usb-power.lock \
      /var/run/ace-usb-recover.pid /var/run/ace-usb-recover.lock \
      /var/run/ace-usb-reauth.ts /var/run/ace-usb-gone.ts

update-rc.d -f ace-usb-power remove 2>/dev/null || true
update-rc.d -f ace-usb-recover remove 2>/dev/null || true

udevadm control --reload 2>/dev/null || true
echo "ace-usb-harden removed (usbcore module params reset on next reboot)."
