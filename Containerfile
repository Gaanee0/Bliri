FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# FROM ghcr.io/ublue-os/aurora-dx-nvidia-open:latest AS bliri
FROM ghcr.io/ublue-os/aurora-dx-nvidia-open:testing AS bliri

RUN rm -rvf /opt && mkdir -p /opt

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/build.sh
# ostree container commit

RUN bootc container lint
