#!/usr/bin/env bash
# install-adblock-hosts.sh — system-wide ad-block via Magisk's built-in hosts module
# Requires: rooted Magisk device, adb authorized, su granted for shell.
# Usage:  ./install-adblock-hosts.sh [path-to-hosts-file]
#         defaults to downloading the latest StevenBlack unified list.

set -euo pipefail

HOSTS_FILE="${1:-/tmp/hosts_stevenblack.txt}"

if [ ! -f "$HOSTS_FILE" ]; then
    echo ">> Downloading StevenBlack unified hosts..."
    curl -sL --max-time 120 -o "$HOSTS_FILE" \
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
fi

LINES=$(wc -l < "$HOSTS_FILE")
echo ">> Hosts file: $HOSTS_FILE ($LINES lines)"

echo ">> Pushing to device..."
adb push "$HOSTS_FILE" /data/local/tmp/hosts

# Magisk ships a built-in 'hosts' module (id=hosts) that wins the mount race —
# write into it rather than creating a new module that silently fails.
echo ">> Installing into /data/adb/modules/hosts ..."
adb shell "su -c 'cp /data/local/tmp/hosts /data/adb/modules/hosts/system/etc/hosts \
    && chmod 644 /data/adb/modules/hosts/system/etc/hosts \
    && mount --bind /data/adb/modules/hosts/system/etc/hosts /system/etc/hosts'"

echo ">> Verifying..."
adb shell "su -c 'wc -l /system/etc/hosts'"
adb shell "ping -c1 -W2 ads.doubleclick.net 2>&1 | head -2" || true
adb shell "ping -c1 -W2 google.com 2>&1 | head -2" || true

echo ">> Done. ads.doubleclick.net should be unreachable; google.com should reply."
echo ">> Persists across reboots via Magisk magic-mount."
