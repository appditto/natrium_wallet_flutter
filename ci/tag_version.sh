#!/bin/bash

source ./ci/get_version.sh

VERSION=$(get_version)
GITHUB_OAUTH_BASIC="${GITHUB_API_TOKEN}:x-oauth-basic"
AUTH="Authorization: token $GITHUB_API_TOKEN"
GH_PUBLISH="$GH_REPO/releases"

# See if TAG exists

#export GIT_DIR=./.git
#if git rev-parse $VERSION >/dev/null 2>&1
#then
#    echo "Tag already exists"
#    exit 0
#fi
#echo "Tag not found, creating..."
#git tag -d $VERSION
#git tag $VERSION HEAD
#git push origin :$VERSION
#git push origin $VERSION
#if [ $? -ne 0 ]
#then
#    echo "Fatal, failed to push tag $VERSION"
#    exit 1
#fi

pubresponse=$(curl -u "$GITHUB_OAUTH_BASIC" -sH "$AUTH" --data '{"tag_name":"'"$VERSION"'", "name":"Natrium '"${VERSION}"'", "draft":false, "prerelease":false}' $GH_PUBLISH)
if [[ "$pubresponse" == *"already_exists"* ]]; then
  echo "Tag already exists, skipping"
   exit 0
elif [[ "$pubresponse" == *"Validation Failed"* ]]; then
  echo "Error! ${pubresponse}"
  exit 1
fi
echo "Release created"
exit 0
