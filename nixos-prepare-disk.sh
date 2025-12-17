#!/usr/bin/env bash
set -euo pipefail

DISK="/dev/sda"
ROOT_LABEL="nixos"
SWAP_LABEL="swap"
SWAP_SIZE_GB=8
MOUNT_POINT="/mnt"

GREEN="\033[1;32m"
RESET="\033[0m"

stage() {
  echo -e "${GREEN}>>> STAGE: $1 <<<${RESET}"
}

# -------------------------
# Safety confirmation
# -------------------------
stage "WARNING"
echo "THIS WILL ERASE ALL DATA ON ${DISK}"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || exit 1

# -------------------------
# Partitioning (MBR / BIOS)
# -------------------------
stage "CREATE MBR PARTITION TABLE"
parted "$DISK" --script "mklabel msdos"

stage "CREATE ROOT PARTITION"
parted "$DISK" --script \
  "mkpart primary ext4 1MiB -${SWAP_SIZE_GB}GiB"

stage "SET BOOT FLAG"
parted "$DISK" --script "set 1 boot on"

stage "CREATE SWAP PARTITION"
parted "$DISK" --script \
  "mkpart primary linux-swap -${SWAP_SIZE_GB}GiB 100%"

# Ensure kernel sees new partitions
stage "RELOAD PARTITION TABLE"
partprobe "$DISK"
sleep 2

# -------------------------
# Formatting
# -------------------------
stage "FORMAT ROOT PARTITION (ext4)"
mkfs.ext4 -L "$ROOT_LABEL" "${DISK}1"

stage "FORMAT SWAP PARTITION"
mkswap -L "$SWAP_LABEL" "${DISK}2"

# -------------------------
# Mounting
# -------------------------
stage "MOUNT ROOT FILESYSTEM"
mkdir -p "$MOUNT_POINT"
mount "/dev/disk/by-label/${ROOT_LABEL}" "$MOUNT_POINT"

# -------------------------
# Summary
# -------------------------
stage "FINAL STATE"
lsblk -f "$DISK"
df -h "$MOUNT_POINT"
swapon --show

echo
echo "System prepared and mounted at ${MOUNT_POINT}."
echo "You can now continue with nixos-generate-config or nixos-install."
