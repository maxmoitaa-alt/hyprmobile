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

# Clone official pi-gen
WORKDIR /pi-gen
RUN git clone --depth=1 https://github.com/RPi-Distro/pi-gen.git /pi-gen-official \
    && cp -r /pi-gen-official/* /pi-gen/ \
    && rm -rf /pi-gen-official

# Copy our custom stages and config OVER the official pi-gen
COPY config /pi-gen/config
COPY stage1 /pi-gen/stage1
COPY stage2 /pi-gen/stage2
COPY stage3 /pi-gen/stage3
COPY stage4 /pi-gen/stage4

# Fix line endings and make scripts executable
RUN find /pi-gen -name "*.sh" -exec dos2unix {} \; 2>/dev/null || true
RUN find /pi-gen -name "*.sh" -exec chmod +x {} \;

# Default command - run pi-gen's build.sh non-interactively
CMD ["./build.sh"]