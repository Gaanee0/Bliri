#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

log() {
  echo "=== $* ==="
}

# Add Terra repo via dnf
dnf5 config-manager --add-repo https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo
# Install terra-release (which registers the repo) and wpaperd
dnf5 install --nogpgcheck -y terra-release wpaperd

log "Enable COPR repos...." 
COPR_REPOS=(
     
)
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

ADDITIONAL_SYSTEM_APPS=(
     
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
