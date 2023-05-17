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
apt-get install -y fish exa curl isc-dhcp-server bind9 bind9-doc dnsutils

# Copy Fish shell configuration
cp config.fish /root/.config/fish
source /root/.config/fish/config.fish

# Change the default shell for root user to Fish
chsh root -s /usr/bin/fish

# Install Starship prompt
curl -Ss https://starship.rs/install.sh | sh

# Create groups
for group in zaakvoerder klantenrelaties administratie IT_medewerker; do
    groupadd "$group"
done

# Function to create user
create_user() {
    local username=$1
    local full_name=$2
    local group=$3
    local password="${username}123"
    local last_name_initial

    IFS=' ' read -ra name_parts <<< "$full_name"
    first_name="${name_parts[0]}"

    if [[ ${#name_parts[@]} -gt 1 ]]; then
        last_name_initial=$(echo "${name_parts[@]:1}" | awk -F' ' '{for (i=1;i<=NF;i++) print substr($i,1,1)}' | tr -d '\n' | tr '[:upper:]' '[:lower:]')
        password="${password}${last_name_initial}"
    fi

    useradd -m -c "$full_name" -s /bin/bash -g "$group" -p $(openssl passwd -1 "$password") "${username,,}${last_name_initial,,}"
    chown -R "${username,,}${last_name_initial,,}":"$group" "/home/${username,,}${last_name_initial,,}"
}

# Prompt for user creation
for i in 1 2; do
    read -p "Please enter the full name for user $i: " name
    create_user "user$i" "$name" "zaakvoerder"
done

# Create additional users
create_user "tinevdv" "Tine Van de Velde" "klantenrelaties"
create_user "jorisq" "Joris Quataert" "administratie"
create_user "kimdw" "Kim De Waele" "IT_medewerker"

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
