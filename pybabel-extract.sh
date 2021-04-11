#!/bin/sh
pybabel extract -F project/assets/main/locale/babelrc \
	-k text \
	-k tr \
	-k song_title \
	-k description \
	-k keybind_value \
	-o project/assets/main/locale/messages.pot .
