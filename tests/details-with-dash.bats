#!/usr/bin/env bats

TEST_DIR=$(dirname "$BATS_TEST_FILENAME")
SCRIPT_PATH="$TEST_DIR/../generate-pr-description.sh"

load "test-setup.bats"

@test "Check parsing of details with dash" {
    git commit --allow-empty -m "- updated go-sdk-open-api - updated go-sdk-reports"

    run source $SCRIPT_PATH

    expected_output="# Changelog

## CHORE: other
- updated go-sdk-open-api
- updated go-sdk-reports"

    debug_output "$output" "$expected_output"

    [[ "$output" == "$expected_output" ]]
}
