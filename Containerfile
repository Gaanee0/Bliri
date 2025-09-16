FROM scratch AS ctx
COPY build_files /

#FROM ghcr.io/ublue-os/bazzite-dx-nvidia:latest
FROM ghcr.io/ublue-os/bazzite-asus-nvidia-open:latest

COPY --from=ghcr.io/determinate-systems/nix:latest /nix /nix
COPY --from=ghcr.io/determinate-systems/nix:latest /etc/profile.d/nix.sh /etc/profile.d/nix.sh
COPY --from=ghcr.io/determinate-systems/nix:latest /usr/local/bin /usr/local/bin

RUN restorecon -RF /nix || true && \
    systemctl enable nix-daemon.service || true
 
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    ostree container commit

RUN bootc container lint
