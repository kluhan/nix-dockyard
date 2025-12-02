{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;

    # Automatic Docker prune
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
  };

  # docker-compose comes automatically from pkgs
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
