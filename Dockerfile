FROM --platform=$BUILDPLATFORM docker:stable-git

ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="Droid Runner" \
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
RUN apk add --no-cache --purge -uU \
    bash make curl ca-certificates wget \
    alpine-sdk alpine-base coreutils binutils libc-dev util-linux ncurses-libs \
    rsync sshpass openssh openssl gnupg zlib zip unzip tar xz \
    sudo shadow gawk python3 py3-pip \
  && rm -rf /var/cache/apk/* /tmp/* 

# Add builder user to match droid-builder container
RUN set -xe \
  && groupadd --gid 1000 builder \
  && useradd --uid 1000 --gid builder --shell /bin/bash --create-home builder \
  && echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/builder \
  && chmod 0440 /etc/sudoers.d/builder

RUN set -xe \
  && curl -sL https://gerrit.googlesource.com/git-repo/+/refs/heads/stable/repo?format=TEXT | base64 --decode > /usr/bin/repo \
  && curl -s https://api.github.com/repos/tcnksm/ghr/releases/latest | grep "browser_download_url" | grep "amd64.tar.gz" | cut -d '"' -f 4 | wget -qi - \
  && tar -xzf ghr_*_amd64.tar.gz \
  && cp ghr_*_amd64/ghr /usr/bin/ \
  && rm -rf ghr_* \
  && curl -sL https://github.com/yshalsager/telegram.py/raw/master/telegram.py -o /usr/bin/tg.py \
  && sed -i '1i #!\/usr\/bin\/python3' /usr/bin/tg.py \
  && pip3 install requests \
  && sed -i '1s/python/python3/g' /usr/bin/repo \
  && chmod a+rx /usr/bin/repo \
  && chmod a+x /usr/bin/ghr /usr/bin/tg.py

USER builder

VOLUME [/home/builder/]
VOLUME [/home/builder/android]
