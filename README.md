# HyprMobile - Raspberry Pi OS 64-bit + Hyprland Mobile

A complete, beautiful mobile Linux experience for Raspberry Pi 3B with Waveshare 3.5" TFT35a display.

## Features

- OS: Raspberry Pi OS Bookworm 64-bit (kernel 6.6+)
- Display: Waveshare 3.5" TFT35a (480x320, SPI, ILI9486) rotated 90 = 320x480 portrait
- Touch: XPT2046 capacitive touch with libinput calibration
- Compositor: Hyprland with parallel animations, gestures, mobile UX
- Lock Screen: hyprlock - iOS/Android style with PIN, time, battery, network
- Status Bar: Waybar - workspaces, clock, battery, WiFi, Bluetooth, volume
- Notifications: Mako + SwayNC - beautiful, actionable, grouped
- Launcher: Wofi - fuzzy search, categories, power menu
- Keyboard: wvkbd (lightweight) + Squeekboard (mobile UX) + Maliit
- Idle: hypridle - dim -> lock -> suspend -> hibernate
- Gestures: 3-finger swipe (workspace), 4-finger (quick settings), pinch zoom, edge swipe
- Apps: Phone, Messages, Contacts, Camera, Gallery, Browser, Terminal, Files, Settings, Clock, Weather, Calendar, Calculator, Recorder, Compass, Flashlight
- Tools: 50+ utilities: btop, fzf, ripgrep, eza, bat, delta, lazygit, glow, viu, chafa, httpie, dog, xh, choose, sd, dust, duf, procs, tokei, hyperfine, rclone, syncthing, tailscale, wireguard, and more
- Optimizations: ZRAM swap, TLP power management, BBR TCP, hardened SSH, fail2ban, UFW

## Hardware Requirements

- Raspberry Pi 3 Model B (1GB RAM, 4x Cortex-A53)
- Waveshare 3.5" TFT35a (SPI display with XPT2046 touch controller)
- microSD card (minimum 8GB, recommended 16GB+ Class 10)
- Power supply (5V 2.5A+ recommended)

## Quick Start

1. Clone and build
2. Run: sudo ./build.sh
3. Choose Docker (recommended) or Native build
4. Flash to SD card
5. Insert into Pi 3B, connect TFT35a, power on

Default login: mobile / mobile
SSH: Enabled on port 22

See build script for detailed options.

