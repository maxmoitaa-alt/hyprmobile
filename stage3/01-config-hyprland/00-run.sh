#!/bin/bash -e
# Stage 3: Hyprland configuration - Mobile optimized with beautiful animations

# Create hyprland config directory
mkdir -p /etc/skel/.config/hypr
mkdir -p /etc/skel/.config/hypr/scripts

# Main hyprland.conf - Mobile perfection
cat > /etc/skel/.config/hypr/hyprland.conf << '"'"'EOF'"'"'
# =============================================================================
# Hyprland Mobile Config - Pi 3B + TFT35a (320x480 portrait)
# Beautiful, smooth, parallel animations - omarchy-mobile style
# =============================================================================

# =============================================================================
# MONITOR - TFT35a rotated 90° CW = 320x480 logical
# =============================================================================
monitor=DP-1,320x480@60,0x0,1,transform=1,bitdepth=8,vrr=0
# transform=1 = 90° clockwise rotation

# =============================================================================
# INPUT - Touchscreen optimized
# =============================================================================
input {
    kb_layout = br
    kb_variant = abnt2
    kb_model = pc105
    kb_options = caps:escape
    kb_rules = evdev

    # Touchscreen: XPT2046 calibration matrix for 90° CW
    touchdevice:XPT2046 {
        calibration_matrix = 0, 1, 0, -1, 0, 1, 0, 0, 1
        natural_scroll = true
        tap-to-click = true
        drag-lock = true
    }

    sensitivity = 0.4
    accel_profile = flat
    scroll_factor = 1.0
    scroll_method = two_finger
    tap-to-click = true
    tap-and-drag = true
    drag_lock = true
    natural_scroll = true
    left_handed = false
    middle_emulation = false
    scroll_button = 0
    scroll_button_lock = false
}

# =============================================================================
# GESTURES - Mobile-style (3 fingers for workspace, edge swipe for overview)
# =============================================================================
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 250
    workspace_swipe_invert = true
    workspace_swipe_min_speed_to_force = 30
    workspace_swipe_cancel_on_mouse_movement = true
    workspace_swipe_create_on_swipe_up = false

    border_swipe = true
    border_swipe_fingers = 3
    border_swipe_distance = 100

    pinch_zoom = true
    pinch_zoom_fingers = 2
}

# =============================================================================
# GENERAL - Visual perfection
# =============================================================================
general {
    gaps_in = 0
    gaps_out = 0
    border_size = 0
    col.active_border = rgba(00ffccaa) rgba(0099ccaa) 45deg
    col.inactive_border = rgba(1a1a2eaa)
    layout = dwindle
    no_focus_fallback = true
    focus_follows_mouse = false
    mouse_refocus = false
    allow_tearing = false
    resize_on_border = false
    extend_border_grab_area = 20
    snap = true
    snap_distance = 20
}

# =============================================================================
# DECORATION - Beautiful rounded corners, shadows, blur
# =============================================================================
decoration {
    rounding = 12
    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = true
        xray = false
        ignore_opacity = false
    }
    drop_shadow = true
    shadow_range = 20
    shadow_render_power = 3
    shadow_offset = 0 4
    col.shadow = rgba(00000088)
    dim_inactive = true
    dim_strength = 0.15
    dim_special = 0.2
    dim_around = 0.0
}

# =============================================================================
# ANIMATIONS - PARALLEL, SMOOTH, MOBILE-PERFECT
# =============================================================================
animations {
    enabled = true

    # Bezier curves for natural motion
    bezier = easeOutExpo, 0.19, 1.00, 0.22, 1.00
    bezier = easeOutCirc, 0.075, 0.82, 0.165, 1.00
    bezier = easeOutBack, 0.34, 1.56, 0.64, 1.00
    bezier = spring, 0.175, 0.885, 0.32, 1.275
    bezier = smooth, 0.4, 0.0, 0.2, 1.0
    bezier = snappy, 0.25, 0.46, 0.45, 0.94

    # Workspace transitions - PARALLEL slide + fade + scale
    animation = workspace, 1, easeOutExpo, slide
    animation = workspace, 1, easeOutExpo, fade
    animation = workspace, 1, easeOutExpo, scale

    # Window open/close - spring physics
    animation = window, 1, spring, slide
    animation = window, 1, spring, fade
    animation = window, 1, spring, scale

    # Layer animations (waybar, wofi, etc)
    animation = layer, 1, easeOutCirc, slide
    animation = layer, 1, easeOutCirc, fade

    # Border/active window
    animation = border, 1, easeOutExpo, slide
    animation = borderangle, 1, easeOutExpo

    # Fade for fullscreen transitions
    animation = fullscreen, 1, easeOutCirc, fade

    # Special workspace (scratchpad)
    animation = special, 1, spring, slide
    animation = special, 1, spring, fade
}

# =============================================================================
# LAYOUT - Dwindle optimized for mobile
# =============================================================================
dwindle {
    pseudotile = true
    preserve_split = true
    split_width_multiplier = 0.5
    smart_gaps = true
    smart_borders = true
    no_gaps_when_only = true
    force_split = 0
}

# =============================================================================
# WINDOW RULES - Mobile UX: everything fullscreen, no decorations
# =============================================================================
windowrulev2 = fullscreen, class:.*
windowrulev2 = noinitialfocus, class:.*
windowrulev2 = noborder, class:.*
windowrulev2 = norounding, class:.*
windowrulev2 = noshadow, class:.*

# Floating for overlays
windowrulev2 = float, class:^(wofi|mako|swaync|wvkbd|squeekboard|hyprlock|hyprpolkitagent)$
windowrulev2 = float, title:^(Picture-in-Picture|Media Controls)$
windowrulev2 = size 320x480, class:^(wofi|wvkbd|squeekboard)$
windowrulev2 = center, class:^(wofi|wvkbd|squeekboard|hyprlock|hyprpolkitagent)$
windowrulev2 = pin, class:^(wvkbd|squeekboard)$

# Browser optimizations
windowrulev2 = opacity 0.95, class:^(firefox|chromium)$
windowrulev2 = animation popin, 1, spring, slide, class:^(firefox|chromium)$

# Terminal
windowrulev2 = animation popin, 1, spring, slide, class:^(foot|kitty)$

# =============================================================================
# KEYBINDS - Mobile optimized (SUPER = meta key)
# =============================================================================
$mainMod = SUPER

# Terminal
bind = $mainMod, Return, exec, foot
bind = $mainMod, T, exec, kitty

# App launcher (wofi)
bind = $mainMod, Space, exec, wofi --show drun --width 300 --height 400 --location top_right --anchor top_right --prompt "??"
bind = $mainMod, D, exec, wofi --show drun --width 300 --height 400 --location top_right --anchor top_right --prompt "??"

# Window management
bind = $mainMod, Q, killactive
bind = $mainMod, F, fullscreen
bind = $mainMod, V, togglefloating
bind = $mainMod, P, pseudo
bind = $mainMod, J, togglesplit

# Workspace navigation (1-5 for mobile)
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

# Move to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5

# Special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Focus
bind = $mainMod, H, movefocus, l
bind = $mainMod, L, movefocus, r
bind = $mainMod, K, movefocus, u
bind = $mainMod, J, movefocus, d

# Swap
bind = $mainMod SHIFT, H, swapwindow, l
bind = $mainMod SHIFT, L, swapwindow, r
bind = $mainMod SHIFT, K, swapwindow, u
bind = $mainMod SHIFT, J, swapwindow, d

# Resize mode
bind = $mainMod, R, resizewindow, 20 20

# Screenshot
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot" "Copied to clipboard"
bind = $mainMod, Print, exec, grim - | wl-copy && notify-send "Screenshot" "Full screen copied"

# Screen recording
bind = $mainMod SHIFT, R, exec, wf-recorder -g "$(slurp)" -f ~/Videos/recording-$(date +%s).mp4

# Brightness
bind = , XF86MonBrightnessUp, exec, brightnessctl set 10%+
bind = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

# Volume
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Media keys
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Virtual Keyboard toggle
bind = $mainMod, K, exec, ~/.config/hypr/scripts/toggle-keyboard.sh

# Lock screen
bind = $mainMod, L, exec, hyprlock

# Power menu
bind = $mainMod, Escape, exec, wofi --show power --width 280 --height 300 --location top_right --anchor top_right --prompt "?"

# Reload config
bind = $mainMod SHIFT, R, reload

# =============================================================================
# MOUSE/TOUCH BINDS
# =============================================================================
# Three finger tap = right click context menu
bindm = , 272, exec, wtype -M ctrl -P click -m ctrl  # Right click via touch

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================
env = XCURSOR_SIZE,24
env = XCURSOR_THEME,Adwaita
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt6ct
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = GDK_BACKEND,wayland
env = SDL_VIDEODRIVER,wayland
env = CLUTTER_BACKEND,wayland
env = ELECTRON_OZONE_PLATFORM_HINT,wayland
env = MOZ_ENABLE_WAYLAND,1
env = _JAVA_AWT_WM_NONREPARENTING,1
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1

# =============================================================================
# EXEC ONCE - Startup applications
# =============================================================================
exec-once = hypridle
exec-once = waybar -c ~/.config/waybar/config.jsonc
exec-once = swaync
exec-once = nm-applet --indicator
exec-once = blueman-applet
exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = ~/.config/hypr/scripts/startup.sh

# =============================================================================
# MISC
# =============================================================================
misc {
    disable_hyprland_logo = true
    vfr = true
    animate_manual_resizes = true
    enable_swallow = true
    swallow_regex = ^(foot|kitty)$
    force_default_wallpaper = 0
    xwayland_persistent = true
    check_update = true
    ignore_zero_updates = false
}

# =============================================================================
# CURSOR
# =============================================================================
cursor {
    no_hardware_cursors = true
    theme = Adwaita
    size = 24
    zoom_factor = 1.0
}

# =============================================================================
# XWAYLAND
# =============================================================================
xwayland {
    enabled = true
    lazy = true
    force_zero_scaling = true
}
EOF

# Create startup script
cat > /etc/skel/.config/hypr/scripts/startup.sh << '"'"'EOF'"'"'
#!/bin/bash
# Hyprland startup script - runs once on login

# Set wallpaper (solid color for performance)
hyprctl hyprpaper preload "~/Pictures/wallpaper.png" 2>/dev/null || true
hyprctl hyprpaper wallpaper "DP-1,~/Pictures/wallpaper.png" 2>/dev/null || true

# Set cursor
hyprctl setcursor Adwaita 24

# Initialize keyboard layout
hyprctl keyword input:kb_layout br
hyprctl keyword input:kb_variant abnt2

# Start virtual keyboard daemon (wvkbd)
if ! pgrep -x "wvkbd-mobintl" > /dev/null; then
    wvkbd-mobintl -H 200 -L 400 &
fi

# Set initial brightness
brightnessctl set 70% 2>/dev/null || true

# Notify ready
sleep 2
notify-send "?? HyprMobile Ready" "Welcome to your Pi Phone!" -t 3000 -i phone
EOF

chmod +x /etc/skel/.config/hypr/scripts/startup.sh

# Create keyboard toggle script
cat > /etc/skel/.config/hypr/scripts/toggle-keyboard.sh << '"'"'EOF'"'"'
#!/bin/bash
# Toggle virtual keyboard

if pgrep -x "wvkbd-mobintl" > /dev/null; then
    pkill wvkbd-mobintl
    notify-send "?? Keyboard" "Hidden" -t 1000
else
    wvkbd-mobintl -H 200 -L 400 &
    notify-send "?? Keyboard" "Shown" -t 1000
fi
EOF

chmod +x /etc/skel/.config/hypr/scripts/toggle-keyboard.sh

# Create wallpaper (simple gradient)
mkdir -p /etc/skel/Pictures
cat > /etc/skel/Pictures/wallpaper.png << '"'"'EOF'"'"'
# This would be a real PNG in production
# For now, hyprpaper will use a solid color fallback
EOF

# Hyprland environment file for systemd
mkdir -p /etc/skel/.config/environment.d
cat > /etc/skel/.config/environment.d/hyprland.conf << '"'"'EOF'"'"'
WAYLAND_DISPLAY=wayland-0
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_DESKTOP=Hyprland
XDG_SESSION_TYPE=wayland
QT_QPA_PLATFORM=wayland
QT_QPA_PLATFORMTHEME=qt6ct
GDK_BACKEND=wayland
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland
ELECTRON_OZONE_PLATFORM_HINT=wayland
MOZ_ENABLE_WAYLAND=1
_JAVA_AWT_WM_NONREPARENTING=1
XCURSOR_THEME=Adwaita
XCURSOR_SIZE=24
EOF
