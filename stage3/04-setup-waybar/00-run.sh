#!/bin/bash -e
# Stage 3: Waybar - Mobile Status Bar Perfection

mkdir -p /etc/skel/.config/waybar

# Main config
cat > /etc/skel/.config/waybar/config.jsonc << '"'"'EOF'"'"'
{
    // =============================================================================
    // Waybar Mobile Config - iOS/Android style status bar
    // 320px width, 36px height, top positioned
    // =============================================================================

    "layer": "top",
    "position": "top",
    "height": 36,
    "spacing": 4,
    "margin": 4,

    // Modules - mobile layout: [workspaces] [spacer] [clock/date] [spacer] [system]
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock", "battery"],
    "modules-right": ["network", "bluetooth", "pulseaudio", "power"],

    // =============================================================================
    // WORKSPACES - Mobile style dots
    // =============================================================================
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": false,
        "format": "{icon}",
        "format-icons": {
            "1": "?",
            "2": "?",
            "3": "?",
            "4": "?",
            "5": "?",
            "active": "?",
            "inactive": "?",
            "urgent": "?"
        },
        "on-click": "activate",
        "tooltip-format": "Workspace {name}"
    },

    // =============================================================================
    // CLOCK - Time + Date on click
    // =============================================================================
    "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%A, %d %B %Y}",
        "tooltip-format": "<b>{:%A, %d %B %Y}</b>\nWeek {:%V}",
        "interval": 30,
        "on-click": "toggle-format",
        "on-scroll-up": "",
        "on-scroll-down": ""
    },

    // =============================================================================
    // BATTERY - Percentage + icon + charging animation
    // =============================================================================
    "battery": {
        "bat": "BAT0",
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "? {capacity}% {icon}",
        "format-plugged": "?? {capacity}%",
        "format-full": "? 100%",
        "format-icons": [
            "??",  // 0-19%
            "??",  // 20-39%
            "??",  // 40-59%
            "??",  // 60-79%
            "??"   // 80-100%
        ],
        "on-click": "exec, ~/.config/waybar/scripts/battery-details.sh",
        "tooltip": true
    },

    // =============================================================================
    // NETWORK - WiFi signal strength + SSID
    // =============================================================================
    "network": {
        "interface": "wlan0",
        "format-wifi": "?? {signalStrength}%",
        "format-ethernet": "?? Connected",
        "format-linked": "?? {ifname}",
        "format-disconnected": "? Offline",
        "tooltip-format": "{ifname} ({ipaddr}/{cidr})\nSSID: {essid}\nSignal: {signalStrength}%",
        "on-click": "exec, ~/.config/waybar/scripts/network-menu.sh",
        "interval": 10
    },

    // =============================================================================
    // BLUETOOTH - Connected devices count
    // =============================================================================
    "bluetooth": {
        "format": "?? {connectedDevices}",
        "format-disconnected": "? Off",
        "format-off": "? Off",
        "tooltip-format": "{deviceName} ({deviceAddress})",
        "on-click": "exec, blueman-manager",
        "interval": 10
    },

    // =============================================================================
    // PULSEAUDIO - Volume with icon
    // =============================================================================
    "pulseaudio": {
        "format": "?? {volume}%",
        "format-muted": "?? Muted",
        "format-source": "?? {volume}%",
        "format-source-muted": "?? Muted",
        "on-click": "exec, pavucontrol",
        "on-scroll-up": "exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+",
        "on-scroll-down": "exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
        "tooltip": true
    },

    // =============================================================================
    // POWER - Quick power menu
    // =============================================================================
    "power": {
        "format": "?",
        "on-click": "exec, ~/.config/waybar/scripts/power-menu.sh",
        "tooltip": "Power Menu"
    },

    // =============================================================================
    // TRAY - System tray for apps
    // =============================================================================
    "tray": {
        "icon-size": 20,
        "spacing": 6,
        "on-click": "toggle",
        "tooltip": true
    }
}
EOF

# CSS Styling - Beautiful, mobile-perfect
cat > /etc/skel/.config/waybar/style.css << '"'"'EOF'"'"'
/* =============================================================================
   Waybar Mobile Style - iOS/Android aesthetic
   Colors: Dark base (#0a0a12), Accent cyan (#00ffcc), Text white
   ============================================================================= */

* {
    border: none;
    border-radius: 0;
    font-family: "JetBrains Mono", "Inter", "Noto Sans", monospace;
    font-size: 13px;
    min-height: 0;
    margin: 0;
    padding: 0;
}

window#waybar {
    background: rgba(10, 10, 18, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 0 0 16 16;
    border-bottom: 1px solid rgba(0, 255, 204, 0.1);
    color: #ffffff;
    transition: all 0.3s ease-out;
}

/* Module containers */
#workspaces,
#clock,
#battery,
#network,
#bluetooth,
#pulseaudio,
#power,
#tray {
    padding: 0 10px;
    margin: 2px 4px;
    border-radius: 12px;
    transition: all 0.2s ease-out;
}

/* Workspaces - mobile dots */
#workspaces {
    background: rgba(255, 255, 255, 0.05);
    padding: 0 8px;
}

#workspaces button {
    background: transparent;
    color: rgba(255, 255, 255, 0.4);
    padding: 4px 6px;
    margin: 0 2px;
    border-radius: 50%;
    font-size: 14px;
    transition: all 0.2s spring;
}

#workspaces button.active {
    color: #00ffcc;
    background: rgba(0, 255, 204, 0.15);
    transform: scale(1.2);
    box-shadow: 0 0 12px rgba(0, 255, 204, 0.4);
}

#workspaces button:hover {
    color: #ffffff;
    background: rgba(255, 255, 255, 0.1);
}

#workspaces button.urgent {
    color: #ff4444;
    background: rgba(255, 68, 68, 0.15);
    animation: pulse 1s infinite;
}

@keyframes pulse {
    0%, 100% { box-shadow: 0 0 8px rgba(255, 68, 68, 0.4); }
    50% { box-shadow: 0 0 16px rgba(255, 68, 68, 0.8); }
}

/* Clock - prominent time */
#clock {
    background: rgba(0, 255, 204, 0.1);
    color: #00ffcc;
    font-weight: 600;
    font-size: 14px;
    padding: 0 14px;
}

#clock:hover {
    background: rgba(0, 255, 204, 0.2);
    color: #ffffff;
}

/* Battery - with charging animation */
#battery {
    background: rgba(255, 255, 255, 0.05);
    color: #ffffff;
    font-weight: 500;
}

#battery.charging {
    color: #00ffcc;
    animation: charge-pulse 2s ease-in-out infinite;
}

#battery.warning {
    color: #ffaa00;
}

#battery.critical {
    color: #ff4444;
    animation: critical-blink 0.5s infinite;
}

@keyframes charge-pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.6; }
}

@keyframes critical-blink {
    0%, 100% { color: #ff4444; }
    50% { color: #ff0000; }
}

/* Network */
#network {
    background: rgba(255, 255, 255, 0.05);
    color: #ffffff;
}

#network.disconnected {
    color: #ff4444;
}

/* Bluetooth */
#bluetooth {
    background: rgba(255, 255, 255, 0.05);
    color: #00aaff;
}

/* PulseAudio */
#pulseaudio {
    background: rgba(255, 255, 255, 0.05);
    color: #ffffff;
}

#pulseaudio.muted {
    color: #ff4444;
}

/* Power button */
#power {
    background: rgba(255, 255, 255, 0.05);
    color: #ffaa00;
    font-size: 16px;
}

#power:hover {
    background: rgba(255, 170, 0, 0.2);
    color: #ffffff;
}

/* Tray */
#tray {
    background: rgba(255, 255, 255, 0.05);
    padding: 0 8px;
}

#tray > .needs-attention {
    animation: pulse 1s infinite;
}

/* Tooltip styling */
tooltip {
    background: rgba(10, 10, 18, 0.98);
    border: 1px solid rgba(0, 255, 204, 0.2);
    border-radius: 12px;
    padding: 10px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
}

tooltip label {
    color: #ffffff;
    font-size: 12px;
}

/* Scrollbar (if any) */
*::-webkit-scrollbar {
    width: 4px;
    height: 4px;
}

*::-webkit-scrollbar-track {
    background: transparent;
}

*::-webkit-scrollbar-thumb {
    background: rgba(0, 255, 204, 0.3);
    border-radius: 2px;
}

*::-webkit-scrollbar-thumb:hover {
    background: rgba(0, 255, 204, 0.6);
}
EOF

# Create helper scripts
mkdir -p /etc/skel/.config/waybar/scripts

# Battery details script
cat > /etc/skel/.config/waybar/scripts/battery-details.sh << '"'"'EOF'"'"'
#!/bin/bash
# Show detailed battery info in notification

BAT_PATH="/sys/class/power_supply/BAT0"
if [ ! -d "$BAT_PATH" ]; then
    BAT_PATH="/sys/class/power_supply/BAT1"
fi

if [ -d "$BAT_PATH" ]; then
    CAPACITY=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "?")
    STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")
    VOLTAGE=$(cat "$BAT_PATH/voltage_now" 2>/dev/null | awk '{print $1/1000000 "V"}' || echo "?")
    CURRENT=$(cat "$BAT_PATH/current_now" 2>/dev/null | awk '{print $1/1000000 "A"}' || echo "?")
    TEMP=$(cat "$BAT_PATH/temp" 2>/dev/null | awk '{print $1/10 "°C"}' || echo "?")
    HEALTH=$(cat "$BAT_PATH/health" 2>/dev/null || echo "?")

    notify-send "?? Battery Details" \
        "Capacity: $CAPACITY%\nStatus: $STATUS\nVoltage: $VOLTAGE\nCurrent: $CURRENT\nTemp: $TEMP\nHealth: $HEALTH" \
        -t 5000 -i battery
else
    notify-send "?? Battery" "No battery detected" -t 3000
fi
EOF

# Network menu script
cat > /etc/skel/.config/waybar/scripts/network-menu.sh << '"'"'EOF'"'"'
#!/bin/bash
# Toggle WiFi or show network manager
if nmcli radio wifi | grep -q "enabled"; then
    nmcli radio wifi off
    notify-send "?? WiFi" "Disabled" -t 2000
else
    nmcli radio wifi on
    notify-send "?? WiFi" "Enabled" -t 2000
fi
EOF

# Power menu script
cat > /etc/skel/.config/waybar/scripts/power-menu.sh << '"'"'EOF'"'"'
#!/bin/bash
# Show power menu via wofi

CHOICE=$(wofi --show dmenu --width 240 --height 280 --location top_right --anchor top_right --prompt "? Power" << 'MENU'
?? Lock
?? Suspend
?? Reboot
? Power Off
? Cancel
MENU
)

case "$CHOICE" in
    "?? Lock") hyprlock ;;
    "?? Suspend") systemctl suspend ;;
    "?? Reboot") systemctl reboot ;;
    "? Power Off") systemctl poweroff ;;
    *) exit 0 ;;
esac
EOF

chmod +x /etc/skel/.config/waybar/scripts/*.sh
