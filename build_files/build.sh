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
    lukenukem/asus-linux
    avengemedia/danklinux
    avengemedia/dms-git
    gaanee/libfprint-elanmoc2
    #ulysg/xwayland-satellite
    #heus-sueh/packages
    #solopasha/hyprland
    #tofik/sway
    #atim/starship
    #arrobbins/JDSP4Linux
    #lihaohong/yazi
    #rankyn/input-remapper-git
    #errornointernet/quickshell
    #avengemedia/dms
    #meeuw/keyd
    #ryanabx/cosmic-epoch
    #varlad/zellij
)

for repo in "${COPR_REPOS[@]}"; do
  dnf5 -y copr enable "$repo"
done

log "Enable terra repositories..."
dnf5 config-manager setopt terra.enabled=1 terra-extras.enabled=1 terra.exclude=matugen

ADDITIONAL_APPS=(
    testdisk
    kde-partitionmanager
    dislocker
    ntfs2btrfs
    gvfs-fuse
    adb-enhanced
    #syncthing
    #fuzzel
    #JamesDSP
    #greetd
    #input-remapper-git
    #keyd
    #fwupd
    #fwupd-efi
    #ntfs-3g
    #flatpak-builder
    #ntfs-3g-system-compression
    #ghostty
)

TERMINAL_APPS=(
    helix
    #starship
    #keychain
    #yazi
    #zellij
    #neovim
    #neovide
    #fish
)

PODMAN_PKGS=(
    dialog
    nmap-ncat
    podman-compose
    #freerdp
)

NIRI_PKGS=(
    niri
    alacritty
    xwayland-satellite
    xdg-desktop-portal-gnome
    swaybg
    #swww
    #mate-polkit
    #gnome-keyring
    #pavucontrol
    #brightnessctl
    #wtype
    #cliphist
    #lz4
    #gifsicle
    #dav1d
    #wireplumber
    #xdg-desktop-portal-gtk
    #wl-clipboard
)

QUICK_SHELL=(
    quickshell-git
    matugen
    cava
    go
    golang
    gammastep
    qt6ct
    qt5ct
    dms
    dgop
    dsearch
    dms-cli
    #sassc
    #wayland-protocols-devel
    #gtk-murrine-engine
    #wl-mirror
    #dms-greeter
    #dcal
    #hyprpicker
    #qt5-qtsvg
    #libass
    #qt6-qtsvg
    #qt5-qtimageformats
    #qt6-qtimageformats
    #qt5-qtmultimedia
    #qt6-qtmultimedia
    #qt6-qt5compat
    #qt5-qtbase-gui
    #qt6-qtbase-gui
)

FONTS_OTHERS=(
    adw-gtk3-theme
    nwg-look
    material-symbols-fonts
    rsms-inter-fonts
    qgnomeplatform-qt5
    qgnomeplatform-qt6
    fontawesome-fonts-all
    jetbrains-mono-fonts
    wine-ms-sans-serif-fonts
    #material-icons-fonts
    #gnome-icon-theme
    #gnome-themes-extra
    #gnome-colors-icon-theme
    #adobe-source-code-pro-fonts
    #breeze-gtk
    #texlive-atkinson
    #gnome-tweaks
    #adwaita-icon-theme
    #la-capitaine-cursor-theme
    #fira-code-fonts
    #google-droid-sans-fonts
    #google-noto-sans-cjk-fonts
    #google-noto-color-emoji-fonts
    #google-noto-emoji-fonts
)

ASUS_PKGS=(
    asusctl
    #asusctl-rog-gui
    #supergfxctl
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
    gnome-disk-utility
    Sunshine
    #gnome-disks
)

log "removing to reinstall"
dnf5 remove -y libfprint

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
    dnf5 config-manager unsetopt cloudflared-stable.repo
    systemctl disable network-online.target
    systemctl enable podman.socket
    #systemctl disable sddm.service
    #systemctl enable greetd

dnf5 clean all
