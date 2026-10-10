#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake         \
    faac          \
    kvantum       \
    lxqt-qtplugin \
    mac           \
    opus-tools    \
    qt6-tools     \
    qt6ct         \
    sox           \
    taglib        \
    uchardet      \
    vorbis-tools  \
    wavpack       \
    yaml-cpp

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini opus-mini

# Comment this out if you need an AUR package
#make-aur-package alacenc
#if [ "$ARCH" = "x86_64" ]; then
#    make-aur-package ttaenc
#fi
#make-aur-package flacon

echo "Building alacenc..."
echo "---------------------------------------------------------------"
REPO="https://github.com/flacon/alacenc"
git clone --depth 1 "$REPO" ./alacenc
cmake -B build-alacenc -S ./alacenc -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build-alacenc -j$(nproc)
cmake --install build-alacenc

if [ "$ARCH" = "x86_64" ]; then
    echo "Building ttaenc..."
    echo "---------------------------------------------------------------"
    wget http://downloads.sourceforge.net/tta/ttaenc-3.4.1-src.tgz
    tar -xvf ttaenc-3.4.1-src.tgz && rm ./*.tgz
    cd ./ttaenc-3.4.1-src
    make -j$(nproc)
    mv -v ./ttaenc /usr/bin/ttaenc
    cd ../
fi

echo "Building stable version of Flacon..."
echo "---------------------------------------------------------------"
REPO="https://github.com/flacon/flacon"
VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//; s/^v//')"
git clone --depth 1 "$REPO" ./flacon
echo "$VERSION" > ~/version

export LANG=C.UTF-8
export LC_ALL=C.UTF-8
cmake -B build -S ./flacon -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DUSE_QT5=OFF
cmake --build build -j$(nproc)
cmake --install build
