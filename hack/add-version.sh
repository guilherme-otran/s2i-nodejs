#!/usr/bin/env bash

set -e
shopt -s globstar nullglob

VERSION="$1"

if [ -z "$VERSION" ]; then
  echo "Usage:	$0 <version>"
  exit 1
fi

GIT_ROOT="$( git rev-parse --show-toplevel )"

if [ -z "$GIT_ROOT" ]; then
  echo 'Must be in a valid git repository.'
  exit 2
fi

cd "$GIT_ROOT"

rm -rf "$VERSION"

cp -a "0.10" "$VERSION"

rm "${VERSION}/Dockerfile.rhel7" "${VERSION}/contrib/etc/scl_enable"

sed \
  -e "s/0\.10/${VERSION}/g" \
  -e "s;yum install -y centos-release-scl;curl -sL https://rpm.nodesource.com/setup_${VERSION}.x | bash -;" \
  -e 's/"nodejs010/"nodejs/' \
  -e "s/,nodejs010/,nodejs${VERSION}/" \
  "${VERSION}/Dockerfile" >"${VERSION}/Dockerfile.new"

for FILETOFIX in "$VERSION"/{README.md,s2i/bin/usage,s2i/bin/assemble,test/run}; do
  sed \
    -e "s/0\.10/${VERSION}/g" \
    -e "s/010/${VERSION}/g" \
    "$FILETOFIX" >"${FILETOFIX}.new"
done

for NEWFILE in "$VERSION"/**/*.new; do
  cat "$NEWFILE" >"${NEWFILE/.new}"
  rm "$NEWFILE"
done
