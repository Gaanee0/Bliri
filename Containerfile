FROM scratch AS ctx
COPY build_files /

<<<<<<< HEAD
FROM ghcr.io/ublue-os/bazzite-dx-nvidia:latest
=======
# Base Image
FROM ghcr.io/ublue-os/bluefin-dx-nvidia-open:stable

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.
>>>>>>> ea8c02e (changed base image to bluefin-dc-nvidia-ope)

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    ostree container commit
<<<<<<< HEAD

=======
    
### LINTING
## Verify final image and contents are correct.
>>>>>>> ea8c02e (changed base image to bluefin-dc-nvidia-ope)
RUN bootc container lint
