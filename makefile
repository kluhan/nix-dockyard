polaris:
	sudo nixos-rebuild switch --flake .#polaris

vega:
	sudo nixos-rebuild switch --flake .#vega

pull:
	git pull https://github.com/kluhan/nix-dockyard.git