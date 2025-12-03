#!/bin/bash
set -euo pipefail

DISK="/dev/sda"

echo "⚠ WARNING: This will erase all data on $DISK!"

read -p "Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# 1️⃣ Create a new GPT partition table
parted $DISK --script mklabel gpt

# 2️⃣ Create partitions
# Partition 1: boot, 500M
parted $DISK --script mkpart primary fat32 1MiB 501MiB
parted $DISK --script set 1 boot on

# Partition 2: GRUB, 32M
parted $DISK --script mkpart primary 501MiB 533MiB
# Set bios_grub flag for GRUB on BIOS systems
parted $DISK --script set 2 bios_grub on

# Partition 3: swap, 4G
parted $DISK --script mkpart primary linux-swap 533MiB 4533MiB

# Partition 4: root, rest of disk
parted $DISK --script mkpart primary ext4 4533MiB 100%

# 3️⃣ Format partitions
mkfs.fat -F32 ${DISK}1        # EFI boot
mkswap ${DISK}3                # swap
swapon ${DISK}3
mkfs.ext4 ${DISK}4             # root

# 4️⃣ Mount partitions
mount ${DISK}4 /mnt
mkdir -p /mnt/boot
mount -o umask=077 ${DISK}1 /mnt/boot

echo "✅ Partitions created, formatted, and mounted."
