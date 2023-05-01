#!/bin/bash

# Create groups
sudo groupadd zaakvoerder
sudo groupadd klantenrelaties
sudo groupadd administratie
sudo groupadd IT_medewerker

# Add users
sudo useradd -m -c "Iljo De Poorter" -s /bin/bash -g zaakvoerder -p $(openssl passwd -1 iljo123) iljodp
sudo useradd -m -c "David Beerens" -s /bin/bash -g zaakvoerder -p $(openssl passwd -1 david123) davidB
sudo useradd -m -c "Tine Van de Velde" -s /bin/bash -g klantenrelaties -p $(openssl passwd -1 tine123) tinevdv
sudo useradd -m -c "Joris Quataert" -s /bin/bash -g administratie -p $(openssl passwd -1 joris123) jorisq
sudo useradd -m -c "Kim De Waele" -s /bin/bash -g IT_medewerker -p $(openssl passwd -1 kim123) kimdw

# Change ownership of the home directories to the users
sudo chown -R iljodp:zaakvoerder /home/iljodp
sudo chown -R davidB:zaakvoerder /home/davidB
sudo chown -R tinevdv:klantenrelaties /home/tinevdv
sudo chown -R jorisq:administratie /home/jorisq
sudo chown -R kimdw:IT_medewerker /home/kimdw
