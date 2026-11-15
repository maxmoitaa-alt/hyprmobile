#!/bin/bash -e
# Stage 1: Boot configuration for Pi 3B 64-bit + TFT35a

# Create firmware config.txt for TFT35a display
cat > /boot/firmware/config.txt << '"'"'EOF'"'"'
# Raspberry Pi 3B 64-bit + Waveshare 3.5" TFT35a (xpt2046 touch)
# Rotated 90° CW for mobile portrait mode

# Kernel
kernel=kernel8.img
arm_64bit=1

# Display: TFT35a via SPI (includes ili9486 driver)
dtparam=spi=on
dtparam=i2c_arm=on
dtoverlay=tft35a:rotate=90

# Touch controller: xpt2046 on SPI0.1 (CS1)
dtoverlay=xpt2046-spi0-1,int_pin=25

# Console on TFT framebuffer
# fbcon=map:10 maps console to /dev/fb1 (TFT)
# consoleblank=0 disables screen blanking

# Disable HDMI to save power
hdmi_blanking=2
disable_splash=1
boot_delay=0

# GPU memory (minimum for headless/wayland)
gpu_mem=64

# Overclock (Pi 3B safe)
arm_freq=1300
core_freq=500
sdram_freq=500
over_voltage=4

# UART for debugging
enable_uart=1
EOF

# cmdline.txt for console on TFT
cat > /boot/firmware/cmdline.txt << '"'"'EOF'"'"'
console=tty1 console=serial0,115200 root=PARTUUID=%PARTUUID% rootfstype=ext4 fsck.repair=yes rootwait fbcon=map:10 consoleblank=0 plymouth.ignore-serial-consoles
EOF

# Create config.txt symlink for compatibility
ln -sf /boot/firmware/config.txt /boot/config.txt
ln -sf /boot/firmware/cmdline.txt /boot/cmdline.txt
