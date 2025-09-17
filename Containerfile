FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite-dx-nvidia:latest

RUN mkdir -p /nix \
    && curl -L https://install.determinate.systems/nix -o /nix/determinate-nix-installer.sh \
    && chmod +x /nix/determinate-nix-installer.sh \
    && /nix/determinate-nix-installer.sh install --determinate --no-confirm -- --init none

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    ostree container commit

RUN bootc container lint
