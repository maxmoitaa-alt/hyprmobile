#!/bin/bash -e
# Stage 3: Notifications (mako), Launcher (wofi), Mobile Apps

# =============================================================================
# MAKO - Beautiful notifications
# =============================================================================
mkdir -p /etc/skel/.config/mako

cat > /etc/skel/.config/mako/config << '"'"'EOF'"'"'
# Mako notification daemon - Mobile style
# Top-right, stacked, beautiful animations

layer=overlay
anchor=top-right
width=300
height=100
margin=12,12
padding=16
background-color=#0a0a12ee
border-color=#00ffcc
border-size=2
border-radius=16
text-color=#ffffff
actions-enabled=true
format=%s%n%b
max-visible=3
default-timeout=5000
ignore-timeout=0
font=Inter 12
markup=true

# Urgency colors
[urgency=low]
background-color=#0a0a12ee
border-color=#00ffcc
text-color=#ffffff
default-timeout=3000

[urgency=normal]
background-color=#0a0a12ee
border-color=#00ffcc
text-color=#ffffff
default-timeout=5000

[urgency=critical]
background-color=#2a0a0aee
border-color=#ff4444
text-color=#ffaaaa
default-timeout=0

# Animation
animation=slide-from-right
animation-duration=300
easing=easeOutExpo
EOF

# =============================================================================
# WOFI - App launcher / Run dialog / Power menu
# =============================================================================
mkdir -p /etc/skel/.config/wofi

cat > /etc/skel/.config/wofi/config << '"'"'EOF'"'"'
# Wofi - Mobile app launcher
# iOS/Android style app drawer

# General
width=300
height=420
location=top_right
anchor=top_right
margin=12,60
padding=16
border-radius=16
border-width=1
border-color=#00ffcc

# Appearance
background-color=#0a0a12ee
text-color=#ffffff
selection-color=#00ffcc
selection-background-color=rgba(0,255,204,0.15)
separator-color=rgba(255,255,255,0.05)

# Fonts
font=Inter 14
prompt-font=JetBrains Mono 13

# Behavior
show-icons=true
icon-size=28
allow-images=true
insensitive=true
matching=fuzzy
sort-order=default
lines=8
columns=1

# Animation
animation=slide-up
animation-duration=250

# Modes
mode=drun
show-drun=true
drun-format={icon} {name}
drun-print-format={exec}
drun-match-fields=name;generic;categories;keywords;exec
drun-categories=All;Favorites;System;Internet;Multimedia;Office;Graphics;Development;Settings
drun-show-actions=false
drun-use-desktop-name=true

# Run mode
show-run=true
run-format={name}
run-print-format={exec}

# Window mode
show-window=true
window-format={icon} {title}
window-match-fields=title;class

# Power menu mode (custom)
# Will be created as a separate style
EOF

# Wofi styles for different modes
cat > /etc/skel/.config/wofi/style.css << '"'"'EOF'"'"'
/* Wofi Mobile Style - iOS/Android aesthetic */

window {
    background: rgba(10, 10, 18, 0.98);
    border: 1px solid rgba(0, 255, 204, 0.2);
    border-radius: 16px;
    box-shadow: 0 16px 48px rgba(0, 0, 0, 0.6);
}

#input {
    background: rgba(255, 255, 255, 0.05);
    border: none;
    border-radius: 12px;
    padding: 12px 16px;
    margin: 0 12px 12px;
    color: #ffffff;
    font-size: 14px;
    caret-color: #00ffcc;
}

#input:focus {
    background: rgba(0, 255, 204, 0.1);
    outline: 2px solid #00ffcc;
    outline-offset: 2px;
}

#input placeholder {
    color: rgba(255, 255, 255, 0.4);
}

#outer-box {
    margin: 0;
    padding: 0;
}

#inner-box {
    margin: 0;
    padding: 0 12px 12px;
}

#scroll {
    margin: 0;
    padding: 0;
}

#flow-box {
    margin: 0;
    padding: 0;
}

#entry {
    background: transparent;
    border: none;
    border-radius: 10px;
    padding: 12px 16px;
    margin: 4px 0;
    color: #ffffff;
    transition: all 0.15s ease-out;
}

#entry:hover,
#entry:selected {
    background: rgba(0, 255, 204, 0.15);
    color: #00ffcc;
}

#entry:selected {
    outline: none;
    box-shadow: inset 3px 0 0 #00ffcc;
}

#entry image {
    margin-right: 12px;
    min-width: 28px;
    min-height: 28px;
}

#text {
    font-size: 14px;
    font-weight: 400;
}

#entry:selected #text {
    color: #00ffcc;
    font-weight: 500;
}

#unselected {
    color: rgba(255, 255, 255, 0.6);
}

#separator {
    background: rgba(255, 255, 255, 0.03);
    margin: 8px 12px;
    min-height: 1px;
}

#category {
    color: #00ffcc;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    padding: 8px 16px 4px;
    margin: 0;
}

/* Power menu specific */
#power-entry {
    min-height: 56px;
    padding: 16px;
}

#power-entry image {
    min-width: 32px;
    min-height: 32px;
    margin-right: 16px;
}

#power-entry #text {
    font-size: 16px;
    font-weight: 500;
}
EOF

# Power menu style
cat > /etc/skel/.config/wofi/power.css << '"'"'EOF'"'"'
/* Power Menu Style - Large touch targets */

window {
    background: rgba(10, 10, 18, 0.98);
    border: 1px solid rgba(0, 255, 204, 0.2);
    border-radius: 16px;
    box-shadow: 0 16px 48px rgba(0, 0, 0, 0.6);
    width: 280px;
    height: 300px;
}

#input {
    display: none;
}

#inner-box {
    padding: 20px;
}

#entry {
    background: rgba(255, 255, 255, 0.05);
    border-radius: 12px;
    padding: 16px 20px;
    margin: 8px 0;
    min-height: 56px;
    transition: all 0.15s ease-out;
}

#entry:hover,
#entry:selected {
    background: rgba(0, 255, 204, 0.15);
    transform: scale(1.02);
}

#entry image {
    min-width: 28px;
    min-height: 28px;
    margin-right: 16px;
}

#text {
    font-size: 16px;
    font-weight: 500;
    color: #ffffff;
}

#entry:selected #text {
    color: #00ffcc;
}

.cancel-entry {
    color: #ff4444;
}

.cancel-entry:selected {
    background: rgba(255, 68, 68, 0.15) !important;
}
EOF

# =============================================================================
# SWAYNC - Notification center (alternative to mako)
# =============================================================================
mkdir -p /etc/skel/.config/swaync

cat > /etc/skel/.config/swaync/config.json << '"'"'EOF'"'"'
{
    "positionX": "right",
    "positionY": "top",
    "layer": "overlay",
    "control-center-width": 320,
    "control-center-height": 480,
    "control-center-margin-top": 44,
    "control-center-margin-bottom": 12,
    "control-center-margin-right": 12,
    "control-center-margin-left": 12,
    "notification-2fa-action": true,
    "notification-inline-replies": true,
    "notification-body-markup": true,
    "notification-icon-size": 24,
    "notification-body-hide": false,
    "notification-action-hide": false,
    "notification-grouping": true,
    "notification-grouping-min-notifications": 3,
    "notification-grouping-merge-type": "merge",
    "notification-grouping-max-groups": 5,
    "cssPriority": "application",
    "widgets": [
        "title",
        "notifications",
        "buttons-grid"
    ],
    "widget-config": {
        "title": {
            "text": "?? Notifications",
            "clear-all-button": true,
            "button-text": "Clear All"
        },
        "buttons-grid": {
            "actions": [
                {
                    "name": "Do Not Disturb",
                    "label": "?? DND",
                    "command": "makoctl mode -s do-not-disturb",
                    "type": "toggle"
                },
                {
                    "name": "Keyboard",
                    "label": "?? Keyboard",
                    "command": "~/.config/hypr/scripts/toggle-keyboard.sh",
                    "type": "toggle"
                },
                {
                    "name": "Brightness",
                    "label": "?? Brightness",
                    "command": "wofi --show drun --prompt Brightness",
                    "type": "button"
                }
            ]
        }
    }
}
EOF

cat > /etc/skel/.config/swaync/style.css << '"'"'EOF'"'"'
/* SwayNC Mobile Style */

* {
    font-family: "Inter", "Noto Sans", sans-serif;
    font-size: 13px;
}

window {
    background: rgba(10, 10, 18, 0.98);
    border: 1px solid rgba(0, 255, 204, 0.2);
    border-radius: 16px;
    box-shadow: 0 16px 48px rgba(0, 0, 0, 0.6);
}

#control-center {
    background: transparent;
}

#notification-group {
    background: rgba(255, 255, 255, 0.03);
    border-radius: 12px;
    margin: 8px;
    padding: 8px;
}

#notification {
    background: rgba(255, 255, 255, 0.05);
    border-radius: 10px;
    padding: 12px;
    margin: 4px 0;
    border-left: 3px solid #00ffcc;
}

#notification.critical {
    border-left-color: #ff4444;
    background: rgba(255, 68, 68, 0.1);
}

#notification .time {
    color: rgba(255, 255, 255, 0.4);
    font-size: 11px;
}

#notification .app-name {
    color: #00ffcc;
    font-weight: 600;
    font-size: 12px;
}

#notification .summary {
    color: #ffffff;
    font-weight: 500;
    font-size: 13px;
}

#notification .body {
    color: rgba(255, 255, 255, 0.8);
    font-size: 12px;
    margin-top: 4px;
}

#notification .actions {
    margin-top: 8px;
}

#notification button {
    background: rgba(0, 255, 204, 0.1);
    border: 1px solid rgba(0, 255, 204, 0.3);
    border-radius: 8px;
    padding: 6px 12px;
    margin: 0 4px;
    color: #00ffcc;
    font-size: 12px;
    transition: all 0.15s ease-out;
}

#notification button:hover {
    background: rgba(0, 255, 204, 0.3);
    color: #0a0a12;
}

#title {
    color: #00ffcc;
    font-size: 16px;
    font-weight: 600;
    padding: 16px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

#clear-button {
    background: rgba(255, 255, 255, 0.05);
    border: none;
    border-radius: 8px;
    padding: 8px 16px;
    color: #ff4444;
    font-size: 12px;
}

#clear-button:hover {
    background: rgba(255, 68, 68, 0.15);
}

#buttons-grid {
    padding: 12px;
    border-top: 1px solid rgba(255, 255, 255, 0.05);
}

#buttons-grid button {
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    padding: 12px;
    margin: 4px;
    color: #ffffff;
    font-size: 13px;
    min-width: 80px;
    transition: all 0.15s ease-out;
}

#buttons-grid button:hover {
    background: rgba(0, 255, 204, 0.15);
    border-color: #00ffcc;
    color: #00ffcc;
}

#buttons-grid button:checked {
    background: rgba(0, 255, 204, 0.2);
    border-color: #00ffcc;
    color: #00ffcc;
}
EOF

# =============================================================================
# MOBILE APPS - Desktop entries for phone-like apps
# =============================================================================
mkdir -p /etc/skel/.local/share/applications

# Phone dialer
cat > /etc/skel/.local/share/applications/phone.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Phone
Name[pt_BR]=Telefone
Comment=Make and receive calls
Comment[pt_BR]=Fazer e receber chamadas
Exec=calls
Icon=call-start
Terminal=false
Type=Application
Categories=Network;Telephony;
Keywords=phone;call;dial;mobile;
StartupNotify=true
EOF

# Messages/SMS
cat > /etc/skel/.local/share/applications/messages.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Messages
Name[pt_BR]=Mensagens
Comment=SMS and chat messages
Comment[pt_BR]=SMS e mensagens de chat
Exec=chatty
Icon=chat
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
Keywords=message;sms;chat;mobile;
StartupNotify=true
EOF

# Contacts
cat > /etc/skel/.local/share/applications/contacts.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Contacts
Name[pt_BR]=Contatos
Comment=Manage contacts
Comment[pt_BR]=Gerenciar contatos
Exec=gnome-contacts
Icon=address-book
Terminal=false
Type=Application
Categories=Office;ContactManagement;
Keywords=contact;address;phone;mobile;
StartupNotify=true
EOF

# Camera
cat > /etc/skel/.local/share/applications/camera.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Camera
Name[pt_BR]=Câmera
Comment=Take photos and videos
Comment[pt_BR]=Tirar fotos e vídeos
Exec=gnome-camera
Icon=camera
Terminal=false
Type=Application
Categories=Graphics;Photography;
Keywords=camera;photo;video;mobile;
StartupNotify=true
EOF

# Gallery
cat > /etc/skel/.local/share/applications/gallery.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Gallery
Name[pt_BR]=Galeria
Comment=View photos and videos
Comment[pt_BR]=Ver fotos e vídeos
Exec=gnome-photos
Icon=image-viewer
Terminal=false
Type=Application
Categories=Graphics;Viewer;
Keywords=gallery;photo;video;image;mobile;
StartupNotify=true
EOF

# Settings
cat > /etc/skel/.local/share/applications/settings.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Settings
Name[pt_BR]=Configurações
Comment=System settings
Comment[pt_BR]=Configurações do sistema
Exec=gnome-control-center
Icon=preferences-system
Terminal=false
Type=Application
Categories=Settings;System;
Keywords=settings;config;system;mobile;
StartupNotify=true
EOF

# Files
cat > /etc/skel/.local/share/applications/files.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Files
Name[pt_BR]=Arquivos
Comment=File manager
Comment[pt_BR]=Gerenciador de arquivos
Exec=nemo
Icon=folder
Terminal=false
Type=Application
Categories=System;FileManager;
Keywords=file;folder;manager;mobile;
StartupNotify=true
EOF

# Browser
cat > /etc/skel/.local/share/applications/browser.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Browser
Name[pt_BR]=Navegador
Comment=Web browser
Comment[pt_BR]=Navegador web
Exec=firefox-esr
Icon=web-browser
Terminal=false
Type=Application
Categories=Network;WebBrowser;
Keywords=browser;web;internet;mobile;
StartupNotify=true
EOF

# Terminal
cat > /etc/skel/.local/share/applications/terminal.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Terminal
Name[pt_BR]=Terminal
Comment=Command line terminal
Comment[pt_BR]=Terminal de linha de comando
Exec=foot
Icon=terminal
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
Keywords=terminal;shell;command;cli;mobile;
StartupNotify=true
EOF

# Clock/Alarm
cat > /etc/skel/.local/share/applications/clock.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Clock
Name[pt_BR]=Relógio
Comment=Alarms, timers, stopwatch
Comment[pt_BR]=Alarmes, timers, cronômetro
Exec=gnome-clocks
Icon=clock
Terminal=false
Type=Application
Categories=Utility;Clock;
Keywords=clock;alarm;timer;stopwatch;mobile;
StartupNotify=true
EOF

# Weather
cat > /etc/skel/.local/share/applications/weather.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Weather
Name[pt_BR]=Clima
Comment=Weather forecast
Comment[pt_BR]=Previsão do tempo
Exec=gnome-weather
Icon=weather
Terminal=false
Type=Application
Categories=Utility;Weather;
Keywords=weather;forecast;temperature;mobile;
StartupNotify=true
EOF

# Calendar
cat > /etc/skel/.local/share/applications/calendar.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Calendar
Name[pt_BR]=Calendário
Comment=Calendar and events
Comment[pt_BR]=Calendário e eventos
Exec=gnome-calendar
Icon=calendar
Terminal=false
Type=Application
Categories=Office;Calendar;
Keywords=calendar;event;schedule;mobile;
StartupNotify=true
EOF

# Calculator
cat > /etc/skel/.local/share/applications/calculator.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Calculator
Name[pt_BR]=Calculadora
Comment=Simple calculator
Comment[pt_BR]=Calculadora simples
Exec=gnome-calculator
Icon=calculator
Terminal=false
Type=Application
Categories=Utility;Calculator;
Keywords=calculator;math;calculate;mobile;
StartupNotify=true
EOF

# Voice Recorder
cat > /etc/skel/.local/share/applications/recorder.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Recorder
Name[pt_BR]=Gravador
Comment=Voice recorder
Comment[pt_BR]=Gravador de voz
Exec=gnome-sound-recorder
Icon=audio-input-microphone
Terminal=false
Type=Application
Categories=AudioVideo;Audio;Recorder;
Keywords=recorder;voice;audio;mobile;
StartupNotify=true
EOF

# Compass (mock)
cat > /etc/skel/.local/share/applications/compass.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Compass
Name[pt_BR]=Bússola
Comment=Digital compass
Comment[pt_BR]=Bússola digital
Exec=python3 -c "import tkinter as tk; from math import sin, cos, radians; r=tk.Tk(); r.title('Compass'); r.geometry('320x480'); c=tk.Canvas(r,width=320,height=480,bg='#0a0a12'); c.pack(); c.create_oval(60,180,260,380,outline='#00ffcc',width=3); c.create_text(160,280,text='N',fill='#00ffcc',font=('Inter',48)); c.create_text(160,200,text='0°',fill='#fff',font=('Inter',14)); r.mainloop()"
Icon=navigation
Terminal=false
Type=Application
Categories=Utility;Navigation;
Keywords=compass;navigation;direction;mobile;
StartupNotify=true
EOF

# Flashlight (mock)
cat > /etc/skel/.local/share/applications/flashlight.desktop << '"'"'EOF'"'"'
[Desktop Entry]
Name=Flashlight
Name[pt_BR]=Lanterna
Comment=Screen flashlight
Comment[pt_BR]=Lanterna de tela
Exec=bash -c "hyprctl hyprpaper preload '~/.config/hypr/assets/white.png' && hyprctl hyprpaper wallpaper 'DP-1,~/.config/hypr/assets/white.png' && brightnessctl set 100%"
Icon=flashlight
Terminal=false
Type=Application
Categories=Utility;Flashlight;
Keywords=flashlight;torch;light;mobile;
StartupNotify=true
EOF

# Create white image for flashlight
mkdir -p /etc/skel/.config/hypr/assets
cat > /etc/skel/.config/hypr/assets/white.png << '"'"'EOF'"'"'
# Placeholder - real build would create white PNG
# convert -size 320x480 xc:white white.png
EOF
