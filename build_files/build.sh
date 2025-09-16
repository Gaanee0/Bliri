#!/bin/bash

#set -ouex pipefail
set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

RELEASE="$(rpm -E %fedora)"

log() {
  echo "=== $* ==="
}

log "Enable COPR repos...."
COPR_REPOS=(
    tofik/sway
    ulysg/xwayland-satellite
    yalter/niri
    leloubil/wl-clip-persist
    errornointernet/quickshell
    heus-sueh/packages
    gaanee/libfprint-elanmoc2
    alternateved/cliphist
    lihaohong/yazi
    arrobbins/JDSP4Linux
    varlad/zellij
    atim/starship
)

for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

log "Enable terra & docker repositories..."
dnf5 config-manager setopt terra.enabled=1 terra-extras.enabled=1
dnf5 config-manager addrepo --from-repofile="https://pkg.cloudflare.com/cloudflared.repo"
dnf5 config-manager addrepo --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
dnf5 config-manager setopt docker-ce-stable.enabled=0

ADDITIONAL_APPS=(
    testdisk
    fwupd
    fwupd-efi
    kde-partitionmanager
    dislocker
    ntfs-3g
    ntfs2btrfs
    ntfs-3g-system-compression
    JamesDSP
    cloudflared
    syncthing
    flatpak-builder
    ghostty
)

TERMINAL_APPS=(
    helix
    yazi
    zellij
    fish
    starship
    keychain
) 

PODMAN_PKGS=(
    dialog
    freerdp
    nmap-ncat
    podman-compose
)

DOCKER_PKGS=(
    containerd.io
    docker-buildx-plugin
    docker-ce
    docker-ce-cli
    docker-compose-plugin
)

NIRI_PKGS=(
    niri
    alacritty
    fuzzel
    swayidle
    swaybg
    brightnessctl
    xwayland-satellite
    gnome-keyring
    wireplumber
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    mate-polkit
    cliphist
    wl-clipboard
    pavucontrol
    qt6ct
    qt5ct
)

QUICK_SHELL=(
    quickshell-git
    qt5-qtsvg
    gtk-murrine-engine
    qt6-qtsvg
    qt5-qtimageformats
    qt6-qtimageformats
    qt5-qtmultimedia
    qt6-qtmultimedia
    qt6-qt5compat
    matugen
    sassc
    libass
    cava
    go
    golang
    gammastep
)

FONTS_OTHERS=(
    material-icons-fonts
    fira-code-fonts
    fontawesome-fonts-all
    google-noto-emoji-fonts
    adobe-source-code-pro-fonts
    google-droid-sans-fonts
    google-noto-sans-cjk-fonts
    google-noto-color-emoji-fonts
    jetbrains-mono-fonts
    wine-ms-sans-serif-fonts
    la-capitaine-cursor-theme
    gnome-icon-theme
    gnome-colors-icon-theme
    adwaita-icon-theme
    rsms-inter-fonts
    gnome-themes-extra
    texlive-atkinson
)

FINGER_PRINT=(
     fprintd
     libfprint-elanmoc2
     fprintd-pam
)

REMOVE_PKGS=(
    tmux
    kwrite
    lutris
    gnome-disks
    gnome-disk-utility
    sunshine
)

log "removing libfprint" 
dnf5 remove -y libfprint

log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=False -y \
${ADDITIONAL_APPS[@]} \
${NIRI_PKGS[@]} \
${FONTS_OTHERS[@]} \
${PODMAN_PKGS[@]} \
${QUICK_SHELL[@]} \
${TERMINAL_APPS[@]} \
${FINGER_PRINT[@]}

dnf5 install -y --enable-repo="docker-ce-stable" "${DOCKER_PKGS[@]}" || {
    if (($(lsb_release -sr) == 42)); then
        echo "::info::Missing docker packages in f42, falling back to test repos..."
        dnf5 install -y --enablerepo="docker-ce-test" "${DOCKER_PKGS[@]}"
    fi
}

log "Creating /nix and downloading determinite Nix installer."

mkdir -p /nix && \
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o /nix/determinate-nix-installer.sh && \
	chmod a+rx /nix/determinate-nix-installer.sh
	/nix/determinate-nix-installer.sh install --determinate --no-confirm --no-start-daemon
    
log "Removing packages from dependcies"
dnf5 remove -y \
${REMOVE_PKGS[@]}

log "Disable Copr repos to get rid of clutter..."
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr disable "$repo"
done

log "Enabling systemd.services..."
mkdir -p /etc/modules-load.d && cat >>/etc/modules-load.d/ip_tables.conf <<EOF
iptable_nat
EOF

systemctl enable docker
systemctl enable nix-daemon
