FROM scratch AS ctx
COPY build_files /

#FROM ghcr.io/ublue-os/bazzite-dx-nvidia:latest
FROM ghcr.io/ublue-os/bazzite-dx-nvidia:stable-42.20251019
#FROM ghcr.io/ublue-os/bazzite-dx-nvidia:stable-42@sha256:c18207b7d09fef3a9a0ac339f13eeaace333115edcc34a5478f37bde2c710255

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    ostree container commit

RUN bootc container lint
