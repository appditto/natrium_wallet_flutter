#!/bin/bash
#
# Based on:

# https://gist.github.com/stefanbuck/ce788fee19ab6eb0b4447a85fc99f447
#
# Uploads our android release APK to a corresponding release on github releases page
#

source ./ci/get_version.sh
VERSION=$(get_version)

# Define variables.
GH_TAGS="$GH_REPO/releases/tags/$VERSION"
GH_PUBLISH="$GH_REPO/releases"
WGET_ARGS="--content-disposition --auth-no-challenge --no-cookie"
CURL_ARGS="-LJO#"
filename=./build/app/outputs/apk/release/app-release.apk
GITHUB_OAUTH_BASIC="${GITHUB_API_TOKEN}:x-oauth-basic"

AUTH="Authorization: token $GITHUB_API_TOKEN"

# Validate token.
curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

# Read asset tags.
response=$(curl -u "$GITHUB_OAUTH_BASIC" -sH "$AUTH" $GH_TAGS)

# Get ID of the asset based on given filename.
eval $(echo "$response" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
[ "$id" ] || {
  echo "Error: Failed to get release id for tag: $VERSION";
  echo "$response" awk 'length($0)<100' >&2;
  exit 1;
}
# Upload asset
echo "Uploading asset... $localAssetPath" >&2

# Construct url
GH_ASSET="https://uploads.github.com/repos/$GH_OWNER/$GH_REPO_NAME/releases/$id/assets?name=natrium_${VERSION}.apk"

curl -u "$GITHUB_OAUTH_BASIC" --data-binary @"$filename" -H "$AUTH" -H "Content-Type: application/octet-stream" $GH_ASSET