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
DISK="/dev/sda"        # CHANGE THIS!!
SWAP_SIZE="8GiB"       # manual, stable, no arithmetic
EFI_START="1MiB"
EFI_END="512MiB"
ROOT_START="$EFI_END"
# ROOT_END = end of disk minus swap — done by parted using percentage
# -------------------------

stage "WARNING"
echo "WARNING: All data on $DISK will be destroyed!"
read -p "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || exit 1

stage "WIPE DISK"
parted -s "$DISK" mklabel gpt

stage "CREATE PARTITIONS (UEFI)"

# 1) EFI partition
parted -s "$DISK" mkpart ESP fat32 $EFI_START $EFI_END
parted -s "$DISK" set 1 esp on

# 2) Root (512MiB → 100% - swap)
parted -s "$DISK" mkpart root ext4 $ROOT_START "-$SWAP_SIZE"

# 3) Swap (final SWAP_SIZE of disk)
parted -s "$DISK" mkpart swap linux-swap "-$SWAP_SIZE" 100%

stage "SHOW PARTITIONS"
parted "$DISK" print

stage "FORMAT PARTITIONS"
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 "${DISK}2"
mkswap "${DISK}3"
swapon "${DISK}3"

stage "MOUNT"
mount "${DISK}2" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot

echo "✅ Done — partitions created, formatted, and mounted."
