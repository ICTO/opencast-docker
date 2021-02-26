FROM nvidia/cuda:11.2.1-runtime-ubuntu20.04

ENV LANG="C.UTF-8" \
    OPENCAST_VERSION="9.x" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800"

ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_SUPPORT="${OPENCAST_HOME}/docker/support" \
    OPENCAST_CONFIG="${OPENCAST_HOME}/etc"

RUN groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_DATA}" \
 && chown -R "${OPENCAST_USER}":0 "${OPENCAST_DATA}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates openssl tzdata curl jq \
      fontconfig fonts-dejavu fonts-freefont-ttf fonts-liberation fonts-linuxlibertine \
      hunspell hunspell-en-au hunspell-en-ca hunspell-en-gb hunspell-en-us hunspell-en-za \
      tesseract-ocr tesseract-ocr-eng \
      sox synfig \
      nfs-common netcat-openbsd rsync vim ffmpeg \
      openjdk-11-jdk

ENV NVIDIA_VISIBLE_DEVICES all
# Without the following line, libnvcuvid.so.1 will not be mounted into
# the container, see
# https://github.com/NVIDIA/nvidia-docker/issues/531#issuecomment-343993909
# for further details, in nvidia/cuda:9.0 images the base image will
# set these for you
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,utility
ENTRYPOINT ["nvidia-smi"]
CMD ["-L"]