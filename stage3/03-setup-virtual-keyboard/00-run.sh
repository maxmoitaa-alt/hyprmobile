#!/bin/bash -e
# Stage 3: Virtual Keyboard - wvkbd (lightweight) + squeekboard (mobile UX)

# Create wvkbd configuration
mkdir -p /etc/skel/.config/wvkbd

cat > /etc/skel/.config/wvkbd/wvkbd-mobintl.css << '"'"'EOF'"'"'
/* wvkbd-mobile-intl style - Mobile perfect */
* {
    background: rgba(10, 10, 18, 0.98);
    color: #ffffff;
    border: none;
    border-radius: 8px;
    font-family: "Inter", "Noto Sans", sans-serif;
    font-size: 18px;
}

window {
    background: rgba(10, 10, 18, 0.98);
    border: 1px solid rgba(0, 255, 204, 0.2);
    border-radius: 16px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
}

.key {
    background: rgba(255, 255, 255, 0.08);
    color: #ffffff;
    border-radius: 10px;
    padding: 12px 8px;
    margin: 3px;
    min-width: 40px;
    min-height: 48px;
    transition: all 0.1s ease-out;
}

.key:hover,
.key:active {
    background: rgba(0, 255, 204, 0.3);
    color: #0a0a12;
    transform: scale(1.05);
}

.key:focus {
    outline: 2px solid #00ffcc;
    outline-offset: 2px;
}

.key.special {
    background: rgba(0, 255, 204, 0.15);
    color: #00ffcc;
    font-weight: 600;
}

.key.special:hover {
    background: rgba(0, 255, 204, 0.3);
    color: #0a0a12;
}

.key.shift.active,
.key.caps.active {
    background: #00ffcc;
    color: #0a0a12;
}

.key.space {
    min-width: 160px;
}

.key.backspace,
.key.enter {
    min-width: 60px;
}

.row {
    margin: 2px 0;
}

.suggestions {
    background: rgba(255, 255, 255, 0.05);
    border-top: 1px solid rgba(0, 255, 204, 0.1);
    padding: 8px;
}

.suggestion {
    background: rgba(255, 255, 255, 0.08);
    padding: 8px 16px;
    margin: 0 4px;
    border-radius: 20px;
    font-size: 16px;
}

.suggestion:hover {
    background: rgba(0, 255, 204, 0.2);
}

.hidden {
    display: none;
}
EOF

# Create systemd user service for wvkbd
mkdir -p /etc/skel/.config/systemd/user

cat > /etc/skel/.config/systemd/user/wvkbd.service << '"'"'EOF'"'"'
[Unit]
Description=Virtual Keyboard (wvkbd-mobile-intl)
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/wvkbd-mobintl -H 200 -L 400 --css /home/mobile/.config/wvkbd/wvkbd-mobintl.css
Restart=on-failure
RestartSec=2
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=/run/user/1000

[Install]
WantedBy=graphical-session.target
EOF

# Create systemd user service for squeekboard (alternative, better UX)
cat > /etc/skel/.config/systemd/user/squeekboard.service << '"'"'EOF'"'"'
[Unit]
Description=Squeekboard Virtual Keyboard (GNOME mobile keyboard)
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/squeekboard
Restart=on-failure
RestartSec=2
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=/run/user/1000
Environment=GTK_IM_MODULE=squeekboard
Environment=QT_IM_MODULE=squeekboard
Environment=SDL_IM_MODULE=squeekboard

[Install]
WantedBy=graphical-session.target
EOF

# Create maliit configuration (another option)
mkdir -p /etc/skel/.config/maliit

cat > /etc/skel/.config/maliit/maliit.conf << '"'"'EOF'"'"'
[General]
# Maliit keyboard settings for mobile
layout=br
theme=dark
key-size=large
haptic-feedback=true
sound-feedback=false
auto-capitalize=true
auto-correct=true
spell-check=true
swipe-typing=true
voice-input=true
emoji-panel=true
clipboard-panel=true
EOF

# Create keyboard manager script (chooses best available)
cat > /etc/skel/.config/hypr/scripts/keyboard-manager.sh << '"'"'EOF'"'"'
#!/bin/bash
# Smart keyboard manager - chooses best virtual keyboard

KEYBOARD_TYPE="${1:-auto}"

case "$KEYBOARD_TYPE" in
    auto)
        # Try squeekboard first (best UX), fallback to wvkbd
        if command -v squeekboard &> /dev/null; then
            exec squeekboard
        elif command -v wvkbd-mobintl &> /dev/null; then
            exec wvkbd-mobintl -H 200 -L 400 --css ~/.config/wvkbd/wvkbd-mobintl.css
        else
            notify-send "?? Keyboard" "No virtual keyboard found!" -u critical
            exit 1
        fi
        ;;
    wvkbd)
        exec wvkbd-mobintl -H 200 -L 400 --css ~/.config/wvkbd/wvkbd-mobintl.css
        ;;
    squeekboard)
        exec squeekboard
        ;;
    maliit)
        exec maliit-keyboard
        ;;
    *)
        echo "Usage: $0 [auto|wvkbd|squeekboard|maliit]"
        exit 1
        ;;
esac
EOF

chmod +x /etc/skel/.config/hypr/scripts/keyboard-manager.sh

# Create keyboard toggle with animation
cat > /etc/skel/.config/hypr/scripts/toggle-keyboard.sh << '"'"'EOF'"'"'
#!/bin/bash
# Toggle virtual keyboard with smooth animation

KB_PID=$(pgrep -f "wvkbd-mobintl|squeekboard|maliit-keyboard" | head -1)

if [ -n "$KB_PID" ]; then
    # Hide keyboard with animation
    hyprctl dispatch closelayer keyboard 2>/dev/null
    pkill -f "wvkbd-mobintl|squeekboard|maliit-keyboard"
    notify-send "?? Keyboard" "Hidden" -t 800 -i keyboard
else
    # Show keyboard
    ~/.config/hypr/scripts/keyboard-manager.sh auto &
    notify-send "?? Keyboard" "Shown" -t 800 -i keyboard
fi
EOF

chmod +x /etc/skel/.config/hypr/scripts/toggle-keyboard.sh

# Create input method environment
cat > /etc/skel/.config/environment.d/99-input-method.conf << '"'"'EOF'"'"'
# Input method for virtual keyboards
GTK_IM_MODULE=wayland
QT_IM_MODULE=wayland
SDL_IM_MODULE=wayland
CLUTTER_IM_MODULE=wayland
EOF

# Enable user services by default
mkdir -p /etc/skel/.config/systemd/user/default.target.wants
ln -sf /usr/lib/systemd/user/wvkbd.service /etc/skel/.config/systemd/user/default.target.wants/wvkbd.service 2>/dev/null || true

# Create desktop entry for keyboard settings
mkdir -p /etc/skel/.local/share/applications

cat > /etc/skel/.local/share/applications/keyboard-settings.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Keyboard Settings
Name[pt_BR]=Configurações do Teclado
Comment=Configure virtual keyboard
Comment[pt_BR]=Configurar teclado virtual
Exec=wofi --show drun --prompt "?? Keyboard"
Icon=preferences-desktop-keyboard
Terminal=false
Type=Application
Categories=Settings;HardwareSettings;
Keywords=keyboard;virtual;touchscreen;mobile;
EOF
