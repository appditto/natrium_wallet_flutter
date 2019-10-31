#!/bin/bash

source ./ci/get_version.sh

VERSION=$(get_version)

# See if TAG exists

export GIT_DIR=./.git
#if git rev-parse $VERSION >/dev/null 2>&1
#then
#    echo "Tag already exists"
#    exit 0
#fi
#echo "Tag not found, creating..."
git tag -d $VERSION
git tag $VERSION HEAD
git push origin :$VERSION
git push origin $VERSION
if [ $? -ne 0 ]
then
    echo "Fatal, failed to push tag $VERSION"
    exit 1
fi