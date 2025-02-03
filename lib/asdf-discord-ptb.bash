#!/usr/bin/env bash
# shellcheck disable=SC1090

# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2025 Marko Kungla
# See the LICENSE file for full licensing details.

# This file is subject to the Apache License Version 2.0, as stated in the LICENSE file
# at the time of creation. Check Git history for further details.

# -----------------------------------------------------------------------------
# Script Information
# -----------------------------------------------------------------------------
# Description: Discord PTB plugin script
# Usage: ./asdf-discord-ptb.bash
# Author: Marko Kungla
# Created: 2025-02-02
# Dependencies:
# ScriptType: Source
# Notes:

# -----------------------------------------------------------------------------
# Example Usage
# -----------------------------------------------------------------------------
# ./asdf-discord-ptb.bash
#
# -----------------------------------------------------------------------------

set -euo pipefail

plugin_dir="${plugin_dir:-$HOME/.local}"

TOOL_NAME="discord-ptb"
DISCORD_API_URL="https://discordapp.com/api/ptb/updates?platform=linux"
VERSIONS_FILE="${plugin_dir}/local/versions.txt"

curl_opts=(-fsSL)

# ensure that versions.txt
touch "$VERSIONS_FILE"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

# Function to check if a version is valid semantic versioning (X.Y.Z)
is_valid_version() {
	local version="$1"
	[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# Function to check if a version exists in versions.txt
check_version_exists() {
	local version="$1"
	grep -Fxq "$version" "$VERSIONS_FILE"
}

get_latest_version() {

	response=$(curl "${curl_opts[@]}" "$DISCORD_API_URL")
	version=$(echo "$response" | jq -r '.name')

	# Validate if the extracted version is a valid semantic version
	if is_valid_version "$version"; then
		# Check if version is already in the file
		if ! check_version_exists "$version"; then
			# Append new version to the file
			echo "$version" >>"$VERSIONS_FILE"
		fi
	else
		echo "Error: Invalid version format received: $version" >&2
		exit 1
	fi
	echo "$version"
}

list_all_versions() {

	# Output all recorded versions
	cat "$VERSIONS_FILE"

	latest=$(get_latest_version)

	if ! grep -Fxq "$latest" "$VERSIONS_FILE"; then
		echo "$latest"
	fi
}

get_download_filename() {
	local version
	version="$1"
	echo "discord-ptb-$version.tar.gz"
}

download_release() {
	local version dl_filename
	version="$1"
	dl_filename="$2"
	dl_url="https://dl-ptb.discordapp.net/apps/linux/${version}/discord-ptb-${version}.tar.gz"

	echo "* Downloading Discord PTB release ${version}... ($dl_filename)"
	curl "${curl_opts[@]}" -o "${ASDF_DOWNLOAD_PATH}/${dl_filename}" -C - "$dl_url" || fail "Failed to download Discord PTB from $dl_url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3}"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "${install_path}/bin"
		cp -r "${ASDF_DOWNLOAD_PATH}"/* "$install_path"
		ln -s "${install_path}/discord-ptb" "${install_path}/bin/discord-ptb"
		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -r "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
