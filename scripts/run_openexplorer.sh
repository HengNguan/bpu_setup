#!/bin/bash

# Get the directory of this script and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"

echo "=========================================================="
echo "Starting Horizon OpenExplorer Docker Container..."
echo "Platform: linux/amd64 (Emulated via Rosetta 2)"
echo "Workspace: $PROJECT_ROOT mapped to /workspace"
echo "=========================================================="

docker run -it --rm \
    --platform linux/amd64 \
    -v "$PROJECT_ROOT":/workspace \
    -w /workspace \
    registry.d-robotics.cc/deliver/ai_toolchain_ubuntu_20_x5_cpu:v1.2.8 \
    /bin/bash
