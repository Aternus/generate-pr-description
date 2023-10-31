#!/usr/bin/env bats

setup() {
    # Setup a temporary git repository for testing
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    git init -b main
    git config user.name "Test User"
    git config user.email "test@example.com"
    git commit --allow-empty -m "Initial commit"

    # Create a new branch for the test
    test_branch="test_branch_$(date +%s)"
    git checkout -b "$test_branch"
}

teardown() {
    # Cleanup the temporary directory
    rm -rf "$temp_dir"
}

echo_block() {
    local terminal_width=$(tput cols)
    local width=$(($terminal_width - 4))
    local title=" $1 "
    local content="$2"

    local title_length=${#title}
    local padding=$((($width - $title_length) / 2))

    # Create the '=' chars for the left padding
    local left_padding=$(printf '=%.0s' $(seq 1 $padding))

    # Create the '=' chars for the right padding, adjust for odd terminal widths
    local right_padding=$(printf '=%.0s' $(seq 1 $(($width - $title_length - ${#left_padding}))))

    # Create bottom line
    local bottom_line=$(printf '=%.0s' $(seq 1 $width))

    echo "${left_padding}${title}${right_padding}"
    echo "${content}"
    echo "${bottom_line}"
}

debug_output() {
    local actual="$1"
    local expected="$2"

    echo_block "ACTUAL OUTPUT" "$actual"
    echo_block "EXPECTED OUTPUT" "$expected"
}
