#!/bin/bash
# =============================================================================
# Pi-Gen Docker Build Script
# Runs inside the Docker container to build the image
# =============================================================================

set -euo pipefail

cd /pi-gen

# Source config
source config

# Build the image using pi-gen
./build.sh

# Copy output to deploy directory
mkdir -p /deploy
cp -r deploy/* /deploy/ 2>/dev/null || true

echo "Build complete! Output in /deploy"
