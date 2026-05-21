#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q flacon | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/flacon.svg
export DESKTOP=/usr/share/applications/flacon.desktop
export STARTUPWMCLASS=flacon
export DEPLOY_QT=1
export QT_DIR=qt6

# Deploy dependencies
quick-sharun /usr/bin/flacon \
  /usr/bin/faac \
  /usr/bin/flac \
  /usr/bin/lame \
  /usr/bin/mac \
  /usr/bin/alacenc \
  /usr/bin/oggenc \
  /usr/bin/opusenc \
  /usr/bin/sox \
  /usr/bin/wavpack \
  /usr/bin/wvunpack

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
