#!/bin/sh
################################################################################
# Analyzes code and assets for stylistic errors, correcting them or printing
# them to the console
#
# Usage:
#   delint.sh:
#     Analyze code for stylistic errors, printing them to the console
#   delint.sh -c, delint.sh --clean:
#     Correct simple errors which can be automatically corrected

# parse arguments
CLEAN=
if [ "$1" = "-c" ] || [ "$1" = "--clean" ]
then
  CLEAN=true
fi

# functions missing return type
grep -R -n "^func.*):$" --include="*.gd" project/src

# long lines
grep -R -n "^.\{120,\}$" --include="*.gd" project/src
grep -R -n "^	.\{116,\}$" --include="*.gd" project/src
grep -R -n "^		.\{112,\}$" --include="*.gd" project/src
grep -R -n "^			.\{108,\}$" --include="*.gd" project/src
grep -R -n "^				.\{104,\}$" --include="*.gd" project/src
grep -R -n "^					.\{100,\}$" --include="*.gd" project/src

# whitespace at the start of a line. includes a list of whitelisted places where leading whitespace is acceptable
grep -R -n "^\s* [^\s]" --include="*.gd" project/src \
  | grep -v "test-piece-kicks-t.gd.*doesn't it look like a rose?"

# fields/variables missing type hint. includes a list of whitelisted type hint omissions
grep -R -n "var [^:]* = " --include="*.gd" project/src \
  | grep -v " = parse_json(" \
  | grep -v "chat-event.gd.*var parsed_meta = json\.get.*" \
  | grep -v "level-settings.gd.*var new_value = old_value" \
  | grep -v "level-settings.gd.*var old_value = json\[old_key\]" \
  | grep -v "dna-loader.gd.*var property_value =" \
  | grep -v "dna-loader.gd.*var shader_value ="

# temporary files
find project/src -name "*.TMP"
find project/src -name "*.gd~"
if [ "$CLEAN" ]
then
  # remove temporary files
  find project/src -name "*.TMP" -exec rm {} +
  find project/src -name "*.gd~" -exec rm {} +
fi

# files with incorrect capitalization
find project/src -name "[A-Z]*.gd"
find project/src -name "[a-z]*.tscn"

# project settings which are enabled temporarily, but shouldn't be pushed
grep "emulate_touch_from_mouse=true" project/project.godot 
grep "window/vsync/use_vsync=false" project/project.godot
if [ "$CLEAN" ]
then
  # unset project settings
  sed -i "/emulate_touch_from_mouse=true/d" project/project.godot
  sed -i "/window\/vsync\/use_vsync=false/d" project/project.godot
fi

# enabled creature tool scripts; these should be disabled before merging
grep -lR "^tool #uncomment to view creature in editor" project/src/main/world/creature
if [ "$CLEAN" ]
then
  # disable creature tool scripts
  ./edit-creature.sh off
fi

# print statements that got left in by mistake
git diff master | grep print\(

# non-ascii characters in chat files
grep -R -n "[…’“”]" --include="*.chat" project/assets
if [ "$CLEAN" ]
then
  # replace non-ascii characters with ascii replacements
  find project/assets -name "*.chat" -exec sed -i "s/[…]/.../g" {} +
  find project/assets -name "*.chat" -exec sed -i "s/[’]/\'/g" {} +
  find project/assets -name "*.chat" -exec sed -i "s/[“”]/\"/g" {} +
fi
