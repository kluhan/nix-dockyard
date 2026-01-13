{
  description = "NixDockyard - Flake for a Docker homelab-server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }:
    {
      nixosConfigurations = {
        polaris = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./hardware-configurations/polaris.nix
            ./hosts/polaris/configuration.nix
            ./modules/docker.nix
            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.kluhan = import ./home.nix;
            }
          ];
        };
        vega = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hardware-configurations/vega.nix
            ./hosts/vega/configuration.nix
            ./modules/docker.nix
            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.kluhan = import ./home.nix;
            }
          ];
        };
      };
    };
}
