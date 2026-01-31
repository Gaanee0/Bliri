#/!/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

RELEASE="$(rpm -E %fedora)"

log() {
  echo "=== $* ==="
}

log "Enable COPR repos...."
COPR_REPOS=(
    yalter/niri
    ulysg/xwayland-satellite
    avengemedia/danklinux
    avengemedia/dms-git
    gaanee/libfprint-elanmoc2
    deltacopy/darkly
    faugus/faugus-launcher
    solopasha/hyprland
)

for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

log "Adding repos & Optimizing build time..."
echo "priority=1" | tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:yalter:niri.repo
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
    faugus-launcher
)

NIRI_PKGS=(
    niri
    xwayland-satellite
    xdg-desktop-portal-gnome
    alacritty
    quickshell-git
    swaybg
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
)

FINGER_PRINT=(
     fprintd
     libfprint-elanmoc2
     fprintd-pam
)

REMOVE_PKGS=(
    tmux
    kwrite
    gnome-disk-utility
    Sunshine
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
dnf5 clean all
