#!/bin/bash
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
RESULT=$(grep -R -n "^func.*):$" --include="*.gd" project/src)
if [ -n "$RESULT" ]
then
  echo ""
  echo "Functions missing return type:"
  echo "$RESULT"
fi

# long lines
RESULT=""
# cannot split a string literal across multiple lines in bash; must use a variable
REGEX="\(^.\{120,\}$"
REGEX+="\|^"$'\t'"{1}.\{116,\}$"
REGEX+="\|^"$'\t'"{2}.\{112,\}$"
REGEX+="\|^"$'\t'"{3}.\{108,\}$"
REGEX+="\|^"$'\t'"{4}.\{104,\}$"
REGEX+="\|^"$'\t'"{5}.\{100,\}$\)"
RESULT="${RESULT}$(grep -R -n "$REGEX" --include="*.gd" project/src)"
if [ -n "$RESULT" ]
then
  echo ""
  echo "Long lines:"
  echo "$RESULT"
fi

# whitespace at the start of a line. includes a list of whitelisted places where leading whitespace is acceptable
RESULT=$(grep -R -n "^\s* [^\s]" --include="*.gd" project/src \
  | grep -v "test-piece-kicks-t.gd.*doesn't it look like a rose?")
if [ -n "$RESULT" ]
then
  echo ""
  echo "Whitespace at the start of a line:"
  echo "$RESULT"
fi

# whitespace at the end of a line
RESULT=$(grep -R -n "\S\s\s*$" --include="*.gd" --include="*.chat" project/src project/assets)
if [ -n "$RESULT" ]
then
  echo ""
  echo "Whitespace at the end of a line:"
  echo "$RESULT"
  if [ "$CLEAN" ]
  then
    # remove whitespace at the end of lines
    find project/src project/assets \( -name "*.gd" -o -name "*.chat" \) -exec sed -i "s/\(\S\)\s\s*$/\1/g" {} +
    echo "...Whitespace removed."
  fi
fi

# comments with incorrect whitespace
REGEX="\(^##"$'\t'"\|## "$'\t\t\t'"\)"
RESULT=$(grep -R -n "$REGEX" --include="*.gd" project/src)
if [ -n "$RESULT" ]
then
  echo ""
  echo "Comments with incorrect whitespace:"
  echo "$RESULT"
fi

# fields/variables missing type hint. includes a list of whitelisted type hint omissions
RESULT=$(grep -R -n "var [^:]* = \|const [^:]* = " --include="*.gd" project/src \
  | grep -v " = parse_json(" \
  | grep -v "career-data\\.gd.*var chat_tree = ChatLibrary.chat" \
  | grep -v "dna-loader\\.gd.*var property_value =" \
  | grep -v "dna-loader\\.gd.*var shader_value =" \
  | grep -v "population\\.gd.*var creature_def =" \
  | grep -v "squish-fx\\.gd.*var _piece_manager =" \
  | grep -v "tracery\\.gd.*var selected_rule = match_name" \
  | grep -v "utils\\.gd.*var tmp = arr\[i\]" \
  )
if [ -n "$RESULT" ]
then
  echo ""
  echo "Fields/variables missing type hint:"
  echo "$RESULT"
fi

# functions missing type hint
RESULT=$(grep -R -n "func [a-zA-Z0-9_]*([a-zA-Z0-9_]\+[,)]" --include="*.gd" project/src \
  | grep -v "critter-manager\\.gd.*func get_critter_cells(critter_type)" \
  | grep -v "current-level\\.gd.*func has_customer(customer_obj)" \
  | grep -v "current-level\\.gd.*func _customers_match(customer1, customer2)" \
  | grep -v "level-triggers\\.gd.*func has_effect(effect_type)" \
  | grep -v "rule-parser\\.gd.*func default(new_default)" \
  | grep -v "rule-parser\\.gd.*func implied(new_implied)" \
  | grep -v "rule-parser\\.gd.*func implied(new_implied)" \
  | grep -v "state\\.gd.*func enter(_host" \
  | grep -v "state\\.gd.*func exit(_host" \
  | grep -v "state\\.gd.*func update(_host" \
  | grep -v "utils\\.gd.*func print_json(value)" \
  )
if [ -n "$RESULT" ]
then
  echo ""
  echo "Functions missing type hint:"
  echo "$RESULT"
fi

# temporary files
RESULT=$(find project -name "*.TMP" -o -name "*.gd~" -o -name "*.tmp")
if [ -n "$RESULT" ]
then
  echo ""
  echo "Temporary files:"
  echo "$RESULT"
  if [ "$CLEAN" ]
  then
    # remove temporary files
    find project \( -name "*.TMP" -o -name "*.gd~" -o -name "*.tmp" \) -exec rm {} +
    echo "...Temporary files deleted."
  fi
fi

# filenames with bad capitalization
RESULT=$(find project/src -name "[A-Z]*.gd" -o -name "[a-z]*.tscn")
if [ -n "$RESULT" ]
then
  echo ""
  echo "Filenames with bad capitalization:"
  echo "$RESULT"
fi

# project settings which are enabled temporarily, but shouldn't be pushed
RESULT=
RESULT=${RESULT}"Ê"$(grep "emulate_touch_from_mouse=true" project/project.godot)
RESULT=${RESULT}"Ê"$(grep "^window/size/test_width=" project/project.godot)
RESULT=${RESULT}"Ê"$(grep "^window/size/test_height=" project/project.godot)
RESULT=$(echo "${RESULT}" |
  sed 's/ÊÊÊ*/Ê/g' | # remove consecutive newline placeholders
  sed 's/^Ê\(.*\)$/\1/g' | # remove trailing newline placeholders
  sed 's/^\(.*\)Ê$/\1/g' | # remove following newline placeholders
  sed 's/Ê/\n/g') # convert newline placeholders to newlines
if [ -n "$RESULT" ]
then
  echo ""
  echo "Temporary project settings:"
  echo "$RESULT"
  if [ "$CLEAN" ]
  then
    # unset project settings
    sed -i "/emulate_touch_from_mouse=true/d" project/project.godot
    sed -i "/^window\/size\/test_width=/d" project/project.godot
    sed -i "/^window\/size\/test_height=/d" project/project.godot
    echo "...Temporary settings reverted."
  fi
fi

# enabled creature tool scripts; these should be disabled before merging
RESULT=$(grep -lR "^tool #uncomment to view creature in editor" project/src/main/world/creature)
if [ -n "$RESULT" ]
then
  echo ""
  echo "Enabled creature tool scripts:"
  echo "$RESULT"
  if [ "$CLEAN" ]
  then
    # disable creature tool scripts
    ./edit-creature.sh off
    echo "...Scripts disabled."
  fi
fi

# ViewportTexture is assigned; this causes an error because of Godot #27790
# (https://github.com/godotengine/godot/issues/27790)
RESULT=$(grep "texture = SubResource" project/src/main/world/creature/ViewportCreatureOutline.tscn)
if [ -n "$RESULT" ]
then
  echo ""
  echo "ViewportTexture is assigned:"
  echo "$RESULT"
fi

# print statements that got left in by mistake
RESULT=$(git diff main | grep print\()
RESULT=${RESULT}"Ê"$(git diff main | grep print_debug\()
RESULT=$(echo "${RESULT}" |
  sed 's/ÊÊÊ*/Ê/g' | # remove consecutive newline placeholders
  sed 's/^Ê\(.*\)$/\1/g' | # remove trailing newline placeholders
  sed 's/^\(.*\)Ê$/\1/g' | # remove following newline placeholders
  sed 's/Ê/\n/g') # convert newline placeholders to newlines
if [ -n "$RESULT" ]
then
  echo ""
  echo "Print statements:"
  echo "$RESULT"
fi

# non-ascii characters in chat files
RESULT=$(grep -R -n "[…‘’“”]" --include="*.chat" project/assets)
if [ -n "$RESULT" ]
then
  echo ""
  echo "Non-ascii characters in chat files:"
  echo "$RESULT"
  if [ "$CLEAN" ]
  then
    # replace non-ascii characters with ascii replacements
    find project/assets -name "*.chat" -exec sed -i "s/[…]/.../g" {} +
    find project/assets -name "*.chat" -exec sed -i "s/[‘’]/\'/g" {} +
    find project/assets -name "*.chat" -exec sed -i "s/[“”]/\"/g" {} +
    echo "...Non-ascii characters replaced."
  fi
fi

# redundant 'range(0, x)' call
RESULT=$(grep -R -n "[^_a-z]range(0," --include="*.gd" project/src)
if [ -n "$RESULT" ]
then
  echo ""
  echo "Redundant 'range(0, x)':"
  echo "$RESULT"
fi

# node names with spaces
RESULT=$(grep -R -n "node name=\"[^\"]* [^\"]*\"" --include="*.tscn" project/src)
if [ -n "$RESULT" ]
then
  echo ""
  echo "Node names with spaces:"
  echo "$RESULT"
fi
