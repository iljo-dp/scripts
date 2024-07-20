{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = false; # Disable NetworkManager for static configuration
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.enp7s0 = {
    ipv4 = {
      addresses = [ {
        address = "172.19.0.1";
        prefixLength = 16;
      }];
      gateway = "172.19.0.1";
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure console keymap
  console.keyMap = "be-latin1";

  # Define user accounts
  users.mutableUsers = false; # Ensure no other users except those defined here
  users.users = {
    root = {
      initialPassword = "root"; # Replace with a secure password
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
    };

    iljodp = {
      isNormalUser = true;
      description = "Iljo De Poorter";
      initialPassword = "iljo"; # Replace with a secure password
      extraGroups = [ "zaakvoerder" ];
    };

    davidb = {
      isNormalUser = true;
      description = "David Beerens";
      initialPassword = "david123"; # Replace with a secure password
      extraGroups = [ "zaakvoerder" ];
    };

    tinevdv = {
      isNormalUser = true;
      description = "Tine Van de Velde";
      initialPassword = "tine123"; # Replace with a secure password
      extraGroups = [ "klantenrelaties" ];
    };

    jorisq = {
      isNormalUser = true;
      description = "Joris Quataert";
      initialPassword = "joris123"; # Replace with a secure password
      extraGroups = [ "administratie" ];
    };

    kimdw = {
      isNormalUser = true;
      description = "Kim De Waele";
      initialPassword = "kim123"; # Replace with a secure password
      extraGroups = [ "IT_medewerker" ];
    };
  };

  # Define user groups
  users.groups = {
    zaakvoerder = { };
    klantenrelaties = { };
    administratie = { };
    IT_medewerker = { };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    fish
    exa
    curl
    isc-dhcp-server
    bind
    ufw
    fail2ban
    clamav
    bmon
    starship
  ];

  # Copy Fish shell configuration
  environment.etc."fish/config.fish".text = builtins.readFile ./config.fish;

  # Install Starship prompt
  programs.starship.enable = true;

  # Configure ISC DHCP Server
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "ens36" ];
    settings = ''
      option domain-name "tisib.local";
      option domain-name-servers 172.19.0.1;

      default-lease-time 600;
      ddns-update-style none;

      authoritative;

      subnet 172.19.0.0 netmask 255.255.0.0 {
        range 172.19.0.0 172.19.0.50;
        option routers 172.18.0.1;
        option subnet-mask 255.255.0.0;
        default-lease-time 720;
      }
    '';
  };

  # Enable ClamAV just-in-time scanning
  security.pam.enable = true;
  services.clamav = {
    enable = true;
    freshclam = {
      enable = true;
      settings = {
        postFile = "sed -i -e 's/^Example/#Example/' /etc/clamav/freshclam.conf";
      };
    };
  };

  # Enable Fail2Ban
  services.fail2ban.enable = true;

  # Configure UFW (Uncomplicated Firewall)
  services.ufw = {
    enable = true;
    default = {
      incoming = "allow";
      outgoing = "allow";
    };
    allow = [ 
      { port = "22"; proto = "tcp"; }
    ];
    logging = "on";
  };

  # Enable Webmin
  systemd.services.webmin = {
    description = "Webmin";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.webmin}/bin/webmin";
      Restart = "always";
    };
  };

  # Enable the OpenSSH daemon
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 10000 ]; # For Webmin

  # Configure BIND DNS Server
  services.bind = {
    enable = true;
    config = ''
      options {
        directory "/var/bind";
        pid-file "/run/named/named.pid";
        statistics-file "/run/named/named.stats";
        memstatistics-file "/run/named/named.memstats";
        allow-query { any; };
        allow-recursion { any; };
        listen-on { any; };
        forwarders {
          8.8.8.8;
          8.8.4.4;
        };
      };
      
      zone "tisib.local" IN {
        type master;
        file "/var/bind/db.tisib.local";
        allow-update { none; };
      };
    '';
  };

  environment.etc."bind/db.tisib.local".text = ''
    $TTL    604800
    @       IN      SOA     ns.tisib.local. root.tisib.local. (
                          2         ; Serial
                     604800         ; Refresh
                      86400         ; Retry
                    2419200         ; Expire
                     604800 )       ; Negative Cache TTL
    ;
    @       IN      NS      ns.tisib.local.
    ns      IN      A       172.19.0.1
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
