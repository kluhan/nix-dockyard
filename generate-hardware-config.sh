set -euo pipefail

# Generate hardware configuration for the target system
nixos-generate-config --root /mnt

# Remove the default configuration file if it exists
if [ -f /mnt/etc/nixos/configuration.nix ]; then
    rm /mnt/etc/nixos/configuration.nix
fi

# Move hardware-configuration.nix to the local project directory
if [ -f /mnt/etc/nixos/hardware-configuration.nix ]; then
    mv /mnt/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
else
    echo "Error: hardware-configuration.nix not found!"
    exit 1
fi

# Ensure correct permissions
chown nixos hardware-configuration.nix
chgrp users hardware-configuration.nix
