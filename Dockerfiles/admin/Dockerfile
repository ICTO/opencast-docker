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

FROM openjdk:8-jdk-slim-stretch AS build

ARG repo="https://github.com/mm-dict/opencast.git"
ARG branch="r/7.x-ugent"

ENV OPENCAST_DISTRIBUTION="admin" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}" \
    MAVEN_MIRROR_URL="http://nexus.opencast.svc.cluster.local:8081/nexus/content/groups/public"

RUN mkdir /root/.m2
COPY assets/settings.xml /root/.m2/settings.xml

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      tar gzip git \
      ca-certificates openssl \
      maven make gcc g++ libc-dev \
 && mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" \
 && git clone --recursive "${OPENCAST_REPO}" "${OPENCAST_SRC}" \
 && cd "${OPENCAST_SRC}" \
 && git checkout "${OPENCAST_BRANCH}" \
 && mvn --quiet --batch-mode install -DskipTests=true -Dcheckstyle.skip=true -DskipJasmineTests=true \
 && tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}" \
 && rm -rf "${OPENCAST_SRC}" /tmp/* /var/lib/apt/lists/* ~/.m2 ~/.npm ~/.node-gyp /usr/lib/node_modules

FROM quay.io/mtneug/synfig-core AS synfig

FROM alpine:edge
LABEL maintainer="WWU eLectures team <electures.dev@uni-muenster.de>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="7.x" \
      org.label-schema.name="opencast-admin" \
      org.label-schema.description="Docker image for the Opencast admin distribution" \
      org.label-schema.usage="https://github.com/opencast/opencast-docker/blob/5.2/README.md" \
      org.label-schema.url="http://www.opencast.org/" \
      org.label-schema.vcs-url="https://github.com/opencast/opencast-docker" \
      org.label-schema.vendor="University of Münster" \
      org.label-schema.docker.debug="docker exec -it $CONTAINER sh" \
      org.label-schema.docker.cmd.help="docker run --rm quay.io/opencast/admin:7.x app:help"

ENV LANG="C.UTF-8" \
    JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk" \
    PATH="$PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin" \
    HUNSPELL_BASE_URL="http://download.services.openoffice.org/contrib/dictionaries" \
    \
    OPENCAST_VERSION="7.x" \
    OPENCAST_DISTRIBUTION="admin" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800"
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_SUPPORT="${OPENCAST_HOME}/docker/support" \
    OPENCAST_CONFIG="${OPENCAST_HOME}/etc" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}"

RUN addgroup -S -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && adduser -S -D -H -G "${OPENCAST_GROUP}" -h "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_DATA}" \
 && chown -R "${OPENCAST_USER}":0 "${OPENCAST_DATA}"

COPY --chown="${OPENCAST_USER}":0 --from=build "${OPENCAST_HOME}" "${OPENCAST_HOME}"
COPY --chown="${OPENCAST_USER}":0 assets/scripts "${OPENCAST_SCRIPTS}"
COPY --chown="${OPENCAST_USER}":0 assets/support "${OPENCAST_SUPPORT}"
COPY --chown="${OPENCAST_USER}":0 assets/etc/* "${OPENCAST_CONFIG}/"
COPY --chown="${OPENCAST_USER}":0 assets/etc/index/adminui/settings.yml "${OPENCAST_CONFIG}/index/adminui/"
COPY --chown="${OPENCAST_USER}":0 assets/etc/index/externalapi/settings.yml "${OPENCAST_CONFIG}/index/externalapi/"
COPY --chown="${OPENCAST_USER}":0 assets/docker-entrypoint.sh assets/docker-healthcheck.sh /

COPY --from=synfig /usr/local/bin/ETL* /usr/local/bin/
COPY --from=synfig /usr/local/bin/synfig* /usr/local/bin/
COPY --from=synfig /usr/local/etc/synfig_modules.cfg /usr/local/etc/synfig_modules.cfg
COPY --from=synfig /usr/local/lib/libsynfig.* /usr/local/lib/
COPY --from=synfig /usr/local/lib/synfig/modules /usr/local/lib/synfig/modules
COPY --from=synfig /usr/local/share/locale /usr/local/share/locale

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
 && javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java" \
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

RUN chown -R "${OPENCAST_USER}":0 \
      "${OPENCAST_HOME}" \
      /etc/passwd \
 && chmod -R g+rw \
      "${OPENCAST_HOME}" \
      /etc/passwd \
 && chmod -R g+rwx "${OPENCAST_HOME}"/bin

WORKDIR "${OPENCAST_HOME}"

EXPOSE 8080
VOLUME [ "${OPENCAST_DATA}" ]

USER "${OPENCAST_USER}"

HEALTHCHECK --timeout=10s CMD /docker-healthcheck.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app:start"]
