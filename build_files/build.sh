#/!/bin/bash

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
    heus-sueh/packages
    lihaohong/yazi
    arrobbins/JDSP4Linux
    varlad/zellij
    lukenukem/asus-linux
    atim/starship
    ryanabx/cosmic-epoch
    avengemedia/danklinux
    avengemedia/dms-git
    gaanee/libfprint-elanmoc2
    #errornointernet/quickshell
    #meeuw/keyd
    #solopasha/hyprland
)

for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

log "Enable terra repositories..."
dnf5 config-manager setopt terra.enabled=1 terra-extras.enabled=1

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
    syncthing
    flatpak-builder
    ghostty
    fuzzel
    #greetd
    #keyd
)

TERMINAL_APPS=(
    helix
    yazi
    zellij
    fish
    starship
    keychain
    neovim
    neovide
) 

PODMAN_PKGS=(
    dialog
    freerdp
    nmap-ncat
    podman-compose
)

NIRI_PKGS=(
    niri
    alacritty
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
    wtype
)

QUICK_SHELL=(
    #quickshell-git
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
    qt6ct
    qt5ct
    hyprpicker
    material-symbols-fonts
    matugen
    dms
    dgop
    #dms-greeter
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
    gnome-icon-theme
    gnome-colors-icon-theme
    adwaita-icon-theme
    rsms-inter-fonts
    gnome-themes-extra
    texlive-atkinson
    qgnomeplatform-qt5
    qgnomeplatform-qt6
    breeze-gtk
    gnome-icon-theme
    gnome-tweaks
    adb-enhanced
    #nwg-look
    #la-capitaine-cursor-theme
)

ASUS_PKGS=(
    asusctl
    supergfxctl
    asusctl-rog-gui
)

EXTRA_DE_PKGS=(
    #@cosmic-desktop
    #gnome-shell
    #@cosmic-desktop-apps
    #@gnome-desktop
)

FINGER_PRINT=(
     fprintd
     libfprint-elanmoc2
     fprintd-pam
)

REMOVE_PKGS=(
    tmux
    kwrite
    gnome-disks
    gnome-disk-utility
    sunshine
    quickshell-git
)

log "removing libfprint & quickshell-git" 
dnf5 remove -y libfprint quickshell-git

log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=False -y \
${ADDITIONAL_APPS[@]} \
${NIRI_PKGS[@]} \
${FONTS_OTHERS[@]} \
${PODMAN_PKGS[@]} \
${QUICK_SHELL[@]} \
${TERMINAL_APPS[@]} \
${ASUS_PKGS[@]} \
${EXTRA_DE_PKGS[@]} \
${FINGER_PRINT[@]}

log "Removing packages from dependcies"
dnf5 remove -y \
${REMOVE_PKGS[@]}

mkdir -p /nix && \
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o /nix/determinate-nix-installer.sh && \
	chmod a+rx /nix/determinate-nix-installer.sh

log "Disable Copr repos to get rid of clutter..."
for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr disable "$repo"
done

log "systemd servies"
    systemctl disable network-online.target
    dnf5 config-manager unsetopt cloudflared-stable.repo

dnf5 clean all
