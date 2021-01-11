#!/bin/sh
#
# Copyright (C) 2019 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

. /lib/functions.sh
. /usr/share/libubox/jshn.sh
. /lib/functions/leds.sh

MWAN3_LED_SELECTED=0
MWAN3_OFFLINE=0
MWAN3_ONLINE=0
MWAN3_STATUS="OFFLINE"
SYSFS=""

log() {
	local facility=$1; shift
	# in development, we want to show 'debug' level logs
	# when this release is out of beta, the comment in the line below
	# should be removed
	[ "$facility" = "debug" ] && return
	logger -t "led-mwan3-status[$$]" -p $facility "$*"
}

check_status() {
	local cfg="$1"

	local trigger sysfs mwan3_status keys key
	local status running

	config_get trigger "$cfg" trigger
	config_get sysfs "$cfg" sysfs

	[ "$trigger" = "mwan3_status" ] && [ -n "$sysfs" ] || return
	MWAN3_LED_SELECTED=1
	SYSFS=$sysfs

	mwan3_status=$(ubus -S call mwan3 status)
	[ -n "$mwan3_status" ] && {
		json_load "$mwan3_status"
		json_select "interfaces"

		json_get_keys keys
		for key in ${keys}; do
			json_select "${key}"
			json_get_vars status running
			json_select ..
			[ $running -eq 1 ] && {
				[ "$status" = "online" ] && {
					MWAN3_ONLINE=1
				}
				[ "$status" = "offline" ] && {
					MWAN3_OFFLINE=1
				}
			}
		done
		json_select ..

		if [ $MWAN3_OFFLINE -eq 1 ] && [ $MWAN3_ONLINE -eq 1 ]; then
			MWAN3_STATUS="BACKUP"
		elif [ $MWAN3_ONLINE -eq 1 ]; then
			MWAN3_STATUS="ONLINE"
		elif [ $MWAN3_OFFLINE -eq 1 ]; then
			MWAN3_STATUS="OFFLINE"
		else
			MWAN3_STATUS="OFFLINE"
		fi
	}
}

main() {
	config_load system
	config_foreach check_status led

	if [ $MWAN3_LED_SELECTED -eq 1 ]; then
		case $MWAN3_STATUS in
			"ONLINE")
				log debug "All mwan3 interfaces are online"
				led_off "$SYSFS"
				;;
			"BACKUP")
				log debug "At least one mwan3 interface is offline"
				led_timer "$SYSFS" "500" "500"
				;;
			"OFFLINE")
				log debug "All mwan3 interfaces are offline"
				led_on "$SYSFS"
				;;
		esac
	fi
}
