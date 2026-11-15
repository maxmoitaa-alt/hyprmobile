#!/bin/bash -e
# Stage 3: Install Hyprland and dependencies (already in package list, but verify)

# Ensure Hyprland is installed
apt-get update
apt-get install -y --no-install-recommends \
    hyprland hyprlock hypridle hyprpolkitagent \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    qt6-wayland qt5-wayland \
    waybar wofi mako swaync \
    grim slurp wl-clipboard wtype wlr-randr \
    wvkbd squeekboard maliit-keyboard \
    network-manager network-manager-gnome \
    bluez blueman \
    pipewire wireplumber pipewire-pulse pavucontrol \
    brightnessctl playerctl upower udisks2 \
    foot kitty zsh fish starship \
    nemo thunar gvfs gvfs-backends file-roller \
    firefox-esr chromium \
    geary gnome-clocks gnome-weather gnome-calendar gnome-contacts \
    baobab gnome-disk-utility \
    fonts-noto fonts-noto-color-emoji fonts-firacode fonts-jetbrains-mono \
    adwaita-icon-theme adwaita-qt \
    tlp tlp-rdw powertop zram-tools \
    cups cups-client system-config-printer simple-scan \
    tesseract-ocr tesseract-ocr-por \
    ufw fail2ban \
    timeshift borgbackup restic rsync

# Enable services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable pipewire
systemctl enable wireplumber
systemctl enable tlp
systemctl enable zramswap
systemctl enable cups
systemctl enable ufw
systemctl enable fail2ban

# Configure ufw
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
