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
	-o project/assets/main/locale/messages.pot .

msgmerge --update --backup=none -N project/assets/main/locale/es.po project/assets/main/locale/messages.pot
msgmerge --update --backup=none -N project/assets/main/locale/en.po project/assets/main/locale/messages.pot
