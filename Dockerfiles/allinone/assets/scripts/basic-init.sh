#!/bin/bash

set -e

# Set arbitrary UID of container in /etc/passwd
opencast_init_configure_user() {
  grep -v ^${OPENCAST_USER} /etc/passwd > "/tmp/passwd"
  echo "${OPENCAST_USER}:x:$(id -u):0:Opencast User:${OPENCAST_HOME}:/bin/bash" >> /tmp/passwd
  cat /tmp/passwd >/etc/passwd
  rm /tmp/passwd
#  chown root /etc/passwd
}
