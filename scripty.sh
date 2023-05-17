#!/bin/bash

apt-get install fish exa curl isc-dhcp-server bind9 bind9-doc dnsutils
cp config.fish /root/.config/fish
source /root/.config/fish/config.fish

chsh root -s /usr/bin/fish

curl -Ss https://starship.rs/install.sh | sh


# Create groups
groupadd zaakvoerder
groupadd klantenrelaties
groupadd administratie
groupadd IT_medewerker

# Add users
# Prompt for the first user's name
read -p "Please enter the full name for user 1: " name1

# Split the name into first and last name parts
IFS=' ' read -ra name_parts <<< "$name1"
first_name="${name_parts[0]}"

# Generate the password for user 1
password="${first_name}123"
if [[ ${#name_parts[@]} -gt 1 ]]; then
    last_name_initial=$(echo "${name_parts[@]:1}" | awk -F' ' '{for (i=1;i<=NF;i++) print substr($i,1,1)}' | tr -d '\n' | tr '[:upper:]' '[:lower:]')
    password="${password}${last_name_initial}"
fi

# Create user 1 using the generated password
useradd -m -c "$name1" -s /bin/bash -g zaakvoerder -p $(openssl passwd -1 "$password") "${first_name,,}${last_name_initial,,}"

# Prompt for the second user's name
read -p "Please enter the full name for user 2: " name2

# Split the name into first and last name parts for user 2
IFS=' ' read -ra name_parts <<< "$name2"
first_name="${name_parts[0]}"

# Generate the password for user 2
password="${first_name}123"
if [[ ${#name_parts[@]} -gt 1 ]]; then
    last_name_initial=$(echo "${name_parts[@]:1}" | awk -F' ' '{for (i=1;i<=NF;i++) print substr($i,1,1)}' | tr -d '\n' | tr '[:upper:]' '[:lower:]')
    password="${password}${last_name_initial}"
fi

# Create user 2 using the generated password
useradd -m -c "$name2" -s /bin/bash -g zaakvoerder -p $(openssl passwd -1 "$password") "${first_name,,}${last_name_initial,,}"

# Change ownership of the home directories to the users
chown -R "${first_name,,}${last_name_initial,,}":zaakvoerder /home/"${first_name,,}${last_name_initial,,}"


useradd -m -c "Tine Van de Velde" -s /bin/bash -g klantenrelaties -p $(openssl passwd -1 tine123) tinevdv
useradd -m -c "Joris Quataert" -s /bin/bash -g administratie -p $(openssl passwd -1 joris123) jorisq
useradd -m -c "Kim De Waele" -s /bin/bash -g IT_medewerker -p $(openssl passwd -1 kim123) kimdw

# Change ownership of the home directories to the users
chown -R tinevdv:klantenrelaties /home/tinevdv
chown -R jorisq:administratie /home/jorisq
chown -R kimdw:IT_medewerker /home/kimdw


file_path="/etc/network/interfaces"
new_content=$(cat <<EOF
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
cp "$file_path" "$file_path.bak"

# Write the new content to the file
echo "$new_content" > "$file_path "

#netwerkkaart instellen
the_path="/etc/default/isc-dhcp-server"
new_content2=$(cat <<EOF

INTERFACESv4="ens36"
EOF
)

# Backup the original file (optional but recommended)
cp "$the_path" "$the_path.bak"

# Write the new content to the file

echo "$new_content2" > "$the_path"
