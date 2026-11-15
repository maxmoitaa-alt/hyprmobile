#!/bin/bash -e
# Stage 4: Final tweaks - User, auto-login, system optimization

# =============================================================================
# USER SETUP - Create mobile user with proper groups
# =============================================================================

# Add user to necessary groups
usermod -aG input,video,render,audio,bluetooth,netdev,plugdev,systemd-journal mobile 2>/dev/null || true

# Set password (already set in config, but ensure)
echo "mobile:mobile" | chpasswd

# Configure sudo without password for mobile user
cat > /etc/sudoers.d/99-mobile << '"'"'EOF'"'"'
mobile ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/99-mobile

# =============================================================================
# AUTO-LOGIN - Direct to Hyprland on TTY1
# =============================================================================

# Getty override for auto-login
mkdir -p /etc/systemd/system/getty@tty1.service.d

cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << '"'"'EOF'"'"'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin mobile --noclear %I $TERM
Type=idle
EOF

# =============================================================================
# HYPRLAND AUTO-START - Start Hyprland on login
# =============================================================================

# Add to .zprofile for auto-start on TTY1
cat > /home/mobile/.zprofile << '"'"'EOF'"'"'
# Auto-start Hyprland on TTY1 login
if [[ -z $DISPLAY && -z $WAYLAND_DISPLAY && $(tty) = /dev/tty1 ]]; then
    exec Hyprland
fi
EOF

chown mobile:mobile /home/mobile/.zprofile

# Also add to .bash_profile for bash fallback
cat > /home/mobile/.bash_profile << '"'"'EOF'"'"'
# Auto-start Hyprland on TTY1 login
if [[ -z $DISPLAY && -z $WAYLAND_DISPLAY && $(tty) = /dev/tty1 ]]; then
    exec Hyprland
fi
EOF

chown mobile:mobile /home/mobile/.bash_profile

# =============================================================================
# SYSTEM OPTIMIZATIONS - Pi 3B specific
# =============================================================================

# ZRAM configuration for memory optimization
cat > /etc/systemd/zram-generator.conf << '"'"'EOF'"'"'
[zram0]
zram-size = min(ram, 1024)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

# Sysctl optimizations
cat > /etc/sysctl.d/99-mobile.conf << '"'"'EOF'"'"'
# Mobile optimizations for Pi 3B

# Virtual memory
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.dirty_expire_centisecs = 3000
vm.dirty_writeback_centisecs = 500

# Network
net.core.netdev_max_backlog = 5000
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3

# Filesystem
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512

# Kernel
kernel.sched_autogroup_enabled = 1
kernel.sched_migration_cost_ns = 5000000

# Power
kernel.nmi_watchdog = 0
EOF

# =============================================================================
# TLP configuration for battery optimization
# =============================================================================

cat > /etc/tlp.conf << '"'"'EOF'"'"'
# TLP - Advanced power management for mobile

# Enable TLP
TLP_ENABLE=1

# CPU scaling
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_SCALING_MIN_FREQ_ON_AC=0
CPU_SCALING_MAX_FREQ_ON_AC=0
CPU_SCALING_MIN_FREQ_ON_BAT=0
CPU_SCALING_MAX_FREQ_ON_BAT=1200000

# CPU boost
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0

# GPU
GPU_SCALING_GOVERNOR_ON_AC=performance
GPU_SCALING_GOVERNOR_ON_BAT=powersave

# Disk
DISK_APM_LEVEL_ON_AC="254 254"
DISK_APM_LEVEL_ON_BAT="128 128"
DISK_IOSCHED="mq-deadline"

# SATA link power management
SATA_LINKPWR_ON_AC=max_performance
SATA_LINKPWR_ON_BAT=min_power

# PCIe
PCIE_ASPM_ON_AC=performance
PCIE_ASPM_ON_BAT=powersupersave

# USB
USB_AUTOSUSPEND=1
USB_AUTOSUSPEND_ON_AC=1
USB_AUTOSUSPEND_ON_BAT=1

# Audio
SOUND_POWER_SAVE_ON_AC=1
SOUND_POWER_SAVE_ON_BAT=1
SOUND_POWER_SAVE_CONTROLLER=Y

# WiFi
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# Bluetooth
BLUETOOTH_PWR_ON_AC=on
BLUETOOTH_PWR_ON_BAT=on

# Runtime PM
RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=auto
RUNTIME_PM_ALL=1
EOF

# =============================================================================
# NETWORK - Mobile optimized
# =============================================================================

# NetworkManager configuration
mkdir -p /etc/NetworkManager/conf.d

cat > /etc/NetworkManager/conf.d/99-mobile.conf << '"'"'EOF'"'"'
[main]
dhcp=internal
dns=systemd-resolved
rc-manager=systemd-resolved

[device]
wifi.scan-rand-mac-address=yes
wifi.backend=iwd

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random

[wifi]
rand-mac-address=yes
EOF

# systemd-resolved configuration
mkdir -p /etc/systemd/resolved.conf.d

cat > /etc/systemd/resolved.conf.d/99-mobile.conf << '"'"'EOF'"'"'
[Resolve]
DNS=1.1.1.1 8.8.8.8 9.9.9.9
DNSOverTLS=yes
FallbackDNS=1.0.0.1 8.8.4.4 149.112.112.112
Domains=~.
LLMNR=yes
MulticastDNS=yes
DNSSEC=allow-downgrade
DNSStubListener=yes
ReadEtcHosts=yes
Cache=yes
CacheFromLocalhost=yes
EOF

# =============================================================================
# BLUETOOTH - Mobile optimized
# =============================================================================

mkdir -p /etc/bluetooth

cat > /etc/bluetooth/main.conf << '"'"'EOF'"'"'
[General]
Name = HyprMobile-%h
Class = 0x00210C
DiscoverableTimeout = 0
PairableTimeout = 0
AutoEnable = true
Privacy = device
JustWorksRepairing = always

[Policy]
AutoEnable = true
ReconnectAttempts = 7
ReconnectIntervals = 1, 2, 4, 8, 16, 32, 64
ReconnectUUIDs = 00001112-0000-1000-8000-00805f9b34fb, 0000111f-0000-1000-8000-00805f9b34fb, 0000110a-0000-1000-8000-00805f9b34fb

[Asset]
RemoteAddr = 00:00:00:00:00:00

[GATT]
Cache = yes
EOF

# =============================================================================
# AUDIO - PipeWire mobile config
# =============================================================================

mkdir -p /etc/pipewire/pipewire.conf.d

cat > /etc/pipewire/pipewire.conf.d/99-mobile.conf << '"'"'EOF'"'"'
context.properties = {
    default.clock.rate = 48000
    default.clock.quantum = 1024
    default.clock.min-quantum = 32
    default.clock.max-quantum = 8192
}
EOF

mkdir -p /etc/wireplumber/wireplumber.conf.d

cat > /etc/wireplumber/wireplumber.conf.d/99-mobile.conf << '"'"'EOF'"'"'
wireplumber.components = [
    { name = libwireplumber-module-lua-scripting }
    { name = libwireplumber-module-device-api }
    { name = libwireplumber-module-link-factory }
    { name = libwireplumber-module-metadata }
    { name = libwireplumber-module-ports }
    { name = libwireplumber-module-profiler }
    { name = libwireplumber-module-reserve-device }
    { name = libwireplumber-module-route-factory }
    { name = libwireplumber-module-session-policy }
    { name = libwireplumber-module-standard-event-source }
    { name = libwireplumber-module-stream-restore }
]

monitor.alsa.rules = [
    { matches = [ { device.name = "~alsa_card.*" } ] actions = { update-props = { device.profile-set = "mobile.conf" } } }
]
EOF

# =============================================================================
# FIRMWARE - Copy TFT35a overlay if available
# =============================================================================

mkdir -p /boot/firmware/overlays

cat > /boot/firmware/overlays/README-tft35a.txt << '"'"'EOF'"'"'
TFT35a Overlay Installation
============================

This image expects the Waveshare TFT35a overlay file at:
/boot/firmware/overlays/tft35a.dtbo

If the display doesn'"'"'t work, you need to:

1. Download the overlay from Waveshare:
   wget https://www.waveshare.com/w/upload/4/45/TFT35a-overlay.dtb

2. Copy to overlays:
   sudo cp TFT35a-overlay.dtb /boot/firmware/overlays/tft35a.dtbo

3. Reboot:
   sudo reboot

The config.txt already includes:
dtoverlay=tft35a:rotate=90
dtoverlay=xpt2046-spi0-1,int_pin=25

For other rotations, change rotate parameter:
0 = 0°, 1 = 90°, 2 = 180°, 3 = 270°
EOF

# =============================================================================
# FIRST BOOT SCRIPT - Runs on first boot for final setup
# =============================================================================

cat > /usr/local/bin/hyprmobile-firstboot << '"'"'EOF'"'"'
#!/bin/bash
# HyprMobile First Boot Setup
# Runs once on first boot to finalize configuration

FLAG_FILE="/etc/.hyprmobile_firstboot_done"

if [ -f "$FLAG_FILE" ]; then
    exit 0
fi

echo "?? HyprMobile: Running first boot setup..."

# Update system
apt-get update && apt-get upgrade -y

# Regenerate font cache
fc-cache -fv

# Update MIME database
update-mime-database /usr/share/mime

# Update desktop database
update-desktop-database /usr/share/applications

# Update icon cache
gtk-update-icon-cache -f /usr/share/icons/Adwaita

# Enable user services
systemctl --user daemon-reload 2>/dev/null || true

# Set up touchscreen calibration if needed
if [ ! -f /etc/.touch_calibrated ]; then
    echo "Touchscreen calibration pending - run calibrate-touch after desktop loads"
fi

# Create flag
touch "$FLAG_FILE"

echo "?? HyprMobile: First boot setup complete!"
notify-send "?? HyprMobile Ready" "First boot setup complete! Enjoy your Pi Phone." -t 5000
EOF

chmod +x /usr/local/bin/hyprmobile-firstboot

# Systemd service for first boot
cat > /etc/systemd/system/hyprmobile-firstboot.service << '"'"'EOF'"'"'
[Unit]
Description=HyprMobile First Boot Setup
After=graphical.target network-online.target
Wants=network-online.target
ConditionPathExists=!/etc/.hyprmobile_firstboot_done

[Service]
Type=oneshot
ExecStart=/usr/local/bin/hyprmobile-firstboot
RemainAfterExit=yes
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF

systemctl enable hyprmobile-firstboot.service

# =============================================================================
# HOSTNAME & LOCALE
# =============================================================================

echo "hyprmobile" > /etc/hostname

cat > /etc/hosts << '"'"'EOF'"'"'
127.0.0.1    localhost
127.0.1.1    hyprmobile

::1          localhost ip6-localhost ip6-loopback
ff02::1      ip6-allnodes
ff02::2      ip6-allrouters
EOF

# =============================================================================
# TIMEZONE & LOCALE
# =============================================================================

timedatectl set-timezone America/Sao_Paulo

locale-gen pt_BR.UTF-8
update-locale LANG=pt_BR.UTF-8

# =============================================================================
# SSH - Enable and configure
# =============================================================================

systemctl enable ssh

cat > /etc/ssh/sshd_config.d/99-mobile.conf << '"'"'EOF'"'"'
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
LoginGraceTime 30
Banner /etc/ssh/banner
EOF

cat > /etc/ssh/banner << '"'"'EOF'"'"'
#############################################################
#                    ?? HyprMobile SSH                      #
#          Unauthorized access is prohibited!               #
#############################################################
EOF

# =============================================================================
# FIREWALL - UFW rules for mobile
# =============================================================================

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 53/udp
ufw allow 67/udp
ufw allow 68/udp
ufw --force enable

# =============================================================================
# FAIL2BAN - SSH protection
# =============================================================================

cat > /etc/fail2ban/jail.d/sshd.conf << '"'"'EOF'"'"'
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
ignoreip = 127.0.0.1/8 ::1
EOF

systemctl enable fail2ban
# =============================================================================
# CLEANUP - Remove unnecessary packages and files
# =============================================================================

# Remove packages not needed for mobile
apt-get purge -y \
    libreoffice* \
    thunderbird* \
    rhythmbox* \
    totem* \
    gnome-mahjongg* \
    gnome-mines* \
    gnome-sudoku* \
    aisleriot* \
    gnome-2048* \
    gnome-robots* \
    gnome-taquin* \
    gnome-tetravex* \
    gnome-nibbles* \
    lightsoff* \
    quadrapassel* \
    swell-foop* \
    four-in-a-row* \
    five-or-more* \
    hitori* \
    iagno* \
    lightsoff* \
    tali* \
    2>/dev/null || true

# Clean apt
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -rf /var/tmp/*

# Remove documentation
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*

# Remove locales we don'"'"'t need (keep pt_BR and en_US)
for locale in /usr/share/locale/*; do
    case $(basename "$locale") in
        pt_BR|pt|en_US|en|C|C.UTF-8|POSIX) ;;
        *) rm -rf "$locale" ;;
    esac
done

# =============================================================================
# FINAL PERMISSIONS
# =============================================================================

chown -R mobile:mobile /home/mobile
chmod 700 /home/mobile/.ssh 2>/dev/null || true
chmod 600 /home/mobile/.ssh/authorized_keys 2>/dev/null || true

# Ensure scripts are executable
find /home/mobile/.config/hypr/scripts -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find /home/mobile/.config/waybar/scripts -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

echo "? Stage 4 complete: HyprMobile configured and optimized!"
