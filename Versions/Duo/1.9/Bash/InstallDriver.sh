#!/bin/bash
set -e

BOOT_CFG="/boot/config.txt"

if grep -Eq '^[#[:space:]]*dtoverlay=vc4-kms-v3d' "$BOOT_CFG"; then
  sudo cp "$BOOT_CFG" "${BOOT_CFG}.bak_$(date +%Y%m%d_%H%M%S)"
  sudo sed -i -E 's@^[#[:space:]]*dtoverlay=vc4-kms-v3d@dtoverlay=vc4-fkms-v3d@g' "$BOOT_CFG"
elif ! grep -Eq 'dtoverlay=vc4-fkms-v3d' "$BOOT_CFG"; then
  sudo cp "$BOOT_CFG" "${BOOT_CFG}.bak_$(date +%Y%m%d_%H%M%S)"
  echo "dtoverlay=vc4-fkms-v3d" | sudo tee -a "$BOOT_CFG" >/dev/null
fi

sudo apt update
sudo apt install -y python3-opencv
sudo apt install -y cmake git build-essential

cd ~
git clone https://github.com/sn-lab/MouseGoggles

cd MouseGoggles/fbcp-ili9341
mkdir -p build
cd build
cmake -DGC9A01=ON ..
make -j$(nproc)

sudo ./fbcp-ili9341
