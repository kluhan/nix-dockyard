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
# RAM in MiB (guaranteed integer)
RAM_MB=$(free -m | awk '/Mem:/ {print $2 + 0}')
SWAP_MB=$((RAM_MB * SWAP_FACTOR))
echo "Detected RAM: ${RAM_MB}MiB → swap will be ${SWAP_MB}MiB"

stage "DETECT DISK SIZE"
# Read disk size in MiB reliably
DISK_BYTES=$(lsblk -bno SIZE "$DISK")
DISK_MB=$((DISK_BYTES / 1024 / 1024))
echo "Disk size: ${DISK_MB}MiB"

# Safety check: ensure variables are numeric
[[ "$DISK_MB" =~ ^[0-9]+$ ]] || { echo "ERROR: DISK_MB invalid"; exit 1; }
[[ "$SWAP_MB" =~ ^[0-9]+$ ]] || { echo "ERROR: SWAP_MB invalid"; exit 1; }

# Compute root end
ROOT_END_MB=$((DISK_MB - SWAP_MB))
ROOT_END_MB=$((ROOT_END_MB > 0 ? ROOT_END_MB : 1))  # never negative or zero

echo "Root partition will end at ${ROOT_END_MB}MiB"

stage "WIPE DISK"
parted -s "$DISK" mklabel gpt

stage "CREATE PARTITIONS"

# EFI: 1MiB → 512MiB
parted -s "$DISK" mkpart ESP fat32 1MiB 512MiB

# Root: 512MiB → ROOT_END_MB MiB
parted -s "$DISK" mkpart root ext4 512MiB "${ROOT_END_MB}MiB"

# Swap: end of root → full disk
parted -s "$DISK" mkpart swap linux-swap "${ROOT_END_MB}MiB" 100%

# Mark ESP flag
parted -s "$DISK" set 1 esp on

stage "SHOW PARTITION TABLE"
parted "$DISK" print

stage "FORMAT PARTITIONS"
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 "${DISK}2"
mkswap "${DISK}3"
swapon "${DISK}3"

stage "MOUNT PARTITIONS"
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

echo "✅ Partitions created, formatted, and mounted successfully."
