{ config, pkgs, ... }:

{
  # Shared user configuration
  users.users.kluhan = {
    isNormalUser = true;
    description = "Klaus Luhan";
    initialPassword = "admin";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA....DEIN_KEY"
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
  ];

  # Firewall & SSH
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
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
}