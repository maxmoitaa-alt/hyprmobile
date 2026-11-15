#!/bin/bash -e
# Stage 4: Cleanup - Final image shrinking and optimization

# Remove apt cache
apt-get clean
rm -rf /var/lib/apt/lists/*

# Remove temporary files
rm -rf /tmp/*
rm -rf /var/tmp/*

# Remove documentation
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*

# Remove unnecessary locales
for locale in /usr/share/locale/*; do
    case $(basename "$locale") in
        pt_BR|pt|en_US|en|C|C.UTF-8|POSIX) ;;
        *) rm -rf "$locale" ;;
    esac
done

# Remove bash completion for unused commands
rm -rf /usr/share/bash-completion/completions/*

# Remove systemd journal vacuum
journalctl --vacuum-time=1d

# Remove old kernels (keep current)
CURRENT_KERNEL=$(uname -r)
dpkg -l "linux-image-*" | awk "/^ii/ && !/$CURRENT_KERNEL/ {print \$2}" | xargs -r apt-get purge -y

# Remove old kernel headers
dpkg -l "linux-headers-*" | awk "/^ii/ && !/$CURRENT_KERNEL/ {print \$2}" | xargs -r apt-get purge -y

# Sync filesystem
sync

echo "Cleanup complete!"

