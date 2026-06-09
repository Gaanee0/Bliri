#!/bin/bash
set ${SET_X:+-x} -euo pipefail

# ── Helpers ────────────────────────────────────────────────────────────────────
log() { echo "=== $* ==="; }
RELEASE="$(rpm -E %fedora)"

# ── COPR Repos ─────────────────────────────────────────────────────────────────
log "Enabling COPR repos..."
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

# ── Terra Repo ─────────────────────────────────────────────────────────────────
log "Adding Terra repo..."
curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo \
  -o /etc/yum.repos.d/terra.repo

# Repo priorities (lower = higher priority)
echo "priority=1" >>/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri-git.repo
echo "priority=1" >>/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:ulysg:xwayland-satellite.repo
echo "priority=1" >>/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:scottames:ghostty.repo
echo "priority=2" >>/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:avengemedia:danklinux.repo
echo "priority=2" >>/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:deltacopy:darkly.repo
dnf5 -y config-manager setopt '*danklinux*.exclude=ghostty*'
dnf5 -y config-manager setopt 'terra.enabled=1' 'terra*.priority=3' 'terra*.exclude=ghostty matugen*'
# ── Packages ───────────────────────────────────────────────────────────────────
PKGS=(
  # Hardware
  dislocker
  ntfs2btrfs
  adb-enhanced
  asusctl

  # Fingerprint
  libfprint-elanmoc2
  fprintd
  fprintd-pam

  # Niri desktop
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
  darkly-qt5
  darkly-qt6
  greetd
  dms-greeter

  # Terminal
  ghostty
  ghostty-terminfo
  ghostty-shell-integration
  # ghostty-vim
  ghostty-zsh-completion
  ghostty-bash-completion
  ghostty-fish-completion
  foot
  foot-terminfo
  btop

  # Utilities
  dsearch
  brightnessctl
  playerctl
  wl-mirror
  khal
  cups-pk-helper

  # Fonts & themes
  material-symbols-fonts
  papirus-icon-theme
)

REMOVE_PKGS=(
  tmux
  kwrite
  kate
  Sunshine
)

# ── Install ────────────────────────────────────────────────────────────────────
log "Removing packages before reinstall..."
dnf5 -y remove --no-autoremove libfprint

log "Installing packages..."
dnf5 install -y --setopt=install_weak_deps=False "${PKGS[@]}"

log "Removing unwanted packages..."
dnf5 remove -y "${REMOVE_PKGS[@]}"

log "Cleaning up..."
dnf5 clean all
