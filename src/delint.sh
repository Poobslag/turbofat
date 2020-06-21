#!/bin/sh
# analyzes code for stylistic errors, printing them to the console

# functions missing return type
grep -R -n "^func.*):$" --include="*.gd" .

# long lines
grep -R -n "^.\{120,\}$" --include="*.gd" .
grep -R -n "^	.\{116,\}$" --include="*.gd" .
grep -R -n "^		.\{112,\}$" --include="*.gd" .
grep -R -n "^			.\{108,\}$" --include="*.gd" .
grep -R -n "^				.\{104,\}$" --include="*.gd" .
grep -R -n "^					.\{100,\}$" --include="*.gd" .

# fields/variables missing type hint. includes a list of whitelisted type hint omissions
grep -R -n "var [^:]* = " --include="*.gd" . \
  | grep -v " = parse_json(" \
  | grep -v "chat-event.gd:73"

find -name *.TMP
find -name *.gd~

# project settings which are enabled temporarily, but shouldn't be pushed
grep "emulate_touch_from_mouse=true" ../project.godot 
