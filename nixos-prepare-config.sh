set -euo pipefail

# Clone the configuration
git clone https://github.com/kluhan/nixos-dockyard.git /mnt/etc/nixos

# Generate hardware configuration for the target system
nixos-generate-config --show-hardware-config >> /mnt/etc/nixos/hardware-configuration.nix

# Ensure correct permissions
chown nixos hardware-configuration.nix
chgrp users hardware-configuration.nix
