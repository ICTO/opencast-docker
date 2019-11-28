FROM alpine:edge
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
    JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk" \
    PATH="$PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin" \
    HUNSPELL_BASE_URL="http://download.services.openoffice.org/contrib/dictionaries" \
    \
    OPENCAST_VERSION="8.x" \
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

RUN addgroup -S -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && adduser -S -D -H -G "${OPENCAST_GROUP}" -h "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_DATA}" \
 && chown -R "${OPENCAST_USER}":0 "${OPENCAST_DATA}"

RUN apk add --no-cache \
      openjdk8 \
      bash su-exec openssl tzdata curl jq \
      fontconfig ttf-dejavu ttf-freefont ttf-liberation ttf-linux-libertine \
      ffmpeg sox hunspell tesseract-ocr \
      nfs-utils \
  \
 && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
      boost boost-program_options boost-system boost-filesystem zlib libsigc++ glibmm cairo fftw pango gettext \
      imagemagick6 imagemagick6-dev libjpeg-turbo libtool libdv-tools \
      libxml++-2.6 mlt \
 && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.7/main \
      swfdec \
 && ln -s /usr/bin/convert-6 /usr/local/bin/convert \
  \
 && mkdir -p /tmp/hunspell /usr/share/hunspell \
 && { \
      echo "22e217a631977d7b377f8dd22d2bbacd2d36b32765ce13f3474b03a4a97dd700  en_AU.zip"; \
      echo "31fac12a1b520cde686f328d3fa7560f6eba772cddc872197ff842c57a0dc1ea  en_CA.zip"; \
      echo "5869d8bd80eb2eb328ebe36b356348de4ae2acb1db6df39d1717d33f89f63728  en_GB.zip"; \
      echo "6cc717b4de43240595662a2deef5447b06062e82380f5647196f07c9089284fa  en_NZ.zip"; \
      echo "9227f658f182c9cece797352f041a888134765c11bffc91951c010a73187baea  en_US.zip"; \
      echo "090285b721dcaabff51b467123f82a181a6904d187c90bda812c6e5f365ff19a  en_ZA.zip"; \
      echo "63ce36baf97b6ce2f533f5e77027810a12d1a008fd2acc0d8397f084a742dfb3  nl_NL.zip"; \
    } > /tmp/hunspell-sha256sum.txt \
 && cd /tmp/hunspell \
 && for file in $(awk '{print $2}' /tmp/hunspell-sha256sum.txt); do \
      curl -L -o "${file}" "${HUNSPELL_BASE_URL}/${file}"; \
      grep "${file}" /tmp/hunspell-sha256sum.txt | sha256sum -c -; \
      unzip "/tmp/hunspell/${file}"; \
    done \
 && cp *.aff *.dic /usr/share/hunspell \
 && rm -rf /tmp/*