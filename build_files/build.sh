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
)

for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

log "Adding repos & Optimizing build time..."
dnf5 install -y --nogpgcheck \
  --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
  terra-release
echo "priority=1" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri-git.repo
echo "priority=1" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:ulysg:xwayland-satellite.repo
echo "priority=2" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:avengemedia:danklinux.repo
dnf5 -y config-manager setopt terra.enabled=1 "*terra*".priority=3

ADDITIONAL_PKGS=(
  dislocker
  ntfs2btrfs
  adb-enhanced
  asusctl
  libfprint-elanmoc2
  fprintd
  fprintd-pam
  btop
)

NIRI_PKGS=(
  niri
  xwayland-satellite
  xdg-desktop-portal-gnome
  quickshell-git
  matugen
  cava
  gammastep
  qt6ct
  qt5ct
  dms
  dgop
  dms-cli
  adw-gtk3-theme
  nwg-look
  darkly
  foot
  foot-terminfo
  cups-pk-helper
  dsearch
  brightnessctl
  playerctl
  wl-mirror
  khal
  greetd
  dms-greeter
)

FONTS=(
  material-symbols-fonts
  papirus-icon-theme
)

REMOVE_PKGS=(
  tmux
  kwrite
  kate
  Sunshine
)

log "removing to reinstall"
dnf5 -y remove --no-autoremove libfprint

log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=False -y \
  ${ADDITIONAL_PKGS[@]} \
  ${NIRI_PKGS[@]} \
  ${FONTS[@]}

log "Removing packages from dependcies"
dnf5 remove -y \
  ${REMOVE_PKGS[@]}

log "cleaning system"
dnf5 clean all
