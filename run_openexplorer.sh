#!/bin/bash

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=========================================================="
echo "Starting Horizon OpenExplorer Docker Container..."
echo "Platform: linux/amd64 (Emulated via Rosetta 2)"
echo "Workspace: $SCRIPT_DIR mapped to /workspace"
echo "=========================================================="

docker run -it --rm \
    --platform linux/amd64 \
    -v "$SCRIPT_DIR":/workspace \
    -w /workspace \
    registry.d-robotics.cc/deliver/ai_toolchain_ubuntu_20_x5_cpu:v1.2.8 \
    /bin/bash
