#!/bin/sh
pybabel extract -F project/assets/main/locale/babelrc \
	-k text \
	-k LineEdit/placeholder_text \
	-k tr \
	-o project/assets/main/locale/messages.pot .
