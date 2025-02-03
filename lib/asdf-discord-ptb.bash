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

TOOL_NAME="discord-ptb"
DISCORD_API_URL="https://discordapp.com/api/ptb/updates?platform=linux"
VERSIONS_FILE="${plugin_dir}/local/versions.txt"

curl_opts=(-fsSL)
# NOTE: You might want to remove this if godot is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

get_latest_version() {
	# ensure that versions.txt
	touch $VERSIONS_FILE

	response=$(curl "${curl_opts[@]}" "$DISCORD_API_URL")
	version=$(echo "$response" | jq -r '.name')

	# Validate if the extracted version is a valid semantic version
	if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		# Check if version is already in the file
		if ! grep -Fxq "$version" "$VERSIONS_FILE"; then
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
	# ensure that versions.txt
	touch $VERSIONS_FILE

	# Output all recorded versions
	cat "$VERSIONS_FILE"

	latest=$(get_latest_version)

	if ! grep -Fxq "$latest" "$VERSIONS_FILE"; then
		echo "$latest"
	fi
}
