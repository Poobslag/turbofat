#!/bin/sh
################################################################################
# This script generates our export_presets.cfg.template file from the
# export_presets.cfg file. It sanitizes version numbers and sensitive properties
# which cannot be kept in version control.
#
# After editing the export presets in the Godot editor, this script should be
# run to share the changes with other developers.

# Extract Turbo Fat version from project.godot
version=$(grep "^config\/version=\".*\"" project/project.godot | cut -d "\"" -f 2)

# Load sensitive information from secrets files
. secrets/android.properties

echo "version=$version"

# Update export presets
cp project/export_presets.cfg project/export_presets.cfg.template
sed -i "s/$version/##VERSION##/g" project/export_presets.cfg.template
sed -i "s/$ANDROID_KEYSTORE_RELEASE_PASSWORD/##ANDROID_KEYSTORE_RELEASE_PASSWORD##/g" project/export_presets.cfg.template
echo "Updated export_presets.cfg.template"
