#!/bin/bash -e
# Stage 3: Autostart - Systemd user services, environment, session

# =============================================================================
# SYSTEMD USER SERVICES - Enable by default
# =============================================================================
mkdir -p /etc/skel/.config/systemd/user/default.target.wants

# Enable core services
ln -sf /usr/lib/systemd/user/wvkbd.service /etc/skel/.config/systemd/user/default.target.wants/wvkbd.service 2>/dev/null || true
ln -sf /usr/lib/systemd/user/squeekboard.service /etc/skel/.config/systemd/user/default.target.wants/squeekboard.service 2>/dev/null || true
ln -sf /usr/lib/systemd/user/mako.service /etc/skel/.config/systemd/user/default.target.wants/mako.service 2>/dev/null || true
ln -sf /usr/lib/systemd/user/swaync.service /etc/skel/.config/systemd/user/default.target.wants/swaync.service 2>/dev/null || true
ln -sf /usr/lib/systemd/user/waybar.service /etc/skel/.config/systemd/user/default.target.wants/waybar.service 2>/dev/null || true
ln -sf /usr/lib/systemd/user/hypridle.service /etc/skel/.config/systemd/user/default.target.wants/hypridle.service 2>/dev/null || true
ln -sf /usr/lib/systemd/user/libinput-gestures.service /etc/skel/.config/systemd/user/default.target.wants/libinput-gestures.service 2>/dev/null || true
ln -sf /usr/lib/systemd/user/gesture-daemon.service /etc/skel/.config/systemd/user/default.target.wants/gesture-daemon.service 2>/dev/null || true

# Create service files if they dont exist in system location
mkdir -p /etc/skel/.config/systemd/user

# Waybar service
cat > /etc/skel/.config/systemd/user/waybar.service << '"'"'EOF'"'"'
[Unit]
Description=Waybar - Mobile status bar
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css
Restart=on-failure
RestartSec=2
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=/run/user/1000

[Install]
WantedBy=graphical-session.target
EOF

# Mako service
cat > /etc/skel/.config/systemd/user/mako.service << '"'"'EOF'"'"'
[Unit]
Description=Mako - Notification daemon
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/mako
Restart=on-failure
RestartSec=2
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=/run/user/1000

[Install]
WantedBy=graphical-session.target
EOF

# SwayNC service
cat > /etc/skel/.config/systemd/user/swaync.service << '"'"'EOF'"'"'
[Unit]
Description=SwayNC - Notification center
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/swaync
Restart=on-failure
RestartSec=2
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=/run/user/1000

[Install]
WantedBy=graphical-session.target
EOF

# Hypridle service
cat > /etc/skel/.config/systemd/user/hypridle.service << '"'"'EOF'"'"'
[Unit]
Description=Hypridle - Idle management
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/hypridle
Restart=on-failure
RestartSec=2
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=/run/user/1000

[Install]
WantedBy=graphical-session.target
EOF

# =============================================================================
# ENVIRONMENT VARIABLES - Systemd user environment
# =============================================================================
mkdir -p /etc/skel/.config/environment.d

cat > /etc/skel/.config/environment.d/10-wayland.conf << '"'"'EOF'"'"'
# Wayland environment
WAYLAND_DISPLAY=wayland-0
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_DESKTOP=Hyprland
XDG_SESSION_TYPE=wayland
XDG_SESSION_CLASS=user
EOF

cat > /etc/skel/.config/environment.d/20-toolkit.conf << '"'"'EOF'"'"'
# Toolkit backends
QT_QPA_PLATFORM=wayland
QT_QPA_PLATFORMTHEME=qt6ct
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
GDK_BACKEND=wayland
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland
ELECTRON_OZONE_PLATFORM_HINT=wayland
MOZ_ENABLE_WAYLAND=1
_JAVA_AWT_WM_NONREPARENTING=1
EOF

cat > /etc/skel/.config/environment.d/30-input-method.conf << '"'"'EOF'"'"'
# Input methods
GTK_IM_MODULE=wayland
QT_IM_MODULE=wayland
SDL_IM_MODULE=wayland
CLUTTER_IM_MODULE=wayland
EOF

cat > /etc/skel/.config/environment.d/40-cursor.conf << '"'"'EOF'"'"'
# Cursor theme
XCURSOR_THEME=Adwaita
XCURSOR_SIZE=24
EOF

cat > /etc/skel/.config/environment.d/50-mobile.conf << '"'"'EOF'"'"'
# Mobile optimizations
WLR_NO_HARDWARE_CURSORS=1
WLR_RENDERER_ALLOW_SOFTWARE=1
LIBVA_DRIVER_NAME=v3d
VDPAU_DRIVER=v3d
GST_VAAPI_ALL_DRIVERS=1
EOF

# =============================================================================
# AUTOSTART DESKTOP ENTRIES - For non-systemd apps
# =============================================================================
mkdir -p /etc/skel/.config/autostart

# NM Applet
cat > /etc/skel/.config/autostart/nm-applet.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Type=Application
Name=Network Manager Applet
Exec=nm-applet --indicator
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
OnlyShowIn=Hyprland;
EOF

# Blueman Applet
cat > /etc/skel/.config/autostart/blueman-applet.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Type=Application
Name=Blueman Applet
Exec=blueman-applet
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
OnlyShowIn=Hyprland;
EOF

# Polkit agent
cat > /etc/skel/.config/autostart/hyprpolkitagent.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Type=Application
Name=Hyprland Polkit Agent
Exec=hyprpolkitagent
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
OnlyShowIn=Hyprland;
EOF

# XDG Desktop Portal
cat > /etc/skel/.config/autostart/xdg-desktop-portal.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Type=Application
Name=XDG Desktop Portal
Exec=/usr/libexec/xdg-desktop-portal-hyprland
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
OnlyShowIn=Hyprland;
EOF

# =============================================================================
# USER PROFILE - Shell configuration
# =============================================================================
mkdir -p /etc/skel

# Zsh configuration (modern, mobile-friendly)
cat > /etc/skel/.zshrc << '"'"'EOF'"'"'
# Mobile-optimized Zsh configuration

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Completion
autoload -Uz compinit
compinit
zstyle ":completion:*" menu select
zstyle ":completion:*" matcher-list "m:{a-z}={A-Z}"

# Prompt - Starship (installed)
eval "$(starship init zsh)"

# Aliases - Mobile friendly
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first"
alias la="eza -la --icons --group-directories-first"
alias lt="eza --tree --icons"
alias cat="bat --style=plain"
alias grep="rg"
alias find="fd"
alias top="btop"
alias htop="btop"
alias df="duf"
alias du="dust"
alias ps="procs"
alias ssh="kitten ssh"

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline -20"
alias gd="git diff"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# Mobile specific
alias brightness="brightnessctl"
alias volume="wpctl set-volume @DEFAULT_AUDIO_SINK@"
alias battery="cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null"
alias wifi="nmtui"
alias bluetooth="blueman-manager"
alias lock="hyprlock"
alias suspend="systemctl suspend"
alias reboot="systemctl reboot"
alias poweroff="systemctl poweroff"

# Keyboard toggle
alias kb="~/.config/hypr/scripts/toggle-keyboard.sh"
alias keyboard="~/.config/hypr/scripts/toggle-keyboard.sh"

# Apps
alias browser="firefox-esr"
alias term="foot"
alias files="nemo"
alias settings="gnome-control-center"

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar x "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "Unknown archive format: $1" ;;
        esac
    else
        echo "File not found: $1"
    fi
}

# Mobile info
mobile-info() {
    echo "?? HyprMobile System Info"
    echo "========================="
    echo "Host: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "Memory: $(free -h | awk "/Mem:/ {print \$3 \"/\" \$2}")"
    echo "Disk: $(df -h / | awk "NR==2 {print \$3 \"/\" \$2 \" (\" \$5 \")\"}")"
    echo "Battery: $(battery)%"
    echo "CPU Temp: $(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk "{print \$1/1000 \"°C\"}" || echo "N/A")"
    echo "IP: $(ip -4 addr show wlan0 | grep -oP "(?<=inet )[\d.]+")"
}

# Welcome message
fastfetch --logo-type kitty --logo ~/.config/fastfetch/logo.png 2>/dev/null || mobile-info
EOF

# Starship configuration - mobile prompt
mkdir -p /etc/skel/.config
cat > /etc/skel/.config/starship.toml << '"'"'EOF'"'"'
# Starship prompt - Mobile minimal

format = """$username$hostname$directory$git_branch$git_status$character"""

[username]
show_always = true
style_user = "bold cyan"
style_root = "bold red"
format = "[$user]("

[hostname]
ssh_only = false
format = "@[$hostname](bold yellow) "
disabled = false

[directory]
style = "bold blue"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = "?? "
style = "bold magenta"
format = "[$symbol$branch]("

[git_status]
conflicted = "?? "
ahead = "?? "
behind = "?? "
diverged = "?? "
untracked = "? "
stashed = "?? "
modified = "?? "
staged = "? "
renamed = "?? "
deleted = "??? "
style = "bold red"
format = "([$all_status](bold red))"

[character]
success_symbol = "[?](bold green)"
error_symbol = "[?](bold red)"
vicmd_symbol = "[?](bold yellow)"

[cmd_duration]
min_time = 2000
format = "took [$duration](bold yellow) "

[package]
disabled = true

[nodejs]
disabled = true

[rust]
disabled = true

[python]
disabled = true

[golang]
disabled = true

[docker_context]
disabled = true

[kubernetes]
disabled = true

[aws]
disabled = true

[gcloud]
disabled = true

[azure]
disabled = true
EOF

# Fastfetch configuration - mobile system info
mkdir -p /etc/skel/.config/fastfetch

cat > /etc/skel/.config/fastfetch/config.jsonc << '"'"'EOF'"'"'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "~/.config/fastfetch/logo.txt",
        "color": "auto",
        "padding": {
            "top": 2,
            "left": 2,
            "right": 2
        }
    },
    "display": {
        "separator": "  ",
        "color": "auto",
        "keys": [
            "os",
            "kernel",
            "uptime",
            "packages",
            "shell",
            "de",
            "wm",
            "memory",
            "disk",
            "cpu",
            "gpu",
            "battery",
            "localip"
        ]
    },
    "modules": {
        "os": {
            "key": "?? OS",
            "keyColor": "cyan"
        },
        "kernel": {
            "key": "?? Kernel",
            "keyColor": "cyan"
        },
        "uptime": {
            "key": "?? Uptime",
            "keyColor": "cyan"
        },
        "packages": {
            "key": "?? Packages",
            "keyColor": "cyan"
        },
        "shell": {
            "key": "?? Shell",
            "keyColor": "cyan"
        },
        "de": {
            "key": "??? DE",
            "keyColor": "cyan"
        },
        "wm": {
            "key": "?? WM",
            "keyColor": "cyan"
        },
        "memory": {
            "key": "?? Memory",
            "keyColor": "cyan"
        },
        "disk": {
            "key": "?? Disk",
            "keyColor": "cyan"
        },
        "cpu": {
            "key": "? CPU",
            "keyColor": "cyan"
        },
        "gpu": {
            "key": "?? GPU",
            "keyColor": "cyan"
        },
        "battery": {
            "key": "?? Battery",
            "keyColor": "cyan"
        },
        "localip": {
            "key": "?? IP",
            "keyColor": "cyan"
        }
    }
}
EOF

# ASCII logo for fastfetch
cat > /etc/skel/.config/fastfetch/logo.txt << '"'"'EOF'"'"'
      ¦¦+  ¦¦+¦¦¦¦¦¦¦+¦¦+  ¦¦+¦¦¦¦¦¦+ 
      ¦¦¦  ¦¦¦¦¦+----+¦¦¦  ¦¦¦¦¦+--¦¦+
      ¦¦¦¦¦¦¦¦¦¦¦¦¦+  ¦¦¦¦¦¦¦¦¦¦¦¦¦¦++
      ¦¦+--¦¦¦¦¦+--+  ¦¦+--¦¦¦¦¦+--¦¦+
      ¦¦¦  ¦¦¦¦¦¦¦¦¦¦+¦¦¦  ¦¦¦¦¦¦  ¦¦¦
      +-+  +-++------++-+  +-++-+  +-+
           ¦¦+   ¦¦+¦¦¦¦¦¦+ ¦¦¦¦¦¦+ 
           ¦¦¦   ¦¦¦¦¦+--¦¦+¦¦+--¦¦+
           ¦¦¦   ¦¦¦¦¦¦¦¦¦++¦¦¦¦¦¦++
           ¦¦¦   ¦¦¦¦¦+---+ ¦¦+--¦¦+
           +¦¦¦¦¦¦++¦¦¦     ¦¦¦  ¦¦¦
            +-----+ +-+     +-+  +-+
EOF

# Bash configuration (fallback)
cat > /etc/skel/.bashrc << '"'"'EOF'"'"'
# Mobile-optimized Bash configuration

# If not running interactively, don"'"'t do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Check window size
shopt -s checkwinsize

# Prompt - simple but nice
PS1='"'"'\[\033[01;36m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"'"'

# Aliases
alias ls="'"'"'ls --color=auto -h'"'"'"
alias ll="'"'"'ls -la'"'"'"
alias la="'"'"'ls -A'"'"'"
alias grep="'"'"'grep --color=auto'"'"'"
alias fgrep="'"'"'fgrep --color=auto'"'"'"
alias egrep="'"'"'egrep --color=auto'"'"'"

# Mobile aliases
alias brightness="'"'"'brightnessctl'"'"'"
alias volume="'"'"'wpctl set-volume @DEFAULT_AUDIO_SINK@'"'"'"
alias battery="'"'"'cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null'"'"'"
alias wifi="'"'"'nmtui'"'"'"
alias bluetooth="'"'"'blueman-manager'"'"'"
alias lock="'"'"'hyprlock'"'"'"
alias suspend="'"'"'systemctl suspend'"'"'"
alias kb="'"'"'~/.config/hypr/scripts/toggle-keyboard.sh'"'"'"

# Load starship if available
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
EOF

# =============================================================================
# HYPRLAND SESSION - Desktop entry for login managers
# =============================================================================
mkdir -p /usr/share/wayland-sessions

cat > /usr/share/wayland-sessions/hyprland.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Hyprland
Name[pt_BR]=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Comment[pt_BR]=Um compositor Wayland inteligente e dinâmico
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF

# Hyprland desktop file for applications menu
cat > /usr/share/applications/hyprland.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Hyprland
Name[pt_BR]=Hyprland
Comment=Wayland Compositor
Comment[pt_BR]=Compositor Wayland
Exec=Hyprland
Icon=hyprland
Type=Application
Categories=System;WindowManager;
Keywords=wayland;compositor;tiling;mobile;
EOF
