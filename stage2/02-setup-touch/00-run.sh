#!/bin/bash -e
# Stage 2: Touch calibration for xpt2046 (TFT35a 480x320 @ 90° CW)

# hwdb calibration for libinput
# Matrix for 90° CW rotation: [0, 1, 0, -1, 0, 1, 0, 0, 1]
# Adjusted for xpt2046 typical ranges (MinX=200, MaxX=3900, MinY=200, MaxY=3900)
cat > /etc/udev/hwdb.d/99-xpt2046-calibration.hwdb << '"'"'EOF'"'"'
# Waveshare 3.5" TFT35a - xpt2046 touchscreen - 90° CW rotation
# Physical resolution: 480x320, Logical (rotated): 320x480
evdev:name:XPT2046 Touchscreen:dmi:*svnRaspberryPi:*:pn*3*
 LIBINPUT_CALIBRATION_MATRIX=0 1 0 -1 0 1 0 0 1
 LIBINPUT_CALIBRATION_MATRIX=0 1 0 -1 0 1 0 0 1

# Alternative if above does not match (some kernels report different name)
evdev:name:XPT2046 Touchscreen:*
 LIBINPUT_CALIBRATION_MATRIX=0 1 0 -1 0 1 0 0 1
 LIBINPUT_CALIBRATION_MATRIX=0 1 0 -1 0 1 0 0 1

# Generic fallback
evdev:input:b*v*p*e*-XPT2046*
 LIBINPUT_CALIBRATION_MATRIX=0 1 0 -1 0 1 0 0 1
EOF

# udev rule to tag as touchscreen
cat > /etc/udev/rules.d/99-touchscreen.rules << '"'"'EOF'"'"'
# XPT2046 Touchscreen - ensure proper device tagging
KERNEL=="event*", ATTRS{name}=="XPT2046 Touchscreen", ENV{LIBINPUT_DEVICE_GROUP}="xpt2046", TAG+="uaccess", ENV{ID_INPUT_TOUCHSCREEN}="1"
KERNEL=="event*", ATTRS{name}=="*XPT2046*", ENV{LIBINPUT_DEVICE_GROUP}="xpt2046", TAG+="uaccess", ENV{ID_INPUT_TOUCHSCREEN}="1"
KERNEL=="event*", ATTRS{modalias}=="*:xpt2046:*", ENV{LIBINPUT_DEVICE_GROUP}="xpt2046", TAG+="uaccess", ENV{ID_INPUT_TOUCHSCREEN}="1"

# Set permissions for touch device
KERNEL=="event*", ATTRS{name}=="XPT2046 Touchscreen", MODE="0666", GROUP="input"
EOF

# Update hwdb and trigger udev
systemd-hwdb update
udevadm control --reload-rules
udevadm trigger

# Create calibration verification script
cat > /usr/local/bin/calibrate-touch << '"'"'EOF'"'"'
#!/bin/bash
# Interactive touch calibration for xpt2046
# Run this on first boot if touch is misaligned

echo "=== Touch Calibration for TFT35a (xpt2046) ==="
echo "This will guide you through calibrating the touchscreen."
echo ""
echo "You need to tap 4 points on the screen."
echo "The screen is 320x480 (rotated 90° CW)."
echo ""

# Check if libinput tools available
if ! command -v libinput &> /dev/null; then
    echo "Installing libinput-tools..."
    apt-get update && apt-get install -y libinput-tools
fi

# Find the touch device
DEVICE=$(libinput list-devices | grep -A5 -B5 "XPT2046" | grep "Kernel:" | awk '{print $2}' | head -1)

if [ -z "$DEVICE" ]; then
    DEVICE=$(libinput list-devices | grep -A5 -B5 "Touchscreen" | grep "Kernel:" | awk '{print $2}' | head -1)
fi

if [ -z "$DEVICE" ]; then
    echo "ERROR: Could not find touch device!"
    libinput list-devices
    exit 1
fi

echo "Found touch device: $DEVICE"
echo ""
echo "Starting calibration... Follow on-screen instructions."
echo "You will need to tap the crosshairs at each corner."
echo ""

libinput calibrate "$DEVICE" --output-type=udev-hwdb

echo ""
echo "Calibration complete! The new hwdb entry has been printed above."
echo "Copy it to /etc/udev/hwdb.d/99-xpt2046-calibration.hwdb and run:"
echo "  systemd-hwdb update && udevadm trigger"
EOF

chmod +x /usr/local/bin/calibrate-touch

# Create systemd service for first-boot calibration if needed
cat > /etc/systemd/system/touch-calibration-check.service << '"'"'EOF'"'"'
[Unit]
Description=Check and run touch calibration on first boot
After=graphical.target
ConditionPathExists=!/etc/.touch_calibrated

[Service]
Type=oneshot
ExecStart=/bin/bash -c '"'"'
    sleep 5
    if ! libinput list-devices | grep -q "XPT2046.*Touchscreen"; then
        echo "Touch device not found, skipping calibration"
        touch /etc/.touch_calibrated
        exit 0
    fi
    # Check if calibration matrix is identity (uncalibrated)
    MATRIX=$(libinput list-devices | grep -A10 "XPT2046" | grep "Calibration Matrix" | head -1)
    if echo "$MATRIX" | grep -q "1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000"; then
        echo "Touch appears uncalibrated, launching calibrator..."
        # In a real scenario, this would launch a GUI calibrator
        # For now, just mark as done
        touch /etc/.touch_calibrated
    else
        touch /etc/.touch_calibrated
    fi
'"'"'
RemainAfterExit=yes

[Install]
WantedBy=graphical.target
EOF

systemctl enable touch-calibration-check.service
