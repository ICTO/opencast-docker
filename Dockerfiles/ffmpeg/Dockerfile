FROM nvidia/cuda:11.2.1-devel-ubuntu20.04 as build

RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
# Install basic development dependencies
RUN apt-get update && apt-get install -y \
    git \
    autoconf \
    build-essential \
    libass-dev \
    libtool \
    pkg-config \
    texinfo \
    zlib1g-dev \
    git

# Install FFmpeg dependencies
RUN apt-get update && apt-get -y install \
    autoconf \
    automake \
    build-essential \
    cmake \
    git \
    libass-dev \
    libfreetype6-dev \
    libsdl2-dev \
    libtheora-dev \
    libtool \
    libva-dev \
    libvpx-dev \
    libvdpau-dev \
    libvorbis-dev \
    libmp3lame-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    libx265-dev \
    libnuma-dev \
    libfdk-aac-dev \
    libx264-dev \
    nasm \
    mercurial \
    pkg-config \
    texinfo \
    wget \
    zlib1g-dev \
    yasm

RUN mkdir -p /src/deps /install
ENV PATH="/install/usr/bin:/install/bin:${PATH}"

## FFMPEG NV CODEC HEADERS ##
WORKDIR /src/deps
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
WORKDIR /src/deps/nv-codec-headers
RUN PREFIX=/install make install

## FFMPEG ##
WORKDIR /src
RUN git clone --depth=1 https://github.com/FFmpeg/FFmpeg.git /src/ffmpeg
WORKDIR /src/ffmpeg
ARG NVCC_ARCH="compute_60"
ARG NVCC_CODE="sm_60,sm_61,sm_62"
RUN export PKG_CONFIG_PATH="/install/lib/pkgconfig" && \
    ./configure \
        --prefix="/install" \
        --pkg-config-flags="--static" \
        --extra-cflags="-I/install/include" \
        --extra-ldflags="-L/install/lib" \
        --extra-cflags="-I/usr/local/cuda-${CUDA_VERSION%.*}/include" \
        --extra-ldflags=-L/usr/local/cuda-${CUDA_VERSION%.*}/lib \
        --extra-ldflags=-L/usr/local/cuda-${CUDA_VERSION%.*}/lib64 \
        --extra-libs="-lpthread -lm" \
        --nvccflags="--generate-code arch=$NVCC_ARCH,code=[$NVCC_CODE] -O2" \
        --enable-gpl \
        --enable-libass \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libx264 \
        --enable-libx265 \
        --enable-nonfree \
        --enable-cuda-sdk \
        --enable-cuvid \
        --enable-libnpp \
        --enable-nvenc \
        --enable-xlib \
        --disable-doc \
        --disable-debug \
        --disable-ffplay \
        && \
    make -j$(nproc) && \
    make -j$(nproc) install
RUN tar -cvf /src/ffmpeg-dynamic-deps.tar \
    $(ldd /install/bin/ffmpeg | \
      grep / | \
      awk '{ print $3 }' | \
      xargs readlink -f)

FROM nvidia/cuda:11.2.1-runtime-ubuntu20.04
RUN apt-get update && apt-get install -y \
     \
    && rm -rf /var/cache/apt


COPY --from=build /install/lib/* /usr/local/lib/
COPY --from=build /install/bin/* /usr/local/bin/
COPY --from=build /src/ffmpeg-dynamic-deps.tar /
RUN tar -xvf /ffmpeg-dynamic-deps.tar && \
    rm /ffmpeg-dynamic-deps.tar

ENV NVIDIA_VISIBLE_DEVICES all
# Without the following line, libnvcuvid.so.1 will not be mounted into
# the container, see
# https://github.com/NVIDIA/nvidia-docker/issues/531#issuecomment-343993909
# for further details, in nvidia/cuda:9.0 images the base image will
# set these for you
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,utility
VOLUME /workspace
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/ffmpeg"]
CMD ["-h"]