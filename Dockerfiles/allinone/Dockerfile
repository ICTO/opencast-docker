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
ARG branch="r/8.x"

ENV OPENCAST_DISTRIBUTION="allinone" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}"

RUN echo '{ "allow_root": true }' > /root/.bowerrc

RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      tar gzip git bzip2 \
      ca-certificates openssl \
      maven make gcc g++ libc-dev \
 && mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}"

 RUN git clone --recursive "${OPENCAST_REPO}" "${OPENCAST_SRC}" \
 && cd "${OPENCAST_SRC}" \
 && git checkout "${OPENCAST_BRANCH}" \
 && mvn --quiet --batch-mode install -DskipTests=true -Dcheckstyle.skip=true -DskipJasmineTests=true \
 && tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}" \
 && rm -rf "${OPENCAST_SRC}" /tmp/* /var/lib/apt/lists/* ~/.m2 ~/.npm ~/.node-gyp /usr/lib/node_modules

FROM quay.io/mtneug/synfig-core AS synfig

FROM image-registry.openshift-image-registry.svc:5000/opencast-build/opencast-base

LABEL maintainer="UGent Multimedia <multimedia@ugent.be>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="8.x" \
      org.label-schema.name="opencast-allinone" \
      org.label-schema.description="Docker image for the Opencast allinone distribution" \
      org.label-schema.usage="https://github.com/mm-dict/opencast-docker/blob/5.2/README.md" \
      org.label-schema.url="http://www.opencast.org/" \
      org.label-schema.vcs-url="https://github.com/mm-dict/opencast-docker" \
      org.label-schema.vendor="Ghent University"

ENV LANG="C.UTF-8" \
    JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk" \
    PATH="$PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin" \
    \
    OPENCAST_VERSION="8.0" \
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

COPY --chown="${OPENCAST_USER}":0 --from=build "${OPENCAST_HOME}" "${OPENCAST_HOME}"
COPY --chown="${OPENCAST_USER}":0 assets/scripts "${OPENCAST_SCRIPTS}"
COPY --chown="${OPENCAST_USER}":0 assets/support "${OPENCAST_SUPPORT}"
COPY --chown="${OPENCAST_USER}":0 assets/etc/* "${OPENCAST_CONFIG}/"
COPY --chown="${OPENCAST_USER}":0 assets/docker-entrypoint.sh assets/docker-healthcheck.sh /

COPY --from=synfig /usr/local/bin/ETL* /usr/local/bin/
COPY --from=synfig /usr/local/bin/synfig* /usr/local/bin/
COPY --from=synfig /usr/local/etc/synfig_modules.cfg /usr/local/etc/synfig_modules.cfg
COPY --from=synfig /usr/local/lib/libsynfig.* /usr/local/lib/
COPY --from=synfig /usr/local/lib/synfig/modules /usr/local/lib/synfig/modules
COPY --from=synfig /usr/local/share/locale /usr/local/share/locale

RUN javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java"

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
