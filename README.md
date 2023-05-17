Dit is een shell script dat verschillende systeemconfiguratie taken en gebruikersbeheer uitvoert. Het is ontworpen om te worden uitgevoerd met rootrechten. Het ultieme doel van dit script is het helpen bij de configuratie van onze gip

WAT HET NU AL DOET
DE 3 VEREISTE GEBRUIKERS TOEVOEGEN
EEN TWEEDE NETWERKKAART CONFIGUREREN (ERVAN UITGAANDE DAT HET ENS36IS), DEZE IS WEL NOGSTEEDS HARDCODED NAAR 172.19.0.1
ALLE HUIDIGE VEREISTE PAKKETEN INSTALLEREN
DHCP VOLLEDIG CONFIGUREREN.



Vereisten
het is absoluut nodig dat je 'git' hebt geinstaleerd
apt install git

Het is ook nodig dat je in vmware een tweede netwerk kaart hebt die staat ingesteld op lan segment, met dan ook een lansegment 

Zorg ervoor dat je de juiste rechten hebt om systeemcommando's met verhoogde privileges uit te voeren. Het script gaat ervan uit dat je administratieve toegang(root)- hebt tot het systeem

Hoe te gebruiken?

ga eerst naar je home folder

cd ~ 

Kloon of download het shell script naar je lokale machine.

git clone https://github.com/iljo-dp/scripts/

cd scripts

chmod +x scripty.sh

sed -i 's/\r//' scripty.sh 

bash ./script.sh

Functionaliteit

Het script voert de volgende taken uit:

    Installeert de volgende softwarepakketten: fish, exa, curl, isc-dhcp-server, bind9, bind9-doc en dnsutils.
    Installeert de Starship-prompt.
    Maakt groepen aan: zaakvoerder, klantenrelaties, administratie en IT_medewerker.
    Voegt gebruikers toe aan de aangemaakte groepen en genereert wachtwoorden op basis van de ingevoerde namen.
    Wijzigt eigenaarschap van de home directories van de gebruikers.
    Vervangt de inhoud van het bestand /etc/network/interfaces door specifieke configuratiegegevens.
    Om zo een tweede netwerk kaart(lan seggment) te voorzien van een ipadress,

Let op: Zorg ervoor dat je een back-up hebt van belangrijke bestanden voordat je het script uitvoert. Het script kan bestanden wijzigen en zelfs vervangen.

Opmerkingen

    Het script kan enige tijd duren om te voltooien, afhankelijk van de systeemconfiguratie en het aantal gebruikers dat wordt toegevoegd.
    Zorg ervoor dat je de vereiste informatie correct invoert wanneer daarom wordt gevraagd.
    Controleer de gegenereerde wachtwoorden en pas ze indien nodig aan voor betere beveiliging.

Bijdragen

Je kunt bijdragen aan dit script leveren door verbeteringen voor te stellen of eventuele problemen te melden via de GitHub-pagina van dit project.

IK ZAL NIET REAGEREN OP DISCORD BERICHTEN OF MAILS, VOOR VRAGEN EN BIJDRAGEN AAN DE SCRIPT BEN JE VERPLICHT DE GITHUB PLATFORM TE GEBRUIKEN.
