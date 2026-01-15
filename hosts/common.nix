{ config, pkgs, ... }:

{
  # Setup auxiliary group 'stackops' for giving users access to /opt/stacks/ 
  users.groups.stackops = {};
  # Create /opt/stacks/ with group 'stackops' and ensure proper permissions
  systemd.tmpfiles.rules = [
    "d /opt/stacks 2774 root stackops -"
    "d /etc/komodo 2774 root docker -"
  ];

  # Shared user configuration
  users.users.kluhan = {
    isNormalUser = true;
    description = "Klaus Luhan";
    initialPassword = "admin";
    extraGroups = [ "wheel" "networkmanager" "docker" "stackops"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICd7YIOX1aQ0GJj9FPxJt0m73dmYKZYoNo5Y5kggSm3Q"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

# Time zone
  time.timeZone = "Europe/Berlin";

  # Packages
  environment.systemPackages = with pkgs; [
    nano
    htop
    git
    curl
    wget
    jq
    gnumake
  ];

  # Firewall & SSH
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
        22
      ];
    allowedUDPPorts = [];
  };

  services.fail2ban.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "kluhan" ];
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

}
