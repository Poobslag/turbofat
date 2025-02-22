#!/bin/sh
################################################################################
# This script generates our export_presets.cfg and project.godot files. It
# updates the version number and inserts sensitive properties which cannot be
# kept in version control.
#
# Before exporting the project, this script should be run to ensure the
# export_presets.cfg file is present and up to date with the latest project
# changes. Before releasing the project, this script should be run to update
# the version number.
#
# Usage:
#   generate-export-presets.sh: Update the export presets with a generated
#     version number.
#   generate-export-presets.sh [VERSION]: Update the export presets with the
#     specified version number.
#
# Further info is available in the Turbo Fat wiki:
# https://github.com/Poobslag/turbofat/wiki/release-process

if [ "$1" ]
then
  version="$1"
else
# Calculate version string
  yy=$(date +%Y)
  mmdd=$(date +%m%d)
  mmdd=$(echo "$mmdd" | sed 's/^0*//')
  version=$(((yy - 2024) * 2000 + mmdd - 1013))
  version=$(printf 1.%04d $version)
fi

echo "version=$version"

# Load sensitive information from secrets files
. secrets/android.properties

# Update export presets
cp project/export_presets.cfg.template project/export_presets.cfg
sed -i "s/##VERSION##/$version/g" project/export_presets.cfg
sed -i "s/##ANDROID_KEYSTORE_RELEASE_PASSWORD##/$ANDROID_KEYSTORE_RELEASE_PASSWORD/g" project/export_presets.cfg
echo "Updated export_presets.cfg"

# Update project.godot
sed -i "s/^config\/version=\".*\"$/config\/version=\"$version\"/g" project/project.godot
echo "Updated project.godot"
