#!/bin/bash
# based on script found in attachment 255355, at https://bugzilla.kernel.org/show_bug.cgi?id=191601#c97

if [[ $EUID -ne 0 ]]; then
	echo "This script fails if not run as root"
	exit 1
fi

wirelessPCI=$(lspci | grep "Wireless 7260")
pci="$(echo ${wirelessPCI} | awk '{ print $1 }')"
devicePath="/sys/bus/pci/devices/0000:$pci/remove"

#echo "devicePath $devicePath"

# Tell linux to remove the wifi card from pci device list only if it actually exists
if [[ -f $devicePath ]]; then
	echo 1 > $devicePath > /dev/null
	sleep 1
fi

# reprobe the driver modules in case we removed them in a failed attempt to wake the network card
modprobe iwlmvm
modprobe iwlwifi

# try to have linux bring the network card back online as a PCI device
echo 1 > /sys/bus/pci/rescan
sleep 1

# check if linux managed to bring the network card back online as a pci device
if [[ -f $devicePath ]]; then

	# looks like we're back
	# so we do some voodoo that an intel dev said to do
	# see https://bugzilla.kernel.org/show_bug.cgi?id=191601
	setpci -s $pci 0x50.B=0x40

	# bring the wireless interface back up
	ip link set dev wlp5s0 up

	# did it actually come up?
	exitCode=$?

	echo "Success"
else
	# wifi's completly dead!, force removal and report failure
	sudo modprobe -r iwlmvm
	sudo modprobe -r iwlwifi

	echo "Failure"

	exit 1
fi

exit 0
