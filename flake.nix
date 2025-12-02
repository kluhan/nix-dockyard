{
  description = "NixDockyard - Setup for a Docker homelab-server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    {
      nixosConfigurations = {
        myserver = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./hosts/polaris/configuration.nix
            ./modules/base.nix
            ./modules/security.nix
            ./modules/docker.nix
          ];
        };
      };
    };
}