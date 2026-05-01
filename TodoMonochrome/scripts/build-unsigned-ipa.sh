#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
IPA_PATH="${BUILD_DIR}/TodoMonochrome-unsigned.ipa"
ARCHIVE_PATH="${BUILD_DIR}/TodoMonochrome.xcarchive"

mkdir -p "${BUILD_DIR}"

echo "==> Archiving (unsigned) ..."
xcodebuild \
  -project "${ROOT_DIR}/TodoMonochrome.xcodeproj" \
  -scheme "TodoMonochrome" \
  -configuration "Release" \
  -sdk "iphoneos" \
  -destination "generic/platform=iOS" \
  -archivePath "${ARCHIVE_PATH}" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  DEVELOPMENT_TEAM="" \
  PROVISIONING_PROFILE_SPECIFIER="" \
  archive

APP_PATH="${ARCHIVE_PATH}/Products/Applications/TodoMonochrome.app"
if [[ ! -d "${APP_PATH}" ]]; then
  echo "Could not find built app at: ${APP_PATH}"
  exit 1
fi

echo "==> Packaging IPA ..."
TMP_DIR="$(mktemp -d)"
mkdir -p "${TMP_DIR}/Payload"
ditto "${APP_PATH}" "${TMP_DIR}/Payload/TodoMonochrome.app"

rm -f "${IPA_PATH}"
ditto -c -k --sequesterRsrc --keepParent "${TMP_DIR}/Payload" "${IPA_PATH}"
rm -rf "${TMP_DIR}"

echo "Wrote: ${IPA_PATH}"
