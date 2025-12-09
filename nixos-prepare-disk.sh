#!/bin/bash
set -euo pipefail

GREEN="\033[1;32m"
RESET="\033[0m"

stage() {
    echo -e "${GREEN}<<< STAGE - $1 >>>${RESET}"
}

DISK="/dev/sda"   # Change if needed
SWAP_FACTOR=1     # swap = RAM * SWAP_FACTOR

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
SWAP_GB=$(( (SWAP_MB + 1023) / 1024 ))   # Convert to GiB (rounded up)

echo "Detected RAM: ${RAM_MB}MiB → swap will be ${SWAP_GB}GiB"

stage "WIPE DISK"
# Create GPT
parted -s "$DISK" mklabel gpt

stage "CREATE PARTITIONS (UEFI according to NixOS manual)"

# 1) EFI System Partition: 1MiB → 512MiB
parted -s "$DISK" mkpart ESP fat32 1MiB 512MiB

# 2) Root Partition: 512MiB → (end - swap)
parted -s "$DISK" mkpart root ext4 512MiB "-${SWAP_GB}GiB"

# 3) Swap Partition: final part of the disk
parted -s "$DISK" mkpart swap linux-swap "-${SWAP_GB}GiB" 100%

# Mark ESP
parted -s "$DISK" set 1 esp on

stage "SHOW PARTITION TABLE"
parted "$DISK" -- print

stage "FORMAT PARTITIONS"
mkfs.fat -F32 "${DISK}1"             # EFI
mkfs.ext4 "${DISK}2"                 # Root
mkswap "${DISK}3"                    # Swap
swapon "${DISK}3"

stage "MOUNT PARTITIONS"
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

echo "✅ Partitions created, formatted, and mounted successfully."
