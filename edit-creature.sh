#!/bin/sh
################################################################################
# This script toggles the 'tool' keyword for our creature scripts as a
# workaround for Godot #40000
# (https://github.com/godotengine/godot/issues/40000)
#
# Usage:
#   edit-creature.sh on: Enable creature editing in the editor. This causes
#     errors in the Godot console.
#   edit-creature.sh off: Disable creature editing in the editor. This fixes the
#     errors in the Godot console.

tool_line='tool #uncomment to view creature in editor'

if [ "$1" = "on" ]
then
  # uncomment 'tool' lines to allow editing
  grep -lRZE "$tool_line" project/src/main/world/creature | xargs -0 -l sed -i "s/^#$tool_line/$tool_line/g"
elif [ "$1" = "off" ]
then
  # comment out 'tool' lines to fix errors
  grep -lRZE "$tool_line" project/src/main/world/creature | xargs -0 -l sed -i "s/^$tool_line/#$tool_line/g"
else
  echo "Usage:"
  echo "  $0 on: Enable creature editing"
  echo "  $0 off: Disable creature editing"
fi
