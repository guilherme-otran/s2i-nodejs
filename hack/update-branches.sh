#!/usr/bin/env bash

set -e

GIT_ROOT="$( git rev-parse --show-toplevel )"

if [ -z "$GIT_ROOT" ]; then
  echo 'Must be in a valid git repository.'
  exit 1
fi

cd "$GIT_ROOT"

echo 'Updating master...'
git checkout -q master
git fetch upstream
git rebase upstream/master

git reset --hard -q HEAD~

./hack/add-version.sh 4
./hack/add-version.sh 6

git add ./4 ./6
git commit -q -m 'Add support for Node.js 4 and 6'

echo 'Updating feature/zeromq...'
git checkout -q -B feature/zeromq
./hack/add-zeromq.sh
git add ./*/Dockerfile
git commit -m 'Add zeromq-devel package to image'

echo 'Updating feature/pdf...'
git checkout -q -B feature/pdf
./hack/add-pdf.sh
git add ./*/Dockerfile
git commit -m 'Add packages: GhostScript, Poppler, ImageMagick'

git checkout -q feature/zeromq

echo 'Updating feature/graphicsmagick...'
git checkout -q -B feature/graphicsmagick
./hack/add-graphicsmagick.sh
git add ./*/Dockerfile
git commit -m 'Add GraphicsMagick package to image'

git checkout -q master

echo

read -p 'Push (y/N)? ' -r
echo

case "$REPLY" in
  [yY]*)
    git push -fu origin master feature/zeromq feature/pdf feature/graphicsmagick
    ;;
  *)
    echo 'To push the branches yourself, run:'
    echo git push -fu origin master feature/zeromq feature/pdf feature/graphicsmagick
esac
