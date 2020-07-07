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

FROM maven:3.6-jdk-8-slim AS build

ARG repo="https://github.com/mm-dict/opencast.git"
ARG branch="r/8.x-ugent"

ENV OPENCAST_DISTRIBUTION="admin" \
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
      make gcc g++ libc-dev unzip \
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
 && tar -xzf build/opencast-dist-allinone-*.tar.gz --strip 1 -C "${OPENCAST_HOME}" \
 && rm -rf "${OPENCAST_SRC}"/* ~/.m2 ~/.npm ~/.node-gyp


RUN unzip "${OPENCAST_HOME}"/system/org/opencastproject/opencast-engage-ui/8-SNAPSHOT/opencast-engage-ui-8-SNAPSHOT.jar -d /tmp/engage \
 && unzip "${OPENCAST_HOME}"/system/org/opencastproject/opencast-engage-paella-player/8-SNAPSHOT/opencast-engage-paella-player-8-SNAPSHOT.jar -d /tmp/paella

FROM nginxinc/nginx-unprivileged:1.18.0
LABEL maintainer="UGent Multimedia <multimedia@ugent.be>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="8.x" \
      org.label-schema.vendor="Ghent University"

RUN mkdir -p /etc/nginx/opencast/engage/ui /etc/nginx/opencast/paella/ui

COPY --from=build /tmp/engage/ui /etc/nginx/opencast/engage/ui/
COPY --from=build /tmp/paella/ui /etc/nginx/opencast/paella/ui/

