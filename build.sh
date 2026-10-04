#!/bin/sh
set -e
cd "$(dirname "$0")"

docker build --no-cache --platform=linux/amd64 -t flolower-kernel-builder .

ARCH=$(docker run --rm --platform=linux/amd64 flolower-kernel-builder uname -m)
if [ "$ARCH" != "x86_64" ]; then
    echo "ERROR: container reports arch '$ARCH', expected x86_64."
    echo "Docker Desktop's amd64 emulation isn't working — check Docker Desktop"
    echo "Settings > General > 'Use Rosetta for x86/amd64 emulation' is enabled,"
    echo "then try again."
    exit 1
fi
echo "Container arch OK: $ARCH"

docker run --rm --platform=linux/amd64 -v "$(pwd)":/project -w /project --user "$(id -u):$(id -g)" flolower-kernel-builder make clean image

echo ""
echo "Built flolower.img. Run it locally with:"
echo "  brew install qemu   # if not already installed"
echo "  make run"
echo "(make run just calls qemu-system-i386 on the .img that's now on your Mac — no Docker needed for that part.)"
