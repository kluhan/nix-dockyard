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

stage "WIPE DISK & CREATE GPT"
sgdisk -Z "$DISK"

stage "CREATE PARTITIONS (BIOS ONLY)"

sgdisk -n1:0:+32M -t1:EF02 -c1:"BIOS GRUB" "$DISK"
sgdisk -n2:0:+${SWAP_MB}M -t2:8200 -c2:"Swap" "$DISK"
sgdisk -n3:0:0 -t3:8300 -c3:"NixOS Root" "$DISK"

stage "RELOAD PARTITION TABLE"
partprobe "$DISK"
udevadm settle

stage "FORMAT PARTITIONS"
mkswap "${DISK}2"
swapon "${DISK}2"
mkfs.ext4 "${DISK}3"

stage "MOUNT ROOT"
mount "${DISK}3" /mnt

echo "✔ BIOS-only GPT layout ready for NixOS installation."
