# Copyright 2016 The WWU eLectures Team All rights reserved.
#
# Licensed under the Educational Community License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
#     http://opensource.org/licenses/ECL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM quay.io/mm-dict/maven:3-jdk-11-slim AS build

ARG repo="https://github.com/mm-dict/opencast.git"
ARG branch="r/10.x-ugent"

ENV OPENCAST_DISTRIBUTION="worker" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}" \
    FFMPEG_VERSION="20210620044626-N-102774-g2cf95f2dd9"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bzip2 \
      ca-certificates \
      g++ \
      gcc \
      git \
      gzip \
      libc-dev \
      make \
      openssl \
      tar \
      xz-utils \
  \
 && groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_SRC}" "${OPENCAST_HOME}" \
  \
 && cd \
 && rm -rf /tmp/* /var/lib/apt/lists/*

USER "${OPENCAST_USER}"

RUN git clone --recursive "${OPENCAST_REPO}" "${OPENCAST_SRC}" \
 && cd "${OPENCAST_SRC}" \
 && git checkout "${OPENCAST_BRANCH}" \
 && mvn --batch-mode install \
      -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
      -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
      -DskipTests=true \
      -Dcheckstyle.skip=true \
      -DskipJasmineTests=true \
 && tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}" \
 && rm -rf "${OPENCAST_SRC}"/* ~/.m2 ~/.npm ~/.node-gyp

FROM nvidia/cuda:11.2.1-runtime-ubuntu20.04 AS build-ffmpeg

ENV LANG="C.UTF-8" \
    OPENCAST_VERSION="9.x" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    NASM_VERSION="2.15.03" \
    YASM_VERSION="1.3.0" \
    LAME_VERSION="3.100" \
    OPUS_VERSION="1.3.1" \
    LASS_VERSION="0.14.0" \
    CUDA_DIR="/usr/local/cuda" \
    WORK_DIR="$HOME/ffmpeg-build-static-sources" \
    DEST_DIR="$HOME/ffmpeg-build-static-binaries" \
    DEBIAN_FRONTEND="noninteractive"

# Install all dependencies from the repositories
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      autoconf automake libtool patch make cmake bzip2 unzip wget git mercurial \
      build-essential pkg-config texi2html software-properties-common \
      libfreetype6-dev libgpac-dev libsdl1.2-dev libtheora-dev libva-dev \
      libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev zlib1g-dev \
      nasm yasm tzdata libgmp-dev nvidia-cuda-toolkit libass-dev


RUN mkdir -p /src/deps /install
ENV PATH="/install/usr/bin:/install/bin:${PATH}"

## Install libx264
WORKDIR /src/deps
RUN git clone https://code.videolan.org/videolan/x264.git && \
    cd x264 && \
    ./configure --prefix="/install" --bindir="/install/bin" --enable-static --disable-shared && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    make -j$(nproc) distclean

## Install libfdk-aac
WORKDIR /src/deps
RUN git clone https://github.com/mstorsjo/fdk-aac.git && \
    cd fdk-aac && \
    autoreconf -fiv && \
    ./configure --prefix="/install" --enable-static --disable-shared && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    make -j$(nproc) distclean

#Compile libmp3lame

WORKDIR /src/deps

RUN wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz && \
    tar xzvf lame-3.99.5.tar.gz && \
    cd lame-3.99.5 && \
    ./configure --prefix="/install" --enable-nasm --enable-static --disable-shared && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    make -j$(nproc) distclean

#Compile libopus
WORKDIR /src/deps

RUN wget http://downloads.xiph.org/releases/opus/opus-1.2.1.tar.gz && \
    tar xzvf opus-1.2.1.tar.gz && \
    cd opus-1.2.1 && \
    ./configure --prefix="/install" --enable-static --disable-shared && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    make -j$(nproc) distclean

#Compile libvpx
WORKDIR /src/deps

RUN git clone https://chromium.googlesource.com/webm/libvpx && \
    cd libvpx && \
    ./configure --prefix="/install" --disable-examples --enable-runtime-cpu-detect --enable-vp9 --enable-vp8 \
        --enable-postproc --enable-vp9-postproc --enable-multi-res-encoding --enable-webm-io --enable-better-hw-compatibility --enable-vp9-highbitdepth --enable-onthefly-bitpacking --enable-realtime-only \
        --cpu=native --as=nasm --enable-static --disable-shared && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    make -j$(nproc) clean


#Compile libgmp
WORKDIR /src/deps

RUN wget https://gmplib.org/download/gmp/gmp-6.1.0.tar.xz && \
    tar xvf gmp-6.1.0.tar.xz && \
    cd gmp-6.1.0 && \
    ./configure --prefix="/install" --bindir="/install/bin" --enable-static --disable-shared && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    make -j$(nproc) distclean

#Compile libnettle
WORKDIR /src/deps

RUN wget https://ftp.gnu.org/gnu/nettle/nettle-3.7.tar.gz && \
    tar xzvf nettle-3.7.tar.gz && \
    cd nettle-3.7 && \
    ./configure --prefix="/install" --bindir="/install/bin" --enable-static --disable-shared && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    make -j$(nproc) distclean

#Compile libgnutls
WORKDIR /src/deps

RUN wget https://www.gnupg.org/ftp/gcrypt/gnutls/v3.6/gnutls-3.6.15.tar.xz && \
    tar xvf gnutls-3.6.15.tar.xz && \
    cd gnutls-3.6.15 && \
    PKG_CONFIG_PATH="/install/lib64/pkgconfig:$PKG_CONFIG_PATH" ./configure --prefix="/install" --bindir="/install/bin" --enable-static --disable-shared --with-included-libtasn1 \
        --with-included-unistring --without-p11-kit --disable-doc --disable-cxx --disable-tools && \
    make -j$(nproc) && \
    make -j$(nproc) install

## FFMPEG NV CODEC HEADERS ##
WORKDIR /src/deps
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git && \
    cd /src/deps/nv-codec-headers && \
    PREFIX=/install make install

## LIBX265 ##
WORKDIR /src/deps
RUN git clone https://github.com/videolan/x265.git && \
    cd /src/deps/x265 && \
    cd build/linux && \
    cmake -G "Unix Makefiles" \
        -DCMAKE_INSTALL_PREFIX="/install" \
        -DENABLE_SHARED:bool=off \
        ../../source \
        && \
    make -j$(nproc) && \
    make -j$(nproc) install

## FFMPEG ##
WORKDIR /src
RUN git clone --depth=1 https://github.com/FFmpeg/FFmpeg.git /src/ffmpeg
WORKDIR /src/ffmpeg
RUN export PKG_CONFIG_PATH="/install/lib/pkgconfig:/install/lib64/pkgconfig" && \
    ./configure \
        --prefix="/install" \
        --bindir="/install/bin" \
        --pkg-config-flags="--static" \
        --extra-cflags="-I/install/include -I/usr/local/cuda/include" \
        --extra-ldflags="-L/install/lib -L/usr/local/cuda/lib64" \
        --extra-libs="-Wl,-Bdynamic -ldl -lm" \
        --extra-libs="-lpthread" \
        --enable-static \
        --enable-gpl \
        --enable-version3 \
        --enable-libass \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libx264 \
        --enable-libx265 \
        --enable-libopus \
        --enable-nonfree \
        --enable-cuda-nvcc \
        --enable-cuvid \
        --enable-libnpp \
        --enable-nvenc \
        --enable-nvdec \
        --enable-gnutls \
        --disable-doc \
        --disable-debug \
        --disable-ffplay \
        --disable-indev=sndio \
        --disable-outdev=sndio \
        && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    make -j$(nproc) distclean && \
    hash -r

FROM nvidia/cuda:11.2.1-runtime-ubuntu20.04

LABEL maintainer="UGent Multimedia <multimedia@ugent.be>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="10.x" \
      org.label-schema.name="opencast-worker" \
      org.label-schema.description="Docker image for the Opencast worker distribution" \
      org.label-schema.usage="https://github.com/mm-dict/opencast-docker/blob/5.2/README.md" \
      org.label-schema.url="http://www.opencast.org/" \
      org.label-schema.vcs-url="https://github.com/mm-dict/opencast-docker" \
      org.label-schema.vendor="Ghent University"

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,utility,graphics
ENV OPENCAST_VERSION="10.0" \
    OPENCAST_DISTRIBUTION="worker" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}"
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_SUPPORT="${OPENCAST_HOME}/docker/support" \
    OPENCAST_CONFIG="${OPENCAST_HOME}/etc"

COPY --from=build-ffmpeg /install/bin/* /usr/local/bin/

RUN groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_DATA}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_DATA}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      fontconfig \
      fonts-dejavu \
      fonts-freefont-ttf \
      fonts-liberation \
      fonts-linuxlibertine \
      hunspell \
      hunspell-en-au \
      hunspell-en-ca \
      hunspell-en-gb \
      hunspell-en-us \
      hunspell-en-za \
      hunspell-nl-nl \
      jq \
      netcat-openbsd \
      nfs-common \
      nvidia-cuda-toolkit \
      openjdk-11-jdk \
      openssl \
      sox \
      synfig \
      tesseract-ocr \
      tesseract-ocr-eng \
      tesseract-ocr-nld \
      tzdata \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build --chown=opencast:opencast "${OPENCAST_HOME}" "${OPENCAST_HOME}"
COPY rootfs /

RUN if [ "${OPENCAST_DISTRIBUTION}" = "allinone" ]; then \
      rm -f "${OPENCAST_CONFIG}/org.opencastproject.organization-mh_default_org.cfg-clustered"; \
    fi \
 && mv "${OPENCAST_CONFIG}/org.opencastproject.organization-mh_default_org.cfg-clustered" "${OPENCAST_CONFIG}/org.opencastproject.organization-mh_default_org.cfg" || true \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_HOME}" \
 && javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java" \
 && rm -rf /tmp/* "${OPENCAST_SCRIPTS}/TryToConnectToDb.java"

WORKDIR "${OPENCAST_HOME}"

EXPOSE 8080
VOLUME [ "${OPENCAST_DATA}" ]

HEALTHCHECK --timeout=10s CMD /docker-healthcheck.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app:start"]
