#!/usr/bin/env bash
#
# backup
#
# Usage:
# sudo backup
#


rsync -avhPE \
  --exclude-from=${EXCLUDE} \
  ${SOURCE} \
  ${TARGET} \
