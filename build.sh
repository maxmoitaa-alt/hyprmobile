#!/bin/bash
# =============================================================================
# HyprMobile Pi-Gen Build Script
# Builds Raspberry Pi OS 64-bit + Hyprland Mobile for Pi 3B + TFT35a
# =============================================================================

set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/deploy"
LOG_FILE="${BUILD_DIR}/build-$(date +%Y%m%d-%H%M%S).log"

log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $*" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[$(date +%H:%M:%S)] WARNING:${NC} $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[$(date +%H:%M:%S)] ERROR:${NC} $*" | tee -a "$LOG_FILE"; exit 1; }
info() { echo -e "${BLUE}[$(date +%H:%M:%S)] INFO:${NC} $*" | tee -a "$LOG_FILE"; }

check_requirements() {
    log "Checking requirements..."
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (sudo)."
    fi
    local tools=("docker" "git" "curl" "wget" "unzip" "qemu-user-static" "binfmt-support")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            warn "$tool not found. Installing..."
            apt-get update && apt-get install -y "$tool"
        fi
    done
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes 2>/dev/null || true
    log "Requirements check passed!"
}

build_docker() {
    log "Starting Docker build..."
    cd "$SCRIPT_DIR"
    docker build -t hyprmobile-builder . 2>&1 | tee -a "$LOG_FILE"
    docker run --rm --privileged \
        -v "$SCRIPT_DIR:/pi-gen" \
        -v "$BUILD_DIR:/deploy" \
        hyprmobile-builder \
        /pi-gen/build-docker.sh 2>&1 | tee -a "$LOG_FILE"
    log "Docker build completed!"
}

build_native() {
    log "Starting native build..."
    cd "$SCRIPT_DIR"
    apt-get update
    apt-get install -y \
        debootstrap qemu-user-static binfmt-support \
        dosfstools parted kpartx zerofree zip \
        xxd curl wget unzip
    ./build.sh 2>&1 | tee -a "$LOG_FILE"
    log "Native build completed!"
}

verify_output() {
    log "Verifying output..."
    local img_files=($(find "$BUILD_DIR" -name "*.img" -o -name "*.img.zst" -o -name "*.zip" 2>/dev/null))
    if [[ ${#img_files[@]} -eq 0 ]]; then
        error "No image files found in $BUILD_DIR"
    fi
    for img in "${img_files[@]}"; do
        local size=$(du -h "$img" | cut -f1)
        log "Found: $(basename "$img") ($size)"
        if file "$img" | grep -q "DOS/MBR boot sector"; then
            log "Valid bootable image"
        else
            warn "Image may not be bootable: $img"
        fi
    done
}

flash_sd() {
    local device="$1"
    if [[ -z "$device" ]]; then
        read -p "Enter SD card device (e.g. /dev/sdX): " device
    fi
    if [[ ! -b "$device" ]]; then
        error "Device $device not found or not a block device"
    fi
    local img=$(find "$BUILD_DIR" -name "*.img" -o -name "*.img.zst" | head -1)
    if [[ -z "$img" ]]; then
        error "No image file found to flash"
    fi
    warn "This will DESTROY all data on $device!"
    read -p "Are you sure? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        log "Flash cancelled."
        return
    fi
    log "Flashing $img to $device..."
    if [[ "$img" == *.zst ]]; then
        zstd -d -c "$img" | dd of="$device" bs=4M status=progress conv=fsync
    else
        dd if="$img" of="$device" bs=4M status=progress conv=fsync
    fi
    sync
    log "Flash complete! Syncing..."
    sync
}

main() {
    echo -e "${BLUE}"
    echo "================================================================"
    echo "                   HyprMobile Builder                          "
    echo "     Raspberry Pi OS 64-bit + Hyprland Mobile for Pi 3B       "
    echo "                    Waveshare TFT35a + xpt2046                "
    echo "================================================================"
    echo -e "${NC}"
    
    mkdir -p "$BUILD_DIR"
    check_requirements
    
    echo ""
    echo "Select build method:"
    echo "  1) Docker (recommended, works on any Linux)"
    echo "  2) Native (faster, requires Debian/Ubuntu host)"
    echo "  3) Flash existing image to SD card"
    read -p "Choice [1-3]: " choice
    
    case "$choice" in
        1) build_docker ;;
        2) build_native ;;
        3) flash_sd; exit 0 ;;
        *) error "Invalid choice" ;;
    esac
    
    verify_output
    
    echo ""
    log "================================================================"
    log "BUILD COMPLETE!"
    log "================================================================"
    log ""
    log "Output files in: $BUILD_DIR"
    log ""
    log "Next steps:"
    log "  1. Flash to SD card: sudo $0 flash /dev/sdX"
    log "  2. Insert SD into Pi 3B"
    log "  3. Connect TFT35a display"
    log "  4. Power on and enjoy HyprMobile!"
    log ""
    log "Default login: mobile / mobile"
    log "SSH: enabled (port 22)"
    log "WiFi: Configure via nmcli or nmtui"
    log ""
}

main "$@"
