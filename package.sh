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
# Package the windows release

win_export_path="project/export/windows-steam"
win_zip_filename="$win_export_path/turbofat-win-v$version.zip"

# Delete the existing windows zip file
if [ -f "$win_zip_filename" ]; then
  echo "Deleting $win_zip_filename"
  rm "$win_zip_filename"
fi

# Assemble the windows zip file
echo "Packaging $win_zip_filename"
zip "$win_zip_filename" "$win_export_path/turbofat-win-v$version.*" "$win_export_path/*.dll" -x "*.zip" -j

################################################################################
# Package the linux release

linux_export_path="project/export/linux-x11-steam"
linux_zip_filename="$linux_export_path/turbofat-linux-v$version.zip"

# Delete the existing linux zip file
if [ -f "$linux_zip_filename" ]; then
  echo "Deleting $linux_zip_filename"
  rm "$linux_zip_filename"
fi

# Assemble the linux zip file
echo "Packaging $linux_zip_filename"
zip "$linux_zip_filename" "$linux_export_path/turbofat-linux-v$version.*" "$linux_export_path/*.so" -x "*.zip" -j

# Enable the +x flag
bin/zip_exec/zip_exec.exe "$linux_zip_filename" turbofat-linux-v$version.x86_64
