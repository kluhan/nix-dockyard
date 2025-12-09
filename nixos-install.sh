#!/usr/bin/env bash
set -euo pipefail

# Usage: ./install.sh <hostname>
# Example: ./install.sh polaris

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi

HOSTNAME="$1"
GREEN="\033[1;32m"
RESET="\033[0m"

echo -e "${GREEN}<<< Installing NixOS for host: $HOSTNAME >>>${RESET}"
nixos-install --flake ".#$HOSTNAME"
