#!/usr/bin/env bash
# ------------------------------------------------------------------
# [Kiril Reznik] Helpers
# ------------------------------------------------------------------

IS_DEBUG=false

debug_line() {
  local title="$1"
  local line="$2"
  if [ "$IS_DEBUG" = true ]; then
    echo "debug:: $title:: $line"
  fi
}

debug_block() {
  local title="$1"
  local block="$2"
  if [ "$IS_DEBUG" = true ]; then
    echo "========================================"
    echo "debug:: $title"
    echo "$block"
    echo "========================================"
  fi
}

trim() {
  local input="$1"
  local trimmed_input=$(echo "$input" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  echo "$trimmed_input"
}
