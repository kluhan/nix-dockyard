#!/usr/bin/env bash
set -euo pipefail

DISK="/dev/sda"
SWAP_SIZE_GB=8

GREEN="\033[1;32m"
RESET="\033[0m"

stage() {
  echo -e "${GREEN}>>> STAGE: $1 <<<${RESET}"
}

stage "WARNING"
echo "THIS WILL ERASE ALL DATA ON ${DISK}"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || exit 1

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

stage "RESULT"
parted "$DISK" print
