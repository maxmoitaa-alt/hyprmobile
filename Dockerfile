# =============================================================================
# HyprMobile Pi-Gen Dockerfile
# Build environment for Raspberry Pi OS 64-bit + Hyprland Mobile
# =============================================================================

FROM debian:bookworm-slim

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    debootstrap qemu-user-static binfmt-support \
    dosfstools parted kpartx zerofree zip \
    xxd curl wget unzip git \
    ca-certificates gnupg dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Enable binfmt for arm64
RUN update-binfmts --enable qemu-aarch64

# Set working directory
WORKDIR /pi-gen

# Copy pi-gen source
COPY . /pi-gen/

# Fix line endings and make scripts executable
RUN find /pi-gen -name "*.sh" -exec dos2unix {} \; 2>/dev/null || true
RUN find /pi-gen -name "*.sh" -exec chmod +x {} \;

# Default command
CMD ["./build-docker.sh"]