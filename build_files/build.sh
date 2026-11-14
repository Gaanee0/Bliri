#!/bin/bash
set ${SET_X:+-x} -euo pipefail

# Logs
log() { echo "=== $* ==="; }

# ── COPR Repos ─────────────────────────────────────────────────────────────────
log "Enabling COPR repos..."
COPR_REPOS=(
  # yalter/niri-git
  # duxlabs/dms-git
  yalter/niri
  duxlabs/dms
  duxlabs/dux-repo
  ulysg/xwayland-satellite
  gaanee/libfprint-elanmoc2
  deltacopy/darkly
  amaranth/homebrew
)

for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

# ── Terra Repo ─────────────────────────────────────────────────────────────────
log "Adding Terra repo..."
curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo \
  -o /etc/yum.repos.d/terra.repo

# Repo priorities (lower = higher priority)
# echo "priority=1" >>/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri-git.repo
echo "priority=1" >>/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri.repo
echo "priority=1" >>/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:ulysg:xwayland-satellite.repo
echo "priority=1" >>/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:deltacopy:darkly.repo
echo "priority=1" >>/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:duxlabs:dux-repo.repo
dnf5 -y config-manager setopt 'terra.enabled=1' 'terra*.priority=2'

# ── Packages ───────────────────────────────────────────────────────────────────
PKGS=(
  # Hardware
  asusctl
  adb-enhanced
  libfprint-elanmoc2
  fprintd
  fprintd-pam

  # Niri WM
  niri
  iio-niri
  xwayland-satellite
  xdg-desktop-portal-gnome

  # Dux Desktop
  dms
  dms-cli
  quickshell-git
  matugen
  dux-gop
  dux-search
  dux-files-git
  dux-calendar-git
  dux-greeter-git
  ffmpegthumbnailer
  adw-gtk3-theme
  darkly
  darkly-qt5
  darkly-qt6
  nwg-look
  qt6ct
  qt5ct
  cava
  gammastep
  cups-pk-helper
  khal
  wl-mirror
  greetd
  oo7-cli
  pam_oo7

  # Addons
  scrcpy
  brew-proxy
  brew-proxy-selinux

  # Fonts & themes
  material-symbols-fonts
  papirus-icon-theme
)

# ── Install ────────────────────────────────────────────────────────────────────
log "Removing packages before reinstall..."
dnf5 -y remove --no-autoremove libfprint

log "Installing packages..."
dnf5 install -y --setopt=install_weak_deps=False "${PKGS[@]}"

log "Cleaning up..."
dnf5 clean all
