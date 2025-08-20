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
    errornointernet/quickshell
    heus-sueh/packages
    gaanee/libfprint-elanmoc2
    alternateved/cliphist
)

for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

log "Enable terra repositories..."
dnf5 config-manager setopt terra.enabled=1 terra-extras.enabled=1

ADDITIONAL_APPS=(
    kitty
    dolphin
    filelight
    kde-connect
    kio-admin
    testdisk
    fwupd
    fwupd-efi
    gnome-firmware
    kde-partitionmanager
    syncthing
    helix
    zellij
    dislocker
    chezmoi
    zsh
    keychain
)

PODMAN_PKGS=(
  dialog
  freerdp
  nmap-ncat
  podman-compose
)

NIRI_PKGS=(
    niri
    wpaperd
    swaylock
    swayidle
    swaybg
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
    wl-copy
    network-manager-applet
    pavucontrol
    qt6ct
    qt5ct
    kvantum
)

QUICK_SHELL=(
    quickshell-git
    qt5-qtsvg
    gtk-murrine-engine
    qt6-qtsvg
    qt5-qtimageformats
    qt6-qtimageformats
    qt5-qtmultimedia
    qt6-qtmultimedia
    qt6-qt5compat
    matugen
    sassc
    libass
    plasma-breeze
    breeze-gtk
    cava
    rsms-inter-fonts
    gnome-themes-extra
    go
    golang
    wtype
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

FINGER_PRINT=(
     fprintd
     libfprint-elanmoc2
     fprintd-pam
)

REMOVE_PKGS=(
    alacritty
    mako
    waybar
    swaylock
    network-manager-applet
    tmux
    blueman
)

log "removing libfprint" 
dnf5 remove -y libfprint cliphist

log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=True -y \
${ADDITIONAL_APPS[@]} \
${NIRI_PKGS[@]} \
${FONT_OTHERS[@]} \
${PODMAN_PKGS[@]} \
${QUICK_SHELL[@]} \
${FINGER_PRINT[@]} 

log "Removing packages from dependcies"
dnf5 remove -y \
${REMOVE_PKGS[@]}

log "Disable Copr repos to get rid of clutter..."
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr disable "$repo"
done

log "Enabling systemd.services..."
