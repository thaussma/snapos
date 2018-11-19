#!/bin/bash

set -u
set -e

for arg in "$@"
do
	case "${arg}" in
		--add-wlan0)
		if ! grep -qE '^iface wlan0' "${TARGET_DIR}/etc/network/interfaces"; then
			echo "Adding wlan0 to /etc/network/interfaces."
			cat << __EOF__ >> "${TARGET_DIR}/etc/network/interfaces"

auto wlan0
iface wlan0 inet dhcp
		pre-up wpa_supplicant -B -Dwext -iwlan0 -c/etc/wpa_supplicant.conf
		post-down killall -q wpa_supplicant
		wait-delay 15
__EOF__
		fi
		if [[ "${WPA_SUPPLICANT_SSID:-}" && "${WPA_SUPPLICANT_PSK:-}" ]]; then
		cat << __EOF__ > "${TARGET_DIR}/etc/wpa_supplicant.conf"
ctrl_interface=/var/run/wpa_supplicant
ap_scan=1

network={
    ssid=${WPA_SUPPLICANT_SSID}
    psk=${WPA_SUPPLICANT_PSK}
    key_mgmt=WPA-PSK
}
__EOF__
		fi
		;;
		--mount-boot)
		if ! grep -qE '^/dev/mmcblk0p1' "${TARGET_DIR}/etc/fstab"; then
			mkdir -p "${TARGET_DIR}/boot"
			echo "Adding mount point for /boot to /etc/fstab."
			cat << __EOF__ >> "${TARGET_DIR}/etc/fstab"
/dev/mmcblk0p1	/boot		vfat	defaults	0	2
__EOF__
		fi
		;;
		--raise-volume)
		if grep -qE '^ENV{ppercent}:=\"75%\"' "${TARGET_DIR}/usr/share/alsa/init/default"; then
			echo "Raising alsa default volume to 100%."
			sed -i -e 's/ENV{ppercent}:="75%"/ENV{ppercent}:="100%"/g' "${TARGET_DIR}/usr/share/alsa/init/default"
			sed -i -e 's/ENV{pvolume}:="-20dB"/ENV{pvolume}:="4dB"/g' "${TARGET_DIR}/usr/share/alsa/init/default"
		fi
		;;
		--authorized_keys)
		if ! [ "${ID_RSA_PUB:-}" = "" ]; then
			mkdir -p "${TARGET_DIR}/root/.ssh/"
			chmod 0700 "${TARGET_DIR}/root/.ssh/"
			chmod 0700 "${TARGET_DIR}/root"
			echo "${ID_RSA_PUB}" > "${TARGET_DIR}/root/.ssh/authorized_keys"
			chmod 0600 "${TARGET_DIR}/root/.ssh/authorized_keys"
		fi
		;;
	esac

done


