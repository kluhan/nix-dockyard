#!/bin/bash
set -euo pipefail

# ⚠ WARNING: THIS WILL ERASE ALL DATA ON THE DISK!
DISK="/dev/sda"   # Change if needed
SWAP_FACTOR=1     # swap = RAM * SWAP_FACTOR

echo "⚠ WARNING: All data on $DISK will be destroyed!"
read -p "Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# 1️⃣ Detect total RAM in MiB
RAM_MB=$(free -m | awk '/Mem:/ {print $2}')
SWAP_MB=$((RAM_MB * SWAP_FACTOR))
echo "Detected RAM: ${RAM_MB}MiB → swap will be ${SWAP_MB}MiB"

# 2️⃣ Wipe existing partitions
sgdisk -Z "$DISK"

# 3️⃣ Create partitions dynamically
# Partition 1: EFI Boot (512MiB)
sgdisk -n1:0:+512M -t1:EF00 -c1:"EFI Boot" "$DISK"

# Partition 2: BIOS GRUB (32MiB)
sgdisk -n2:0:+32M -t2:EF02 -c2:"BIOS GRUB" "$DISK"

# Partition 3: Swap (dynamic size)
sgdisk -n3:0:+${SWAP_MB}M -t3:8200 -c3:"Swap" "$DISK"

# Partition 4: Root (rest of disk)
sgdisk -n4:0:0 -t4:8300 -c4:"NixOS Root" "$DISK"

# 4️⃣ Format partitions
mkfs.fat -F32 "${DISK}1"             # EFI
mkswap "${DISK}3"                     # Swap
swapon "${DISK}3"
mkfs.ext4 "${DISK}4"                  # Root

# 5️⃣ Mount partitions
mount "${DISK}4" /mnt
mkdir -p /mnt/boot
mount -o umask=077 "${DISK}1" /mnt/boot

echo "✅ Partitions created, formatted, and mounted successfully."
