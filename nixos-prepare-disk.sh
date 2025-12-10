#!/bin/bash
set -euo pipefail

GREEN="\033[1;32m"
RESET="\033[0m"

stage() {
    echo -e "${GREEN}<<< STAGE - $1 >>>${RESET}"
}

# -------------------------
# CONFIGURATION
# -------------------------
DISK="/dev/sda"        # CHANGE if /dev/nvme0n1 etc.
SWAP_FACTOR=1          # swap = RAM * factor
EFI_START="1MiB"
EFI_END="512MiB"
ROOT_START="$EFI_END"
# -------------------------
stage "DETECT RAM"
RAM_MB=$(free -m | awk '/Mem:/ {print $2 + 0}')
SWAP_MB=$((RAM_MB * SWAP_FACTOR))
echo "Detected RAM: ${RAM_MB}MiB → swap will be ${SWAP_MB}MiB"

stage "DETECT DISK SIZE"
DISK_BYTES=$(lsblk -bno SIZE "$DISK" || echo 0)
DISK_MB=$((DISK_BYTES / 1024 / 1024))
if [ "$DISK_MB" -le 0 ]; then
    echo "ERROR: Could not determine disk size for $DISK"
    exit 1
fi
echo "Disk size: ${DISK_MB}MiB"

stage "CALCULATE PARTITION BOUNDARIES"
EFI_START_MB=1
EFI_END_MB=512

ROOT_START_MB=$EFI_END_MB
ROOT_END_MB=$((DISK_MB - SWAP_MB))

if [ "$ROOT_END_MB" -le "$ROOT_START_MB" ]; then
    echo "ERROR: Computed root partition would be empty or negative."
    exit 1
fi

SWAP_START_MB=$ROOT_END_MB
SWAP_END_MB=$DISK_MB

echo "EFI : ${EFI_START_MB}MiB  → ${EFI_END_MB}MiB"
echo "Root: ${ROOT_START_MB}MiB → ${ROOT_END_MB}MiB"
echo "Swap: ${SWAP_START_MB}MiB → ${SWAP_END_MB}MiB"

stage "WIPE DISK"
parted -s "$DISK" mklabel gpt

stage "CREATE PARTITIONS (UEFI, absolute MiB)"

# 1) EFI: 1MiB → 512MiB
parted -s "$DISK" unit MiB mkpart ESP fat32 \
    "$EFI_START_MB" "$EFI_END_MB"
parted -s "$DISK" set 1 esp on

# 2) Root: 512MiB → ROOT_END_MB
parted -s "$DISK" unit MiB mkpart root ext4 \
    "$ROOT_START_MB" "$ROOT_END_MB"

# 3) Swap: ROOT_END_MB → DISK_MB
parted -s "$DISK" unit MiB mkpart swap linux-swap \
    "$SWAP_START_MB" "$SWAP_END_MB"

stage "SHOW PARTITIONS"
parted "$DISK" print

stage "FORMAT PARTITIONS"
mkfs.fat -F32 "${DISK}1"      # EFI
mkfs.ext4 "${DISK}2"         # Root
mkswap "${DISK}3"            # Swap
swapon "${DISK}3"

stage "MOUNT PARTITIONS"
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot
echo "✅ Partitions created, formatted, and mounted successfully."
