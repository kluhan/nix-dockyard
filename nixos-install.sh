#!/usr/bin/env bash
set -euo pipefail

# Usage: ./install.sh <hostname>
# Example: ./install.sh polaris

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi

HOSTNAME="$1"

echo ">>> Installing NixOS for host: $HOSTNAME"

nixos-install --flake ".#$HOSTNAME"
