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

FROM quay.io/mm-dict/maven:3-jdk-8 AS build

ARG repo="https://github.com/mm-dict/opencast.git"
ARG branch="r/9.x-ugent"

ENV OPENCAST_DISTRIBUTION="allinone" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}" \
    FFMPEG_VERSION="20200316042902-N-96975-gc467328f07"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      tar gzip bzip2 xz-utils git \
      ca-certificates openssl \
      make gcc g++ libc-dev \
  \
 && mkdir -p /tmp/ffmpeg \
 && cd /tmp/ffmpeg \
 && curl -sSL "https://pkg.opencast.org/bin/ffmpeg/ffmpeg-${FFMPEG_VERSION}.tar.xz" \
     | tar xJf - --strip-components 1 --wildcards '*/ffmpeg' '*/ffprobe' \
 && chown root:root ff* \
 && mv ff* /usr/local/bin \
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
 && mvn --quiet --batch-mode install -DskipTests=true -Dcheckstyle.skip=true -DskipJasmineTests=true \
 && tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}" \
 && rm -rf "${OPENCAST_SRC}"/* ~/.m2 ~/.npm ~/.node-gyp

FROM quay.io/mm-dict/opencast-base:9.x
LABEL maintainer="UGent Multimedia <multimedia@ugent.be>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="9.x" \
      org.label-schema.name="opencast-allinone" \
      org.label-schema.description="Docker image for the Opencast admin distribution" \
      org.label-schema.usage="https://github.com/mm-dict/opencast-docker/blob/5.2/README.md" \
      org.label-schema.url="http://www.opencast.org/" \
      org.label-schema.vcs-url="https://github.com/mm-dict/opencast-docker" \
      org.label-schema.vendor="Ghent University"

ENV OPENCAST_VERSION="9.0" \
    OPENCAST_DISTRIBUTION="allinone" \
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

COPY --from=build /usr/local/bin/ff* /usr/local/sbin/
COPY --chown=opencast:0 --from=build "${OPENCAST_HOME}" "${OPENCAST_HOME}"
COPY --chown=opencast:0 assets/scripts "${OPENCAST_SCRIPTS}"
COPY --chown=opencast:0 assets/support "${OPENCAST_SUPPORT}"
COPY --chown=opencast:0 assets/etc/* "${OPENCAST_CONFIG}/"
COPY --chown=opencast:0 assets/docker-entrypoint.sh assets/docker-healthcheck.sh /

RUN javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java"

WORKDIR "${OPENCAST_HOME}"

EXPOSE 8080
VOLUME [ "${OPENCAST_DATA}" ]

HEALTHCHECK --timeout=10s CMD /docker-healthcheck.sh
RUN chmod g=u /etc/passwd
RUN chmod g=u "${OPENCAST_CONFIG}/"
RUN chmod g+x "${OPENCAST_HOME}"/bin/start-opencast
RUN chmod g=u "${OPENCAST_HOME}"/data "${OPENCAST_HOME}"/data/tmp

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app:start"]
