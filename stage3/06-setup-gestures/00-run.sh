#!/bin/bash -e
# Stage 3: Advanced Gestures - Mobile UX perfection

# Hyprland gestures are configured in hyprland.conf, but we can add
# additional gesture tools and configurations here

# Install and configure libinput-gestures for additional gestures
# (Hyprland has built-in gestures, but libinput-gestures adds more)

mkdir -p /etc/skel/.config/libinput-gestures

cat > /etc/skel/.config/libinput-gestures/libinput-gestures.conf << '"'"'EOF'"'"'
# libinput-gestures configuration for additional mobile gestures
# Complements Hyprland built-in gestures

# =============================================================================
# GESTURE DEFINITIONS
# =============================================================================

# 3-finger swipe up = App overview (wofi)
gesture swipe up 3    wofi --show drun --width 300 --height 400 --location top_right --anchor top_right

# 3-finger swipe down = Show keyboard
gesture swipe down 3  ~/.config/hypr/scripts/toggle-keyboard.sh

# 3-finger swipe left = Previous workspace
gesture swipe left 3  hyprctl dispatch workspace e-1

# 3-finger swipe right = Next workspace
gesture swipe right 3 hyprctl dispatch workspace e+1

# 4-finger swipe up = Quick settings (swaync)
gesture swipe up 4    swaync-client -t

# 4-finger swipe down = Notification center
gesture swipe down 4  swaync-client -t

# 4-finger swipe left = Back (browser, file manager)
gesture swipe left 4  wtype -M alt -P Left -m alt

# 4-finger swipe right = Forward
gesture swipe right 4 wtype -M alt -P Right -m alt

# Pinch zoom in/out (2 fingers)
gesture pinch in 2    wtype -M ctrl -P equal -m ctrl
gesture pinch out 2   wtype -M ctrl -P minus -m ctrl

# 2-finger rotate = Rotate screen (if supported)
# gesture rotate cw 2   hyprctl keyword monitor "DP-1,transform=1"
# gesture rotate ccw 2  hyprctl keyword monitor "DP-1,transform=0"

# Tap gestures
gesture tap 2         wtype -P click  # Two-finger tap = right click
gesture tap 3         hyprctl dispatch fullscreen  # Three-finger tap = fullscreen toggle

# Hold gestures
gesture hold 3        hyprctl dispatch exec "wofi --show power --width 240 --height 280"

# Edge swipe (from screen edges)
# gesture edge left 3   hyprctl dispatch workspace special:magic
# gesture edge right 3  swaync-client -t
# gesture edge top 3    wofi --show drun
# gesture edge bottom 3 ~/.config/hypr/scripts/toggle-keyboard.sh

# =============================================================================
# SETTINGS
# =============================================================================
# Minimum distance for swipe (in pixels)
swipe_threshold=50

# Timeout for gesture recognition (ms)
gesture_timeout=300

# Enable/disable gestures
enable_gestures=true
EOF

# Create systemd user service for libinput-gestures
mkdir -p /etc/skel/.config/systemd/user

cat > /etc/skel/.config/systemd/user/libinput-gestures.service << '"'"'EOF'"'"'
[Unit]
Description=libinput-gestures - Additional touchpad/touchscreen gestures
After=graphical-session.target
PartOf=graphical-session.target
ConditionPathExists=/dev/input/event*

[Service]
Type=simple
ExecStart=/usr/bin/libinput-gestures -c ~/.config/libinput-gestures/libinput-gestures.conf
Restart=on-failure
RestartSec=2
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=/run/user/1000

[Install]
WantedBy=graphical-session.target
EOF

# Add user to input group for libinput-gestures
# (This will be done in stage4)

# =============================================================================
# HYPRIDLE - Idle management for mobile
# =============================================================================
mkdir -p /etc/skel/.config/hypr

cat > /etc/skel/.config/hypr/hypridle.conf << '"'"'EOF'"'"'
# hypridle - Mobile idle management
# Screen off, lock, suspend - optimized for battery

general {
    lock_on_suspend = true
    lock_on_lid_close = true
}

# Listener 1: Dim screen after 30 seconds
listener {
    timeout = 30
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

# Listener 2: Lock after 1 minute of inactivity
listener {
    timeout = 60
    on-timeout = hyprlock
    on-resume = hyprctl dispatch dpms on
}

# Listener 3: Suspend after 5 minutes (battery saving)
listener {
    timeout = 300
    on-timeout = systemctl suspend
    on-resume = hyprctl dispatch dpms on
}

# Listener 4: Hibernate after 30 minutes (deep sleep)
listener {
    timeout = 1800
    on-timeout = systemctl hibernate
    on-resume = hyprctl dispatch dpms on
}

# AC power overrides (longer timeouts)
# listener {
#     timeout = 300
#     on-timeout = hyprctl dispatch dpms off
#     on-resume = hyprctl dispatch dpms on
# }

# listener {
#     timeout = 600
#     on-timeout = hyprlock
#     on-resume = hyprctl dispatch dpms on
# }
EOF

# =============================================================================
# ADVANCED TOUCH GESTURES - Custom gesture daemon for mobile
# =============================================================================
cat > /etc/skel/.config/hypr/scripts/gesture-daemon.py << '"'"'EOF'"'"'
#!/usr/bin/env python3
"""
Advanced Gesture Daemon for Mobile UX
Handles complex multi-touch gestures beyond libinput-gestures
"""

import subprocess
import time
import json
import threading
from collections import deque

class GestureDaemon:
    def __init__(self):
        self.gesture_history = deque(maxlen=10)
        self.last_gesture_time = 0
        self.gesture_cooldown = 0.5  # seconds
        
    def run_hyprctl(self, cmd):
        """Run hyprctl command"""
        try:
            subprocess.run(["hyprctl", "dispatch"] + cmd.split(), 
                         capture_output=True, check=False)
        except Exception:
            pass
    
    def notify(self, title, body, icon=""):
        """Send notification"""
        try:
            subprocess.run(["notify-send", title, body, "-i", icon], 
                         capture_output=True, check=False)
        except Exception:
            pass
    
    def handle_swipe(self, direction, fingers):
        """Handle swipe gestures"""
        now = time.time()
        if now - self.last_gesture_time < self.gesture_cooldown:
            return
        self.last_gesture_time = now
        
        if fingers == 3:
            if direction == "up":
                # App overview
                subprocess.Popen(["wofi", "--show", "drun", "--width", "300", 
                                "--height", "400", "--location", "top_right", 
                                "--anchor", "top_right"])
                self.notify("?? Apps", "App overview opened")
            elif direction == "down":
                # Keyboard
                self.run_hyprctl("exec ~/.config/hypr/scripts/toggle-keyboard.sh")
                self.notify("?? Keyboard", "Toggled")
            elif direction == "left":
                self.run_hyprctl("workspace e-1")
            elif direction == "right":
                self.run_hyprctl("workspace e+1")
                
        elif fingers == 4:
            if direction == "up":
                # Quick settings
                subprocess.Popen(["swaync-client", "-t"])
            elif direction == "down":
                # Notifications
                subprocess.Popen(["swaync-client", "-t"])
            elif direction == "left":
                # Back
                subprocess.Popen(["wtype", "-M", "alt", "-P", "Left", "-m", "alt"])
            elif direction == "right":
                # Forward
                subprocess.Popen(["wtype", "-M", "alt", "-P", "Right", "-m", "alt"])
    
    def handle_pinch(self, direction):
        """Handle pinch zoom"""
        if direction == "in":
            subprocess.Popen(["wtype", "-M", "ctrl", "-P", "equal", "-m", "ctrl"])
        elif direction == "out":
            subprocess.Popen(["wtype", "-M", "ctrl", "-P", "minus", "-m", "ctrl"])
    
    def handle_tap(self, fingers):
        """Handle tap gestures"""
        if fingers == 2:
            # Right click
            subprocess.Popen(["wtype", "-P", "click"])
        elif fingers == 3:
            # Fullscreen toggle
            self.run_hyprctl("fullscreen")
            self.notify("?? Fullscreen", "Toggled")
    
    def handle_hold(self, fingers):
        """Handle long press"""
        if fingers == 3:
            # Power menu
            subprocess.Popen(["wofi", "--show", "power", "--width", "240", 
                            "--height", "280", "--location", "top_right",
                            "--anchor", "top_right"])
            self.notify("? Power", "Menu opened")

def main():
    print("?? Gesture Daemon started")
    daemon = GestureDaemon()
    
    # This would integrate with libinput or a touch event listener
    # For now, it is a framework for future expansion
    # Real implementation would use python-libinput or similar
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Gesture Daemon stopped")

if __name__ == "__main__":
    main()
EOF

chmod +x /etc/skel/.config/hypr/scripts/gesture-daemon.py

# Create systemd service for gesture daemon
cat > /etc/skel/.config/systemd/user/gesture-daemon.service << '"'"'EOF'"'"'
[Unit]
Description=Advanced Gesture Daemon for Mobile UX
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/home/mobile/.config/hypr/scripts/gesture-daemon.py
Restart=on-failure
RestartSec=5
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=/run/user/1000

[Install]
WantedBy=graphical-session.target
EOF
