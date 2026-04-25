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
  scottames/ghostty
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
echo "priority=1" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:scottames:ghostty.repo
echo "priority=2" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:avengemedia:danklinux.repo
dnf5 -y config-manager setopt "*terra*".priority=3 terra.enabled=1

ADDITIONAL_PKGS=(
  dislocker
  ntfs2btrfs
  adb-enhanced
  asusctl
)

NIRI_PKGS=(
  niri
  swaybg
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
  ghostty
  foot
)

FONTS=(
  material-symbols-fonts
  qgnomeplatform-qt5
  qgnomeplatform-qt6
  jetbrains-mono-fonts
  papirus-icon-theme
)

FINGER_PRINT=(
  fprintd
  libfprint-elanmoc2
  fprintd-pam
)

REMOVE_PKGS=(
  tmux
  kwrite
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
for i in /etc/yum.repos.d/terra*.repo; do
  sed -i 's/enabled=1/enabled=0/g' "$i"
done
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr disable "$repo"
done

log "cleaning system"
dnf5 clean all
