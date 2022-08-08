#!/bin/sh

# Build LottiePlayer.app

cd `dirname $0` # move current directory to /path/to/LottiePlayer/bin/
cd ..           # move current directory to /path/to/LottiePlayer/

COMMAND_NAME=`basename $0`

# Parameter for xcodebuild
CONFIGURATION="Release"
# ARCH="x86_64 arm64"
INSTALL_PATH="/Applications"

BUNDLE_ID="com.mnkd.LottiePlayer"
SCHEME="LottiePlayer"
DSTROOT="/tmp/${SCHEME}.dst"
DERIVED_DATA_PATH="/tmp/${SCHEME}.derivedData"
PROJECT_ROOT="LottiePlayer"
ZIP_NAME="LottiePlayer.zip"
PROJECT="${PROJECT_ROOT}.xcodeproj"
INFOPLIST_FILE="${PROJECT_ROOT}/Info.plist"
MINIMUM_SYSTEM_VERSION="10.15"

set -eu
set +x

# --------------------------------------------------
# Build Application Bundle
# --------------------------------------------------

# echo
# echo "-------------------------"
# echo "Update Info.plist"
# echo "-------------------------"
# echo
# echo "** Update LottiePlayer/Info.plist **"

# echo "=== Set :NSHumanReadableCopyright"
# COPYRIGHT_YEAR=`date +%Y`
# /usr/libexec/PlistBuddy -c \
#   "Set :NSHumanReadableCopyright Copyright © 2020 - ${COPYRIGHT_YEAR} Mitsuru Nakada. All rights reserved." \
#   "${INFOPLIST_FILE}"
# /usr/libexec/PlistBuddy -c "Print :NSHumanReadableCopyright" "${INFOPLIST_FILE}"

echo
echo "-------------------------"
echo "Build Application Bundle"
echo "-------------------------"
echo

# Clean the target
echo "<< clean >>"
echo
xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  DSTROOT="${DSTROOT}" \
  INSTALL_PATH="${INSTALL_PATH}" clean | ./Mint/bin/xcbeautify

# Workaround:
# fatal error: file '/tmp/LottiePlayer.dst/usr/local/include/XXXX.h' has been modified since the precompiled
# header '/path/to/PrecompiledHeaders/LottiePlayer-Bridging-Header-swift_xxxx.pch' was built
echo "rm -rf ${DERIVED_DATA_PATH}/Build/Intermediates.noindex/ArchiveIntermediates/${SCHEME}/PrecompiledHeaders"
rm -rf "${DERIVED_DATA_PATH}/Build/Intermediates.noindex/ArchiveIntermediates/${SCHEME}/PrecompiledHeaders"

# Build the target and install it into the target's installation directory in the distribution root (DSTROOT)
echo
echo "<< build >>"
echo
xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  DSTROOT="${DSTROOT}" \
  INSTALL_PATH="${INSTALL_PATH}" install | ./Mint/bin/xcbeautify

# Check whether build succeeded
if [ $? != 0 ]
then
  exit 1
fi

echo
echo "---------------------------------"
echo "Zip Application Bundle"
echo "---------------------------------"
/usr/bin/ditto -c -k --keepParent "${DSTROOT}/Applications/${SCHEME}.app" "${ZIP_NAME}"

echo
echo "---------------------------------"
echo "Clean-up Temporary Files"
echo "---------------------------------"
echo "rm -rf ${DERIVED_DATA_PATH}"
rm -rf "${DERIVED_DATA_PATH}"

echo "rm -rf ${DSTROOT}"
rm -rf "${DSTROOT}"

echo
echo "---------------------------------"
echo "Notarize App"
echo "---------------------------------"
echo "xcrun notarytool submit LottiePlayer.zip --wait --keychain-profile AC_ITEM"
xcrun notarytool submit LottiePlayer.zip --wait --keychain-profile "AC_ITEM"

echo "wait around 2 minutes"
date

echo
echo "*** DONE ***"
echo
