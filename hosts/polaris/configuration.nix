{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
  ];

  networking.hostName = "polaris";
  system.stateVersion = "24.05";
}
