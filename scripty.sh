#!/bin/bash

# Copyright (C) 2023 Iljo De Poorter
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# You can contact me at my electronic mail at Iljodp@gmail.com

# Install required packages
apt-get update -y && apt upgrade -y
apt-get install -y fish exa curl isc-dhcp-server bind9 bind9-doc

# Copy Fish shell configuration
# mkdir -p /root/.config/fish
# cp config.fish /root/.config/fish/config.fish

# Change the default shell for root user to Fish
# chsh -s /usr/bin/fish root

# Install Starship prompt
# curl -fsSL https://starship.rs/install.sh | bash

# Create groups
groupadd zaakvoerder
groupadd klantenrelaties
groupadd administratie
groupadd IT_medewerker

# Function to create user
create_user() {
    local username=$1
    local full_name=$2
    local group=$3
    local password="iljo123"
    local login_name

    IFS=' ' read -ra name_parts <<< "$full_name"
    login_name="${name_parts[0],,}"

    useradd -m -c "$full_name" -s /bin/bash -g "$group" -p "$(openssl passwd -1 "$password")" "$login_name"
    chown -R "$login_name":"$group" "/home/$login_name"
}

# Prompt for user creation
for i in 1 2; do
    read -r -p "Please enter the full name for user $i: " name
    create_user "user$i" "$name" "zaakvoerder"
done

# Create additional users
useradd -m -c "Tine Van de Velde" -s /bin/bash -g klantenrelaties -p $(openssl passwd -1 tine123) tinevdv
useradd -m -c "Joris Quataert" -s /bin/bash -g administratie -p $(openssl passwd -1 joris123) jorisq
useradd -m -c "Kim De Waele" -s /bin/bash -g IT_medewerker -p $(openssl passwd -1 kim123) kimdw

# Configure network interfaces
interfaces_file="/etc/network/interfaces"
interfaces_content=$(cat <<EOF
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback

allow-hotplug ens33
allow-hotplug ens36
auto ens33

iface ens33 inet dhcp

iface ens36 inet static
   address 172.19.0.1
   netmask 255.255.0.0
   broadcast 172.19.0.255
   gateway 172.19.0.1
EOF
)

# Backup the original file (optional but recommended)
cp "$interfaces_file" "$interfaces_file.bak"

# Write the new content to the file
echo "$interfaces_content" > "$interfaces_file"

# Configure ISC DHCP Server
dhcp_server_file="/etc/default/isc-dhcp-server"
dhcp_server_content=$(cat <<EOF

INTERFACESv4="ens36"
EOF
)

# Backup the original file (optional but recommended)
cp "$dhcp_server_file" "$dhcp_server_file.bak"

# Write the new content to the file
echo "$dhcp_server_content" > "$dhcp_server_file"


# Configure DHCPD Server
dhcpd_server_file="/etc/dhcp/dhcpd.conf"
dhcpd_server_content=$(cat <<EOF

option domain-name "tisib.local";
option-domain-name-server 172.19.0.1;

default-lease-time 600;
ddns-update-style none;

authoritative;

subnet 172.19.0.0 netmask 255.255.0.0 {
     range 172.19.0.0 172.19.0.50;
     option routers 172.18.0.1;
     option subnet-mask 255.255.0.0;
     default-lease-time 720;
}
EOF
)

# Backup the original file (optional but recommended)
cp "$dhcpd_server_file" "$dhcpd_server_file.bak"

# Write the new content to the file
echo "$dhcpd_server_content" > "$dhcpd_server_file"


