{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;

    # Automatic Docker prune
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
  };


  networking.firewall.allowedTCPPorts = [ 80 443 2377 7946 ];
  networking.firewall.allowedUDPPorts = [ 7946 4789 ];

  # docker-compose comes automatically from pkgs
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
