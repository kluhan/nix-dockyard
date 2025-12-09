#!/bin/bash
set -euo pipefail

GREEN="\033[1;32m"
RESET="\033[0m"

stage() {
    echo -e "${GREEN}<<< STAGE - $1 >>>${RESET}"
}

DISK="/dev/sda"
SWAP_FACTOR=1

stage "WARNING"
echo "WARNING: All data on $DISK will be destroyed!"
read -p "Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

stage "DETECT RAM"
RAM_MB=$(free -m | awk '/Mem:/ {print $2}')
SWAP_MB=$((RAM_MB * SWAP_FACTOR))
echo "Detected RAM: ${RAM_MB}MiB → swap will be ${SWAP_MB}MiB"

stage "DETECT DISK SIZE"
DISK_MB=$(lsblk -bno SIZE "$DISK")
DISK_MB=$((DISK_MB / 1024 / 1024))   # convert bytes → MiB
echo "Disk size: ${DISK_MB}MiB"

# Root ends where swap begins
ROOT_END_MB=$((DISK_MB - SWAP_MB))

echo "Root partition will end at ${ROOT_END_MB}MiB"

stage "WIPE DISK"
parted -s "$DISK" mklabel gpt

stage "CREATE PARTITIONS"

# EFI partition: 1MiB → 512MiB
parted -s "$DISK" mkpart ESP fat32 1MiB 512MiB

# Root: 512MiB → ROOT_END_MB
parted -s "$DISK" mkpart root ext4 512MiB "${ROOT_END_MB}MiB"

# Swap: ROOT_END_MB → end
parted -s "$DISK" mkpart swap linux-swap "${ROOT_END_MB}MiB" 100%

# Set ESP flag
parted -s "$DISK" set 1 esp on

stage "SHOW PARTITION TABLE"
parted "$DISK" print

stage "FORMAT PARTITIONS"
mkfs.fat -F32 "${DISK}1"           # ESP
mkfs.ext4 "${DISK}2"               # Root
mkswap "${DISK}3"                  # Swap
swapon "${DISK}3"

stage "MOUNT PARTITIONS"
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

echo "✅ Partitions created, formatted, and mounted successfully."
