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
    lihaohong/yazi
)

for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

log "Enable terra repositories..."
dnf5 config-manager setopt terra.enabled=1 terra-extras.enabled=1

ADDITIONAL_APPS=(
    testdisk
    fwupd
    fwupd-efi
    kde-partitionmanager
    dislocker
    ntfs-3g
    ntfs2btrfs
    ntfs-3g-system-compression
    helix
    yazi
    zellij
)

PODMAN_PKGS=(
  dialog
  freerdp
  nmap-ncat
  podman-compose
)

NIRI_PKGS=(
    niri
    alacritty
    fuzzel
    swayidle
    swaybg
    brightnessctl
    xwayland-satellite
    gnome-keyring
    wireplumber
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    mate-polkit
    cliphist
    wl-clipboard
    wl-clip-persist
    wlogout
    wl-copy
    wtype
    pavucontrol
    qt6ct
    qt5ct
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
    cava
    go
    golang
    gammastep
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
    gnome-icon-theme
    gnome-colors-icon-theme
    adwaita-icon-theme
    rsms-inter-fonts
    gnome-themes-extra
)

FINGER_PRINT=(
     fprintd
     libfprint-elanmoc2
     fprintd-pam
)

REMOVE_PKGS=(
    tmux
    kate
    kwrite
    lutris
    gnome-disks
    sunshine
)

log "removing libfprint" 
dnf5 remove -y libfprint cliphist

log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=False -y \
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
