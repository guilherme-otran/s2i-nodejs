#!/usr/bin/env bash

set -e

GIT_ROOT="$( git rev-parse --show-toplevel )"

if [ -z "$GIT_ROOT" ]; then
  echo 'Must be in a valid git repository.'
  exit 2
fi

cd "$GIT_ROOT"

for DOCKERFILE in */Dockerfile; do
  VERSION="${DOCKERFILE%/Dockerfile}"
  TAGVERSION="${VERSION/./}"

  # shellcheck disable=SC1004,SC2016
  sed -e '/^# Drop the root user/i\
# Add label for ZeroMQ\
LABEL io.openshift.tags="builder,nodejs,nodejs'"$TAGVERSION"',zeromq"\
\
# Add additional packages for ZeroMQ\
RUN INSTALL_PKGS="zeromq-devel" && \\\
\    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \\\
\    rpm -V $INSTALL_PKGS && \\\
\    yum clean all -y\
\
' "$DOCKERFILE" >"${DOCKERFILE}.new"

  mv "${DOCKERFILE}.new" "$DOCKERFILE"
done
