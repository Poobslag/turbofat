#!/bin/sh
################################################################################
# This script empties the /project/export directory.
#
# Running this script should never fix or break anything. Other scripts should
# still work if the /project/export directory contains old files.

rm project/export/*/*
