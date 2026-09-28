#!/bin/bash

# ─── Linux / macOS HWID ────────────────────────────────────────────────────────

get_hwid_linux() {
    if [ -f /etc/machine-id ]; then
        ID=$(cat /etc/machine-id)
    elif [ -f /var/lib/dbus/machine-id ]; then
        ID=$(cat /var/lib/dbus/machine-id)
    else
        ID=$(ip link show 2>/dev/null | awk '/ether/ {gsub(/:/, "", $2); printf $2}')
        if [ -z "$ID" ]; then
            echo "Error: Could not determine a stable machine identifier." >&2
            exit 1
        fi
        RAW="LNX-MAC-$ID"
        echo -n "$RAW" | sha256sum | awk '{print "Your HWID: " $1}'
        return
    fi
    echo -n "LNX-$ID" | sha256sum | awk '{print "Your HWID: " $1}'
}

get_hwid_mac() {
    # Try IOPlatformUUID (most reliable on macOS)
    UUID=$(ioreg -rd1 -c IOPlatformExpertDevice 2>/dev/null \
           | awk -F'"' '/IOPlatformUUID/{print $4}')
    if [ -z "$UUID" ]; then
        echo "Error: Could not determine machine UUID on macOS." >&2
        exit 1
    fi
    echo -n "MAC-$UUID" | shasum -a 256 | awk '{print "Your HWID: " $1}'
}

OS="$(uname -s 2>/dev/null)"
case "$OS" in
    Linux)   get_hwid_linux ;;
    Darwin)  get_hwid_mac ;;
    *)
        echo "Unsupported OS: $OS" >&2
        exit 1
        ;;
esac
