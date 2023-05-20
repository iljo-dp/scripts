#!/bin/bash

# Install required packages
apt-get update
apt-get upgrade -y
apt-get install -y fish exa curl isc-dhcp-server bind9 bind9-doc ufw fail2ban clamav bmon

# Copy Fish shell configuration
mkdir -p /root/.config/fish
cp config.fish /root/.config/fish/config.fish

# Change the default shell for root user to Fish
chsh -s /usr/bin/fish root

# Install Starship prompt
curl -fsSL https://starship.rs/install.sh | bash

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

    # Generate login name and password
    local login_name="${full_name%% *}"
    local password="${login_name,,}123"

    # Create user and set password
    useradd -m -c "$full_name" -s /bin/bash -g "$group" -p "$(mkpasswd -m sha-512 "$password")" "$login_name"
    chown -R "$login_name":"$group" "/home/$login_name"
}

# Prompt for user creation
for i in 1 2; do
    read -r -p "Please enter the full name for user $i: " name
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

# Backup the original file
cp "$interfaces_file" "$interfaces_file.bak"

# Write the new content to the file
echo "$interfaces_content" > "$interfaces_file"

# Configure ISC DHCP Server
dhcp_server_file="/etc/default/isc-dhcp-server"
dhcp_server_content=$(cat <<EOF
INTERFACESv4="ens36"
EOF
)

# Backup the original file
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

# Backup the original file
cp "$dhcpd_server_file" "$dhcpd_server_file.bak"

# Write the new content to the file
echo "$dhcpd_server_content" > "$dhcpd_server_file"

# Enable ClamAV just-in-time scanning
setsebool -P clamd_use_jit 1

# Comment out the Example line in freshclam.conf
sed -i -e "s/^Example/#Example/" /etc/clamav/freshclam.conf

# Enable ClamAV and auditd services
systemctl enable clamav auditd

# Download and install Webmin
mkdir -p /usr/local/webmin
cd /usr/local/webmin
wget https://prdownloads.sourceforge.net/webadmin/webmin-2.021.tar.gz
tar -xvzf webmin-2.021
cd webmin-2.021
mkdir -p /usr/local/webmin/webmin

# Display instructions for Webmin configuration
echo "For Webmin, you need to provide certain settings.
Press Enter to use the default directory, logfile, path to Perl, and server port.
For the login defaults, choose 'admin' as the login name with the password 'school99' and set 'start on boot time' to 'yes'.
Press Enter to continue."

read

echo "Continuing...."

./setup.sh /usr/local/webmin/webmin

# Enable and start Webmin service
systemctl enable webmin
systemctl start webmin

echo "To access your Webmin portal, go to the IP address of ens33 followed by :10000, e.g., 192.168.2.24:10000."

# Network Security Configuration
echo "Network security configuration..."

# Enable and start fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Configure UFW (Uncomplicated Firewall)
ufw --force enable
ufw limit 22/tcp
ufw default allow incoming
ufw default allow outgoing
ufw allow in on lo
ufw allow out on lo
ufw logging on
systemctl enable --now ufw

echo "Script execution completed."
