# nix-dockyard

nix-dockyard is a small Nix flake-driven configuration collection for NixOS hosts and Home Manager setups. It contains host configurations, hardware-specific overlays, and reusable Nix modules (e.g., Docker configuration).

**Quick Start**

- **Prerequisites:** Install Nix with flakes enabled and have root access on target NixOS hosts.
- **Explore available outputs:**

```bash
nix flake show
```

- **Apply a host configuration (example `polaris`):**

```bash
sudo nixos-rebuild switch --flake .#polaris
```

- **Apply Home Manager (example):**

```bash
home-manager switch --flake .#<your-host-or-user>
```

**Repository Layout**

- **`flake.nix`**: Top-level flake entrypoint for building host and home configurations.
- **`home.nix`**: Root Home Manager configuration.
- **`modules/docker.nix`**: Reusable Docker/Nix module used by host configurations.
- **`hosts/common.nix`**: Common settings shared across hosts.
- **`hosts/polaris/configuration.nix`**: Example NixOS host configuration for `polaris`.
- **`hardware-configurations/polaris.nix`**: Hardware-specific options for the `polaris` machine.

See these files in the tree for details: [flake.nix](flake.nix), [home.nix](home.nix), [modules/docker.nix](modules/docker.nix), [hosts/common.nix](hosts/common.nix), [hosts/polaris/configuration.nix](hosts/polaris/configuration.nix), [hardware-configurations/polaris.nix](hardware-configurations/polaris.nix).

**Goals & Scope**

- Provide reproducible NixOS host configurations for personal machines.
- Keep modules small and composable (e.g., Docker support isolated in `modules/docker.nix`).

