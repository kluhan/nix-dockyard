{ config, pkgs, ... }:

{
  # Shared user configuration
  users.users.klaus = {
    isNormalUser = true;
    description = "Klaus";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA....DEIN_KEY"
    ];
  };

  # Setup Bootloader for BIOS
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
}
