#!/bin/sh
################################################################################
# This script generates our export_presets.cfg and project.godot files. It
# updates version numbers and sensitive properties which cannot be kept in
# version control.
#
# Further info is available in the Turbo Fat wiki:
# https://github.com/Poobslag/turbofat/wiki/release-process


# Calculate version string
yy=$(date +%Y)
mmdd=$(date +%m%d)
mmdd=$(echo "$mmdd" | sed 's/^0*//')
version=$(((yy - 2020) * 2000 + mmdd))
version=$(printf 0.%04d $version)
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
