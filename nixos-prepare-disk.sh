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

stage "WARNING"
echo "WARNING: All data on $DISK will be destroyed!"
read -p "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || exit 1

stage "DETECT RAM"
# RAM in MiB (numeric only)
RAM_MB=$(free -m | awk '/Mem:/ {print $2 + 0}')
SWAP_MB=$(( RAM_MB * SWAP_FACTOR ))

echo "Detected RAM: ${RAM_MB} MiB"
echo "Swap size:    ${SWAP_MB} MiB"

# final suffix for parted
SWAP_END="${SWAP_MB}MiB"

stage "WIPE DISK"
parted -s "$DISK" mklabel gpt

stage "CREATE PARTITIONS (UEFI)"

# 1) EFI partition (1 → 512 MiB)
parted -s "$DISK" mkpart ESP fat32 $EFI_START $EFI_END
parted -s "$DISK" set 1 esp on

# 2) Root partition until disk_end - swap
parted -s "$DISK" mkpart root ext4 $ROOT_START "-$SWAP_END"

# 3) Swap partition at end of disk
parted -s "$DISK" mkpart swap linux-swap "-$SWAP_END" 100%

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
echo "   Disk: $DISK"
echo "   Swap: $SWAP_MB MiB"
