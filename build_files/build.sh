#!/bin/bash

set ${SET_X:+-x} -euo pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

RELEASE="$(rpm -E %fedora)"

log() {
  echo "=== $* ==="
}

log "Enable COPR repos..."
COPR_REPOS=(
    yalter/niri-git
    ulysg/xwayland-satellite
    avengemedia/danklinux
    avengemedia/dms-git
    gaanee/libfprint-elanmoc2
    deltacopy/darkly
    solopasha/hyprland
    zirconium/packages
    faugus/faugus-launcher
)

for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

log "Adding repos & Optimizing build time..."
echo "priority=1" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri-git.repo
echo "priority=2" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:ulysg:xwayland-satellite.repo
echo "priority=3" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:avengemedia:danklinux.repo
dnf5 -y config-manager setopt "*terra*".priority=4 terra.enabled=1 terra-extras.enabled=1 terra.exclude="matugen"

ADDITIONAL_PKGS=(
    kde-partitionmanager
    dislocker
    ntfs2btrfs
    gvfs-fuse
    adb-enhanced
    asusctl
    liquidctl
    coolercontrol
    faugus-launcher
)

NIRI_PKGS=(
    niri
    swaybg
    xwayland-satellite
    xdg-desktop-portal-gnome
    alacritty
    quickshell-git
    matugen
    cava
    gammastep
    qt6ct
    qt5ct
    dms
    dgop
    dsearch
    dms-cli
    adw-gtk3-theme
    nwg-look
    darkly
)

FONTS=(
    material-symbols-fonts
    rsms-inter-fonts
    qgnomeplatform-qt5
    qgnomeplatform-qt6
    fontawesome-fonts-all
    jetbrains-mono-fonts
    wine-ms-sans-serif-fonts
    papirus-icon-theme
)

FINGER_PRINT=(
     fprintd
     libfprint-elanmoc2
     fprintd-pam
)

REMOVE_PKGS=(
    tmux
    kate
    gnome-disk-utility
    lutris
)

log "removing to reinstall"
dnf5 remove -y libfprint

log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=False -y \
${ADDITIONAL_PKGS[@]} \
${NIRI_PKGS[@]} \
${FONTS[@]} \
${FINGER_PRINT[@]}

log "Removing packages from dependcies"
dnf5 remove -y \
${REMOVE_PKGS[@]}

log "Disable Copr repos to get rid of clutter..."
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr disable "$repo"
done

log "cleaning system"
rm -rvf /usr/share/wayland-sessions/gamescope-session-steam.desktop
rm -rvf /usr/share/wayland-sessions/gamescope-session-steam.desktop
rm -rvf /usr/share/wayland-sessions/gamescope-session.desktop
rm -rvf /usr/share/wayland-sessions/plasma-steamos-wayland-oneshot.desktop
rm -rvf /usr/share/xsessions/plasma-steamos-oneshot.desktop
dnf5 clean all
#
