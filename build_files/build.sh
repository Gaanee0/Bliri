#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

log() {
  echo "=== $* ==="
}

log "Creating temporary GPG directory..."
export GNUPGHOME=/tmp/gnupg
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

log "Enable COPR repos...." 
COPR_REPOS=(
     sneexy/zen-browser
     varlad/zellij 
)
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

ADDITIONAL_SYSTEM_APPS=(
     zen-browser
     helix
     zellij
) 

log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=True -y \
${ADDITIONAL_SYSTEM_APPS[@]}

log "Disable Copr repos to get rid of clutter..."
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr disable "$repo"
done

log "Cleaning up temporary GPG directory..."
rm -rf "$GNUPGHOME"
unset GNUPGHOME

log "Enabling systems.services..."
systemctl enable podman.socket
