#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

log() {
  echo "=== $* ==="
}

log "Add Terra repository..."
dnf5 -y install --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra${RELEASE}" terra-release
dnf5 -y install terra-release-extras || true
dnf5 config-manager setopt "terra*".enabled=0

log "Enable COPR repos...." 
COPR_REPOS=(
    yalter/niri
)
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

ADDITIONAL_SYSTEM_APPS=(
     wpaperd
) 

log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=True -y \
${ADDITIONAL_SYSTEM_APPS[@]}

log "Disable Copr repos to get rid of clutter..."
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr disable "$repo"
done

log "Enabling systemd.services..."
systemctl enable podman.socket
