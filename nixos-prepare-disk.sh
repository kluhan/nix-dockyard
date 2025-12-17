#!/usr/bin/env bash
set -euo pipefail

DISK="/dev/sda"
ROOT_LABEL="nixos"
SWAP_LABEL="swap"
SWAP_SIZE_GB=8

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
# Summary
# -------------------------
stage "FINAL RESULT"
lsblk -f "$DISK"

echo
echo "Partitioning and formatting complete."
echo "Root label : ${ROOT_LABEL}"
echo "Swap label : ${SWAP_LABEL}"
echo "You can now mount /dev/disk/by-label/${ROOT_LABEL} and continue installation."
