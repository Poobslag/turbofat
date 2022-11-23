#!/bin/sh
pybabel extract -F project/assets/main/locale/babelrc \
	-k dialog_text \
	-k text \
	-k tr \
	-k window_title \
	-k song_title \
	-k description \
	-k keybind_value \
	-k label_text \
	-o project/assets/main/locale/messages.pot .
