{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
  ];
  
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Networking.
  networking.hostName = "vega";

  system.stateVersion = "25.11";
}
