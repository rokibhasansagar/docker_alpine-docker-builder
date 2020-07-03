FROM --platform=$BUILDPLATFORM docker:stable-git

ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="alpine-docker-builder" \
  org.label-schema.description="Docker runner based on Alpine image" \
  org.label-schema.url="https://rokibhasansagar.github.io/docker_alpine-docker-builder" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url=$VCS_URL \
  org.label-schema.vendor="Rokib Hasan Sagar" \
  org.label-schema.version=$VERSION \
  org.label-schema.schema-version="1.0"

LABEL maintainer="fr3akyphantom <rokibhasansagar2014@outlook.com>"

ENV LANG=C.UTF-8

RUN set -xe \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# docker and git are pre-installed
RUN apk add --no-cache --purge -uU bash make curl ca-certificates wget \
    alpine-sdk alpine-base coreutils binutils libc-dev util-linux ncurses-libs \
    openssh openssl gnupg zlib zip unzip tar xz \
    sudo shadow tree gawk \
  && rm -rf /var/cache/apk/* /tmp/* 

# Add builder user to match droid-builder container
RUN set -xe \
  && groupadd --gid 1000 builder \
  && useradd --uid 1000 --gid builder --shell /bin/bash --create-home builder \
  && echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/builder \
  && chmod 0440 /etc/sudoers.d/builder

USER builder

VOLUME [/home/builder/]
