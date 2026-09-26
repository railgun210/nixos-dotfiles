#!/bin/bash

# Nerd Font icons for distros
# Format: distro_id="icon_codepoint"

declare -A distro_icons=(
    ["fedora"]=""
    ["ubuntu"]=""
    ["debian"]=""
    ["arch"]="󰣇"
    ["endeavouros"]=""
    ["manjaro"]=""
    ["garuda"]="󰒙"
    ["gentoo"]="󰣢"
    ["rhel"]=""
    ["centos"]=""
    ["rocky"]=""
    ["alma"]=""
    ["opensuse"]=""
    ["leap"]=""
    ["tumbleweed"]=""
    ["alpine"]="󰎙"
    ["void"]="󰍚"
    ["nixos"]="󰉣"
    ["pop"]=""
    ["zorin"]="󰣦"
    ["mint"]="󰣦"
    ["elementary"]=""
    ["macos"]="󰀵"
    ["darwin"]="󰀵"
    ["freebsd"]="󰌛"
    ["linux"]="󰌛"
)

# Try multiple detection methods
detect_distro() {
    # Method 1: Check /etc/os-release ID
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ -n "$ID" ]] && [[ -n "${distro_icons[$ID]}" ]]; then
            echo "${distro_icons[$ID]}"
            return
        fi
    fi

    # Method 2: Check specific files
    if [[ -f /etc/arch-release ]] || [[ -f /etc/archlinux ]]; then
        # Check if it's EndeavourOS
        if [[ -f /etc/endeavouros-release ]] || grep -qi "endeavouros" /etc/os-release 2>/dev/null; then
            echo ""
        else
            echo "󰣇"
        fi
        return
    fi

    # Method 3: Check lsb-release
    if [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        dist_id=$(echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]')
        if [[ -n "${distro_icons[$dist_id]}" ]]; then
            echo "${distro_icons[$dist_id]}"
            return
        fi
    fi

    # Method 4: Check fedora-release
    if [[ -f /etc/fedora-release ]]; then
        echo ""
        return
    fi

    # Method 5: Check debian_version
    if [[ -f /etc/debian_version ]]; then
        echo ""
        return
    fi

    # Default: generic Linux penguin
    echo "󰌛"
}

detect_distro