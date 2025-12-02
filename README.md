# nix-dockyard

NixDockyard is a small NixOS configuration intended to bootstrap Docker-focused homelab nodes.

## Development container

The repository ships with a [Dev Container](https://containers.dev/) definition in `.devcontainer/devcontainer.json`. Launching the repo in a compatible tool (VS Code, GitHub Codespaces, etc.) will:

- Boot a NixOS-based image from `ghcr.io/nix-community/nixos-devcontainer`
- Request privileged mode so systemd and Docker-style workloads function properly inside the container
- Run `nix flake check` followed by a build of `.#nixosConfigurations.myserver` to ensure the configuration evaluates and compiles
- Recommend the `direnv` and `nix-ide` extensions for a smoother workflow

Inside the dev container you can iterate locally and run additional commands such as:

```bash
nix flake show
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
```
