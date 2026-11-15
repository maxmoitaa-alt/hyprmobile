#!/bin/bash -e
# Stage 3: Mobile Apps - Already created in stage3/05-setup-notifications
# This stage ensures apps are properly integrated

# Verify desktop entries exist
for app in phone messages contacts camera gallery settings files browser terminal clock weather calendar calculator recorder compass flashlight; do
    if [ ! -f /etc/skel/.local/share/applications/${app}.desktop ]; then
        echo "WARNING: ${app}.desktop not found"
    fi
done

# Update desktop database
update-desktop-database /usr/share/applications 2>/dev/null || true
update-desktop-database /etc/skel/.local/share/applications 2>/dev/null || true

# Update MIME database
update-mime-database /usr/share/mime 2>/dev/null || true

# Update icon cache
gtk-update-icon-cache -f /usr/share/icons/Adwaita 2>/dev/null || true
gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true

echo "Mobile apps verified and integrated"

