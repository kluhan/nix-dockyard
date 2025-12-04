#!/bin/bash
set -euo pipefail

GREEN="\033[1;32m"
RESET="\033[0m"

stage() {
    echo -e "${GREEN}<<<< STAGE - $1 >>>>${RESET}"
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
echo "Detected RAM: ${RAM_MB}MiB → swap will be ${SWAP_MB}MiB"

stage "WIPE DISK"
sgdisk -Z "$DISK"

stage "CREATE PARTITIONS"
# Partition 1: EFI Boot (512MiB)
sgdisk -n1:0:+512M -t1:EF00 -c1:"EFI Boot" "$DISK"

# Partition 2: BIOS GRUB (32MiB)
sgdisk -n2:0:+32M -t2:EF02 -c2:"BIOS GRUB" "$DISK"

# Partition 3: Swap (dynamic size)
sgdisk -n3:0:+${SWAP_MB}M -t3:8200 -c3:"Swap" "$DISK"

# Partition 4: Root (rest of disk)
sgdisk -n4:0:0 -t4:8300 -c4:"NixOS Root" "$DISK"

stage "FORMAT PARTITIONS"
mkfs.fat -F32 "${DISK}1"             # EFI
mkswap "${DISK}3"                   # Swap
swapon "${DISK}3"
mkfs.ext4 "${DISK}4"                # Root

stage "MOUNT PARTITIONS"
mount "${DISK}4" /mnt
mkdir -p /mnt/boot
mount -o umask=077 "${DISK}1" /mnt/boot

stage "DONE"
echo "✅ Partitions created, formatted, and mounted successfully."
