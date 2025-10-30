FROM scratch AS ctx
COPY build_files /

#FROM ghcr.io/ublue-os/bazzite-dx-nvidia:latest
FROM ghcr.io/ublue-os/bazzite-dx-nvidia:42@sha256-b8879006cc5ad5220780fa3102102855fd70a25a6574f74229c30679c006bc4f

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    ostree container commit

RUN bootc container lint
