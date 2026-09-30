#!/usr/bin/env bash
set -e

# Clone or update klipper source into a local build cache directory
if [ ! -d "build/klipper" ]; then
  mkdir -p build
  git clone https://github.com/Klipper3d/klipper.git build/klipper
fi

# Copy the stored config into the source tree
cp mcu.config build/klipper/.config

# Build using docker container
docker run --rm \
  -v "$(pwd)/build/klipper":/klipper \
  -w /klipper \
  debian:bookworm bash -c '
        apt-get update && apt-get install -y --no-install-recommends \
            gcc-arm-none-eabi binutils-arm-none-eabi make python3 build-essential
        make olddefconfig
        make clean
        make
    '

# Copy the output firmware to project root
cp build/klipper/out/klipper.bin firmware.bin
echo "Build complete: firmware.bin ready to flash (rename to firmware.bin on SD card)."
