#!/usr/bin/env bash
# ------------------------------------------------------------------
# [Kiril Reznik] Helpers
# ------------------------------------------------------------------

debug_line() {
  local title="$1"
  local line="$2"
  echo "debug:: $title:: $line"
}

debug_block() {
  local title="$1"
  local block="$2"
  echo "========================================"
  echo "debug:: $title"
  echo "$block"
  echo "========================================"
}

trim() {
  local input="$1"
  trimmed_input=$(echo "$input" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  echo $trimmed_input
}
