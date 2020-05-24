#!/bin/bash

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network
echo "cleaning up udev rules"
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/

#echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
#echo "pre-up sleep 2" >> /etc/network/interfaces
