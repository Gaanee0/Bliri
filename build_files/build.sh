#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

log() {
  echo "=== $* ==="
}

log "Enable COPR repos...." 
COPR_REPOS=(
    tofik/sway
    ulysg/xwayland-satellite
    yalter/niri
    leloubil/wl-clip-persist
)
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

log "Enable terra repositories..."
dnf5 config-manager setopt terra.enabled=1 terra-extras.enabled=1

ADDITIONAL_APPS=(
    kitty
    kitty-terminfo
    dolphin
    filelight
    kde-connect
    btrfs-assistant
)

NIRI_PKGS=(
    niri
    wpaperd
    swaylock
    swayidle
    brightnessctl
    fuzzel
    mako
    waybar
    xwayland-satellite
    gnome-keyring
    wireplumber
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    polkit-kde
    cliphist
    wl-clipboard
    blueman
    wl-clip-persist
    wlogout
    wireplumber
    wl-copy
    network-manager-applet
)

FONT_OTHERS=(
    material-icons-fonts
    fira-code-fonts
    fontawesome-fonts-all
    google-noto-emoji-fonts
    adobe-source-code-pro-fonts
    google-droid-sans-fonts
    google-noto-sans-cjk-fonts
    google-noto-color-emoji-fonts
    jetbrains-mono-fonts
    wine-ms-sans-serif-fonts
    la-capitaine-cursor-theme 
)

log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=True -y \
${ADDITIONAL_APPS[@]} \
${NIRI_PKGS[@]} \
${FONT_OTHERS[@]}

log "Disable Copr repos to get rid of clutter..."
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr disable "$repo"
done

log "Enabling systemd.services..."
