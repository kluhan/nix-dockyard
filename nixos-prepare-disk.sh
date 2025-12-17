#!/usr/bin/env bash
set -euo pipefail

# =========================
# Configuration
# =========================
DISK="/dev/sda"
SWAP_SIZE_GB=8

GREEN="\033[1;32m"
RESET="\033[0m"

stage() {
  echo -e "${GREEN}>>> STAGE: $1 <<<${RESET}"
}

# =========================
# Safety Check
# =========================
stage "WARNING"
echo "WARNING: This will DESTROY ALL DATA on ${DISK}"
read -rp "Type YES to continue: " CONFIRM
if [[ "${CONFIRM}" != "YES" ]]; then
  echo "Aborted."
  exit 1
fi

# =========================
# Create MBR Partition Table
# =========================
stage "CREATE MBR PARTITION TABLE"
parted -s "${DISK}" mklabel msdos

# =========================
# Create Root Partition
# =========================
stage "CREATE ROOT PARTITION"
# Root: from 1MiB to disk minus swap
parted -s "${DISK}" mkpart primary ext4 1MiB "-${SWAP_SIZE_GB}GiB"

# =========================
# Set Boot Flag
# =========================
stage "SET BOOT FLAG"
parted -s "${DISK}" set 1 boot on

# =========================
# Create Swap Partition
# =========================
stage "CREATE SWAP PARTITION"
parted -s "${DISK}" mkpart primary linux-swap "-${SWAP_SIZE_GB}GiB" 100%

# =========================
# Summary
# =========================
stage "PARTITION TABLE RESULT"
parted "${DISK}" print

echo
echo "Partitioning complete."
echo "You can now proceed with formatting (mkfs.ext4, mkswap, etc.)."
