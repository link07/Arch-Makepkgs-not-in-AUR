#!/bin/bash

if [ -z "$1" ]; then
    # use 5% by default
    cap=5
else
    cap="$1"
fi

acpi -b | grep 'Battery 1' | awk -F'[,:%]' '{print $2, $3}' | {
    read -r status capacity

    msg="$status, $capacity%"

    if [ "$status" == Discharging ] && [ "$capacity" -lt "$cap" ]; then
        msg="Critical battery threshold: $msg"

	    echo "$msg"

    	systemctl hibernate
    else
	    msg="Battery not low: $msg"

	    echo "$msg"
    fi
}
