#!/bin/bash -e
# Stage 2: Display setup for TFT35a

# Ensure config.txt has correct settings (already done in stage1, but verify)
if ! grep -q "dtoverlay=tft35a:rotate=90" /boot/firmware/config.txt; then
    echo "dtoverlay=tft35a:rotate=90" >> /boot/firmware/config.txt
fi

if ! grep -q "dtoverlay=xpt2046-spi0-1" /boot/firmware/config.txt; then
    echo "dtoverlay=xpt2046-spi0-1,int_pin=25" >> /boot/firmware/config.txt
fi

# Create modprobe rule for touch driver
cat > /etc/modprobe.d/tft35a.conf << '"'"'EOF'"'"'
# TFT35a touch driver options
options xpt2046_spi swap_xy=1
EOF

# Create systemd service to wait for touch device
cat > /etc/systemd/system/wait-for-touch.service << '"'"'EOF'"'"'
[Unit]
Description=Wait for xpt2046 touch device
Before=graphical.target
After=systemd-udev-settle.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c '"'"'for i in {1..30}; do [ -e /dev/input/by-id/*XPT2046* ] && exit 0; sleep 1; done; exit 1'"'"'
RemainAfterExit=yes
TimeoutSec=60

[Install]
WantedBy=graphical.target
EOF

systemctl enable wait-for-touch.service

# Disable HDMI service
systemctl disable hdmi.service 2>/dev/null || true
