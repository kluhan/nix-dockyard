{
  description = "NixDockyard - Flake for a Docker homelab-server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    {
      nixosConfigurations = {
        polaris = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ../hardware-configuration.nix
            ./hosts/polaris/configuration.nix
            ./modules/docker.nix
          ];
        };
      };
    };
}