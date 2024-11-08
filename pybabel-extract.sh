#!/bin/sh
################################################################################
# This script extracts messages from source files, generates a POT file, and
# updates the various PO files.

pybabel extract -F project/assets/main/locale/babelrc \
	--add-location=file \
	-k description \
	-k dialog_text \
	-k keybind_value \
	-k label_text \
	-k track_title \
	-k text \
	-k tr \
	-k window_title \
	-o project/assets/main/locale/messages.pot . \
  --msgid-bugs-address=https://github.com/Poobslag/turbofat/ \
  --project="Turbo Fat" \
  --version=0.9000 \
  --copyright-holder="Poobslag"

# temporarily replace 'needs-review' flags with 'fuzzy' so that msgmerge will preserve them
sed -i 's/#, needs-review/#, fuzzy/g' project/assets/main/locale/es.po

msgmerge --update --backup=none -N project/assets/main/locale/es.po project/assets/main/locale/messages.pot
sed -i 's/#, fuzzy/#, needs-review/g' project/assets/main/locale/es.po

msgmerge --update --backup=none -N project/assets/main/locale/en.po project/assets/main/locale/messages.pot
