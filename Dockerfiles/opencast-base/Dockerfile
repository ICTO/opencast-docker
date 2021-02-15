FROM quay.io/mm-dict/openjdk:11-jdk-slim-buster
LABEL maintainer="UGent Multimedia <multimedia@ugent.be>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="8.x" \
      org.label-schema.name="opencast-base" \
      org.label-schema.description="Docker image for the Opencast base" \
      org.label-schema.usage="https://github.com/mm-dict/opencast-docker/blob/5.2/README.md" \
      org.label-schema.url="http://www.opencast.org/" \
      org.label-schema.vcs-url="https://github.com/mm-dict/opencast-docker" \
      org.label-schema.vendor="Ghent University"

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
      nfs-common netcat-openbsd rsync vim \
 && rm -rf /tmp/* /var/lib/apt/lists/*