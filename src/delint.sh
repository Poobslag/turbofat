#!/bin/sh
# analyzes code for stylistic errors, printing them to the console

grep -R -n "^func.*):$" .
