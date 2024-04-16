#!/bin/sh
################################################################################
# This script packages the results of Godot's export process into artifacts
# suitable for uploading to GitHub and itch.io.
#
# Most of Godot's export presets produce two or more files, so this script
# combines them into a zip file. Some exports only produce a single file, so
# those are left alone.

# Calculate the version string from project.godot, trimming off any suffix
# such as '-steam'
version=$(grep "config/version=" project/project.godot | awk -F "[\"-]" '{print $2}')
echo "version=$version"

################################################################################
# Package the html5 release

html5_export_path="project/export/html5"
html5_zip_filename="$html5_export_path/turbofat-html5-v$version.zip"

# Delete the existing html5 zip file
if [ -f "$html5_zip_filename" ]; then
  echo "Deleting $html5_zip_filename"
  rm "$html5_zip_filename"
fi

# Assemble the html5 zip file
echo "Packaging $html5_zip_filename"
zip "$html5_zip_filename" "$html5_export_path/*" -x "*.zip" "$html5_export_path/.*" "*.import" -j
