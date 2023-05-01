#!/bin/bash

# Set the LAN-segment network address based on the project group
# Replace the "172.18.0.0/16" with the appropriate network address for your group
case "$1" in
    1)
        LAN_SEGMENT="172.16.0.0/16"
        ;;
    2)
        LAN_SEGMENT="172.18.0.0/16"
        ;;
    3)
        LAN_SEGMENT="172.19.0.0/16"
        ;;
    4)
        LAN_SEGMENT="172.20.0.0/16"
        ;;
    5)
        LAN_SEGMENT="172.21.0.0/16"
        ;;
    6)
        LAN_SEGMENT="172.22.0.0/16"
        ;;
    7)
        LAN_SEGMENT="172.23.0.0/16"
        ;;
    8)
        LAN_SEGMENT="172.24.0.0/16"
        ;;
    *)
        echo "Usage: $0 [1-8]" >&2
        exit 1
        ;;
esac

# Get the current IP address and netmask for the LAN-segment interface
CURRENT_IP=$(ip -o -4 addr show dev eth1 | awk '{print $4}' | cut -d/ -f1)
CURRENT_NETMASK=$(ip -o -4 addr show dev eth1 | awk '{print $4}' | cut -d/ -f2)

# Update the network interface configuration file with the new IP address and netmask
sudo sed -i "s/address $CURRENT_IP/address $LAN_SEGMENT/g" /etc/network/interfaces
sudo sed -i "s/netmask $CURRENT_NETMASK/netmask 255.255.0.0/g" /etc/network/interfaces

# Restart the networking service to apply the changes
sudo systemctl restart networking

# Display the new IP address and netmask for the LAN-segment interface
echo "New IP address for eth1: $(ip -o -4 addr show dev eth1 | awk '{print $4}')"
