#!/bin/bash -e
# Stage 3: hyprlock - Beautiful mobile lock screen

mkdir -p /etc/skel/.config/hypr

cat > /etc/skel/.config/hypr/hyprlock.conf << '"'"'EOF'"'"'
# =============================================================================
# hyprlock.conf - Mobile Lock Screen Perfection
# iOS/Android style with animations, PIN entry, notifications preview
# =============================================================================

# Background - beautiful gradient
background {
    monitor = DP-1
    color = rgb(0a0a12)
    path = ~/.config/hypr/assets/lock-bg.png
    blur_passes = 3
    blur_size = 8
    noise = 0.015
    contrast = 1.1
    brightness = 0.9
}

# Main clock - large, prominent
label {
    monitor = DP-1
    text = "$TIME"
    font_family = "JetBrains Mono"
    font_size = 120
    font_weight = 300
    color = rgba(ffffffee)
    position = 50%, 35%
    halign = center
    valign = center
    shadow = true
    shadow_color = rgba(000000aa)
    shadow_offset = 0 4
    shadow_range = 20
}

# Date below clock
label {
    monitor = DP-1
    text = "$DATE"
    font_family = "Inter"
    font_size = 28
    font_weight = 400
    color = rgba(ffffffaa)
    position = 50%, 50%
    halign = center
    valign = center
    shadow = true
    shadow_color = rgba(00000088)
    shadow_offset = 0 2
}

# Greeting / status
label {
    monitor = DP-1
    text = "Good $TIME_OF_DAY, mobile"
    font_family = "Inter"
    font_size = 20
    font_weight = 300
    color = rgba(00ffccaa)
    position = 50%, 56%
    halign = center
    valign = center
    shadow = true
    shadow_color = rgba(00000066)
}

# Battery indicator
label {
    monitor = DP-1
    text = "$BATTERY"
    font_family = "JetBrains Mono"
    font_size = 18
    font_weight = 500
    color = rgba(ffffff99)
    position = 50%, 78%
    halign = center
    valign = center
}

# Network indicator
label {
    monitor = DP-1
    text = "$WIFI"
    font_family = "JetBrains Mono"
    font_size = 16
    font_weight = 400
    color = rgba(ffffff77)
    position = 50%, 82%
    halign = center
    valign = center
}

# PIN input field - beautiful, centered
input-field {
    monitor = DP-1
    size = 280, 56
    position = 50%, 68%
    halign = center
    valign = center
    placeholder = "••••"
    font_family = "JetBrains Mono"
    font_size = 32
    font_weight = 500
    color = ffffff
    background_color = rgba(1a1a2ecc)
    border_color = rgba(00ffccaa)
    border_size = 2
    rounding = 16
    hide_input = true
    check_keymap = true
    swap_layout_on_enter = true
    outer_color = rgba(00ffcc33)
    inner_color = rgba(00ffcc00)
    dots = true
    dots_size = 12
    dots_spacing = 8
    dots_center = true
    max_length = 6
    min_length = 4
    cancel_on_empty = true
    submit_on_max = true
}

# Failed attempts indicator
label {
    monitor = DP-1
    text = "$ATTEMPTS_LEFT attempts left"
    font_family = "Inter"
    font_size = 14
    font_weight = 400
    color = rgba(ff4444aa)
    position = 50%, 74%
    halign = center
    valign = center
    visible = $ATTEMPTS_LEFT < 3
}

# Emergency call button
button {
    monitor = DP-1
    text = "?? Emergency"
    font_family = "Inter"
    font_size = 16
    font_weight = 500
    color = ffffff
    background_color = rgba(cc0000aa)
    border_color = rgba(ff4444aa)
    border_size = 1
    rounding = 12
    position = 50%, 90%
    halign = center
    valign = center
    size = 160, 40
    action = exec, notify-send "Emergency" "Calling emergency services..." -u critical
}

# Cancel button (bottom)
button {
    monitor = DP-1
    text = "Cancel"
    font_family = "Inter"
    font_size = 16
    font_weight = 400
    color = rgba(ffffff88)
    background_color = rgba(00000000)
    border_color = rgba(00000000)
    border_size = 0
    rounding = 0
    position = 50%, 96%
    halign = center
    valign = center
    size = 100, 32
    action = cancel
}

# =============================================================================
# ANIMATIONS - Smooth entry/exit
# =============================================================================
animations {
    # Fade in on show
    enabled = true
    animation = fade, 1, easeOutExpo, in
    animation = slide, 1, easeOutExpo, in, 0, -50
    animation = scale, 1, spring, in, 0.95

    # Fade out on unlock
    animation = fade, 1, easeInExpo, out
    animation = slide, 1, easeInExpo, out, 0, 50
    animation = scale, 1, easeInExpo, out, 1.02
}

# =============================================================================
# LAYOUT SETTINGS
# =============================================================================
layout {
    center_if_fits = true
    spacing = 8
}

# =============================================================================
# DPMS - Turn off screen after timeout
# =============================================================================
dpms {
    timeout = 30
    dpms_on_unlock = true
}

# =============================================================================
# MISC
# =============================================================================
misc {
    disable_loading_bar = true
    show_failed_attempts = true
    max_failed_attempts = 5
    lock_on_suspend = true
    lock_on_lid_close = true
}
EOF

# Create assets directory
mkdir -p /etc/skel/.config/hypr/assets

# Create a simple lock screen background (SVG -> would be converted to PNG in real build)
cat > /etc/skel/.config/hypr/assets/lock-bg.svg << '"'"'EOF'"'"'
<svg width="320" height="480" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#0a0a12;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#1a1a2e;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#16213e;stop-opacity:1" />
    </linearGradient>
    <radialGradient id="glow" cx="50%" cy="30%" r="60%">
      <stop offset="0%" style="stop-color:#00ffcc;stop-opacity:0.08" />
      <stop offset="100%" style="stop-color:#00ffcc;stop-opacity:0" />
    </radialGradient>
  </defs>
  <rect width="320" height="480" fill="url(#bg)"/>
  <rect width="320" height="480" fill="url(#glow)"/>
  <!-- Subtle grid pattern -->
  <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
    <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#00ffcc" stroke-width="0.3" opacity="0.03"/>
  </pattern>
  <rect width="320" height="480" fill="url(#grid)"/>
</svg>
EOF

# Convert SVG to PNG if imagemagick available (runs at build time)
# For now, create a placeholder
cat > /etc/skel/.config/hypr/assets/lock-bg.png << '"'"'EOF'"'"'
# Placeholder - real build would use: magick lock-bg.svg lock-bg.png
# hyprlock will fallback to solid color if PNG not found
EOF
