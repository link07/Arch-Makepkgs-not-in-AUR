#!/bin/bash

# Copyright (c) 2017 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

# this edited version supports the following commandline args (in this order): port1 port2 interface

# see https://github.com/bitcoin/bitcoin/blob/master/contrib/qos/tc.sh for a non-edited version

# get port1
if [ -z "$1" ]; then
    # use bitcoin by default
    port=8333
else
    port="$1"
fi

# get port2
if [ -z "$2" ]; then
    # use litecoin by default
    port2=9333
else
    port2="$2"
fi

# get interface
if [ -z "$3" ]; then
    # use this wifi by default [CHANGE TO YOUR OWN]
    IF="wlp5s0"
else
    IF="$3"
fi

#limit of the network interface in question [CHANGE TO YOUR OWN]
LINKCEIL="1gbit"
#limit outbound Bitcoin protocol traffic to this rate [CHANGE TO YOUR OWN]
LIMIT="5Mbit"
#defines the IPv4 address space for which you wish to disable rate limiting (only allow localhost)
LOCALNET_V4="127.0.0.0/8"
#defines the IPv6 address space for which you wish to disable rate limiting (only allow localhost)
LOCALNET_V6="::1/128"

#delete existing rules
tc qdisc del dev ${IF} root

#add root class
tc qdisc add dev ${IF} root handle 1: htb default 10

#add parent class
tc class add dev ${IF} parent 1: classid 1:1 htb rate ${LINKCEIL} ceil ${LINKCEIL}

#add our two classes. one unlimited, another limited
tc class add dev ${IF} parent 1:1 classid 1:10 htb rate ${LINKCEIL} ceil ${LINKCEIL} prio 0
tc class add dev ${IF} parent 1:1 classid 1:11 htb rate ${LIMIT} ceil ${LIMIT} prio 1

#add handles to our classes so packets marked with <x> go into the class with "... handle <x> fw ..."
tc filter add dev ${IF} parent 1: protocol ip prio 1 handle 1 fw classid 1:10
tc filter add dev ${IF} parent 1: protocol ip prio 2 handle 2 fw classid 1:11

if [ ! -z "${LOCALNET_V6}" ] ; then
	# v6 cannot have the same priority value as v4
	tc filter add dev ${IF} parent 1: protocol ipv6 prio 3 handle 1 fw classid 1:10
	tc filter add dev ${IF} parent 1: protocol ipv6 prio 4 handle 2 fw classid 1:11
fi

#delete any existing rules
#disable for now
#ret=0
#while [ $ret -eq 0 ]; do
#	iptables -t mangle -D OUTPUT 1
#	ret=$?
#done

#limit outgoing traffic to and from port 8333. but not when dealing with a host on the local network
#	(defined by $LOCALNET_V4 and $LOCALNET_V6)
#	--set-mark marks packages matching these criteria with the number "2" (v4)
#	--set-mark marks packages matching these criteria with the number "4" (v6)
#	these packets are filtered by the tc filter with "handle 2"
#	this filter sends the packages into the 1:11 class, and this class is limited to ${LIMIT}
iptables -t mangle -A OUTPUT -p tcp -m tcp --dport ${port} ! -d ${LOCALNET_V4} -j MARK --set-mark 0x2
iptables -t mangle -A OUTPUT -p tcp -m tcp --sport ${port} ! -d ${LOCALNET_V4} -j MARK --set-mark 0x2

if [ ! -z "${LOCALNET_V6}" ] ; then
	ip6tables -t mangle -A OUTPUT -p tcp -m tcp --dport ${port} ! -d ${LOCALNET_V6} -j MARK --set-mark 0x4
	ip6tables -t mangle -A OUTPUT -p tcp -m tcp --sport ${port} ! -d ${LOCALNET_V6} -j MARK --set-mark 0x4
fi

# port2
iptables -t mangle -A OUTPUT -p tcp -m tcp --dport ${port2} ! -d ${LOCALNET_V4} -j MARK --set-mark 0x2
iptables -t mangle -A OUTPUT -p tcp -m tcp --sport ${port2} ! -d ${LOCALNET_V4} -j MARK --set-mark 0x2

if [ ! -z "${LOCALNET_V6}" ] ; then
    ip6tables -t mangle -A OUTPUT -p tcp -m tcp --dport ${port2} ! -d ${LOCALNET_V6} -j MARK --set-mark 0x4
    ip6tables -t mangle -A OUTPUT -p tcp -m tcp --sport ${port2} ! -d ${LOCALNET_V6} -j MARK --set-mark 0x4
fi

