#!/bin/sh

set -u
set -e

cat << __EOF__ > "${TARGET_DIR}/etc/wpa_supplicant.conf"

ctrl_interface=/var/run/wpa_supplicant
ap_scan=1

network={
    ssid=${WPA_SUPPLICANT_SSID}
    psk=${WPA_SUPPLICANT_PSK}
}
__EOF__