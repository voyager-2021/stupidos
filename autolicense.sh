#!/bin/bash

set -e

# License headers for each language type
C_HEADER='/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu'"'"'s nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */'

ASM_HEADER='; Bare-Metal License v1.0
; Copyright (c) 2025 voyager-2021
; This software is inspired by and includes code from chibicitiberiu'"'"'s nanobyte_os
;
; You may not use this software for commercial purposes or profit.
; See LICENSE file for full terms.'

MAKE_HEADER='# Bare-Metal License v1.0
# Copyright (c) 2025 voyager-2021
# This software is inspired by and includes code from chibicitiberiu'"'"'s nanobyte_os
#
# You may not use this software for commercial purposes or profit.
# See LICENSE file for full terms.'

print_action() {
  local action="$1"
  local file="$2"
  printf "  %-8s %s\n" "$action" "$file"
}

prepend_header() {
  local file="$1"
  local header="$2"
  local skip_check="$3"

  if [ "$skip_check" -ne 1 ] && grep -q "Bare-Metal License v1.0" "$file"; then
    print_action IGNORE "$file"
  else
    print_action LICENSE "$file"
    {
      echo "$header"
      echo
      cat "$file"
    } > "$file.tmp" && mv "$file.tmp" "$file"
  fi
}

export -f prepend_header
export -f print_action

# Run on C and header files
find src -type f \( -name '*.c' -o -name '*.h' \) \
  -exec bash -c 'prepend_header "$0" "$1" 0' {} "$C_HEADER" \;

# Run on assembly files
find src -type f \( -name '*.asm' -o -name '*.S' \) \
  -exec bash -c 'prepend_header "$0" "$1" 0' {} "$ASM_HEADER" \;

# Run on Makefiles inside src
find src -type f \( -name 'Makefile' -o -name '*.mk' \) \
  -exec bash -c 'prepend_header "$0" "$1" 0' {} "$MAKE_HEADER" \;

# Prepend to top-level Makefile
if [ -f Makefile ]; then
  bash -c 'prepend_header "$0" "$1" 0' "Makefile" "$MAKE_HEADER"
fi
