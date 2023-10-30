#!/usr/bin/env bats

TEST_DIR=$(dirname "$BATS_TEST_FILENAME")
SCRIPT_PATH="$TEST_DIR/../generate-pr-description.sh"

load "test-setup.bats"

@test "Check basic commit messages parsing" {
    git commit --allow-empty -m "PREFIX: task - detail 1 - detail 2 - detail 3"
    git commit --allow-empty -m "PREFIX: another task -     detail with whitespace around it "
    git commit --allow-empty -m "FEAT: something awesome - changed another thingy"
    git commit --allow-empty -m "- added a detail - then added another detail - but forgot to add prefix and task!"
    git commit --allow-empty -m "CHORE: added just the prefix and the task"
    git commit --allow-empty -m "- forgot to add the prefix and the task"
    git commit --allow-empty -m "did something quick via GitHub UI"
    git commit --allow-empty -m "FIX: another thingy - fixed an edge case that we missed last time"
    git commit --allow-empty -m "FEAT: something awesome - created the skeleton - created the tests"
    git commit --allow-empty -m "Merge branch 'master' into new-feature"

    run source $SCRIPT_PATH

    expected_output="# Changelog

## CHORE: added just the prefix and the task

## CHORE: other
- added a detail
- but forgot to add prefix and task!
- did something quick via GitHub UI
- forgot to add the prefix and the task
- then added another detail

## FEAT: something awesome
- created the skeleton
- created the tests

## FIX: another thingy
- fixed an edge case that we missed last time"

    debug_output "$output" "$expected_output"

    [[ "$output" == "$expected_output" ]]
}
