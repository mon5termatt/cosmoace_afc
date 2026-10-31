#!/bin/sh
# Intentionally does NOT toggle hub authorized.
# Hard -71 wedges are not recoverable in software — power-cycle the ACE.
echo "Hub reauth cannot clear an ACE -71 wedge."
echo "Power-cycle the ACE (its own wall power / switch), then wait for ttyACM0."
if [ -x /user-resource/ace-addon/ace-usb-recover.sh ]; then
    sh /user-resource/ace-addon/ace-usb-recover.sh --once || true
fi
exit 1
