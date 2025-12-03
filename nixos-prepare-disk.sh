#!/bin/bash
set -euo pipefail

DISK="/dev/sda"  # Change this if your target disk is different
SWAP_FACTOR=1     # swap = RAM * SWAP_FACTOR

echo "⚠ WARNING: This will erase all data on $DISK!"
read -p "Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# Get total RAM in MiB
RAM_MB=$(free -m | awk '/Mem:/ {print $2}')
SWAP_MB=$((RAM_MB * SWAP_FACTOR))
echo "Detected RAM: ${RAM_MB}MB → Setting swap size: ${SWAP_MB}MB"

# 1️⃣ Create a new GPT partition table
parted $DISK --script mklabel gpt

# 2️⃣ Partitioning
CURRENT_START=1MiB

# Partition 1: EFI boot (512MB)
EFI_SIZE=512MiB
parted $DISK --script mkpart ESP fat32 $CURRENT_START $EFI_SIZE
parted $DISK --script set 1 boot on

# Update start for next partition
CURRENT_START=$EFI_SIZE

# Partition 2: BIOS GRUB (32MB)
GRUB_SIZE=32MiB
GRUB_START=$CURRENT_START
GRUB_END=$(( $(numfmt --from=iec $GRUB_START) + 32 * 1024 * 1024 ))
parted $DISK --script mkpart primary $GRUB_START ${GRUB_START}+32MiB
parted $DISK --script set 2 bios_grub on

# Update start for next partition
CURRENT_START="${GRUB_START}+32MiB"

# Partition 3: Swap (dynamic)
parted $DISK --script mkpart primary linux-swap $CURRENT_START ${CURRENT_START}+${SWAP_MB}MiB

# Update start for root
CURRENT_START="${CURRENT_START}+${SWAP_MB}MiB"

# Partition 4: Root (rest of the disk)
parted $DISK --script mkpart primary ext4 $CURRENT_START 100%

# 3️⃣ Format partitions
mkfs.fat -F32 ${DISK}1
mkswap ${DISK}3
swapon ${DISK}3
mkfs.ext4 ${DISK}4

# 4️⃣ Mount partitions
mount ${DISK}4 /mnt
mkdir -p /mnt/boot
mount -o umask=077 ${DISK}1 /mnt/boot

echo "✅ Partitions created, formatted, and mounted successfully."
