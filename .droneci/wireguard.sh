#!/usr/bin/env bash

KERNEL_DIR="$HOME/sdm636" # Configure kernel directory here
USER_AGENT="WireGuard-AndroidROMBuild/0.3 ($(uname -a))"
WIREGUARD_URL="https://git.zx2c4.com/wireguard-linux-compat/snapshot/wireguard-linux-compat"

cd "${KERNEL_DIR}" || exit

while read -r distro package version _; do
	if [[ $distro == upstream && $package == linuxcompat ]]; then
		VERSION="$version"
		break
	fi
done < <(curl -A "${USER_AGENT}" -LSs --connect-timeout 30 https://build.wireguard.com/distros.txt)

if [ ! -f "wireguard-linux-compat-${VERSION}.tar.xz" ]; then
	aria2c "${WIREGUARD_URL}"-"${VERSION}".tar.xz
fi

if [ ! -d "${KERNEL_DIR}"/net/wireguard ]; then
	mkdir "${KERNEL_DIR}/net/wireguard"
	tar -C "${KERNEL_DIR}/net/wireguard" -xf wireguard-linux-compat-"${VERSION}".tar.xz --strip-components=2 "wireguard-linux-compat-${VERSION}/src"
	git add net/wireguard/*
	git commit :-s -m "Merge tag 'v${VERSION}' of ${WIREGUARD_URL}"
elif [ -d "${KERNEL_DIR}"/net/wireguard ]; then
	FILE="${KERNEL_DIR}""/net/wireguard/version.h"
	CURRENT_VERSION="$(awk 'NR==2' "${FILE}" | sed 's/[^0-9.]*//g' | sed -r 's/^\s*(.*\S)*\s*$/\1/;/^$/d')"
	if [ "${VERSION}" == "${CURRENT_VERSION}" ]; then
		echo "WireGuard is up-to-date!"
	else
		rm -rf "${KERNEL_DIR}""/net/wireguard"
		mkdir "${KERNEL_DIR}/net/wireguard"
		tar -C "${KERNEL_DIR}/net/wireguard" -xf wireguard-linux-compat-"${VERSION}".tar.xz --strip-components=2 "wireguard-linux-compat-${VERSION}/src"
		git add net/wireguard/*
		git commit :-s -m "Merge tag 'v${VERSION}' of ${WIREGUARD_URL}"
	fi

fi

rm -rf wireguard-linux-compat-"${VERSION}".tar.xz
