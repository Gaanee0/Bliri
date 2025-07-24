#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

log() {
  echo "=== $* ==="
}

log "Adding Terra repo..."
curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo | pkexec tee > /etc/yum.repos.d/terra.repo

log "Enable COPR repos...." 
COPR_REPOS=(
     
)
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

ADDITIONAL_SYSTEM_APPS=(
     wpaperd
     syncthing
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
