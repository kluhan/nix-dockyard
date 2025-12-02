{ config, pkgs, ... }:

{
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

  # Automatic updates
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    allowReboot = true;
  };

  # Limit Journald size
  services.journald.extraConfig = "SystemMaxUse=200M";

  # Networking
  networking.useDHCP = false;
  networking.interfaces.ens18.useDHCP = true; # often ens18 on Proxmox
}
