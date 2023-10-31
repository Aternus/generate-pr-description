#!/usr/bin/env bash
# ------------------------------------------------------------------
# [Kiril Reznik] Generate PR Description
# ------------------------------------------------------------------

FULL_FILE_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_PATH=$(dirname "$FULL_FILE_PATH")
SCRIPT_NAME=$(basename "$FULL_FILE_PATH")

source "${SCRIPT_PATH}/helpers.sh"

# -----------------------------------------------------------------

# Check if the current directory is inside a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: This script must be run inside a Git repository."
  exit 1
fi

# Create a temporary file to store the filtered commit messages
temp_file=$(mktemp)

# Get the current git user's name and email
git_user=$(git config user.name)
git_email=$(git config user.email)

# Check if the main branch is named "master" or "main"
if git show-ref --verify --quiet refs/heads/master; then
  main_branch="master"
elif git show-ref --verify --quiet refs/heads/main; then
  main_branch="main"
else
  echo "Error: Can't find main branch (master or main)."
  exit 1
fi

# Find the commit where the current branch diverged from the main branch
diverged_commit=$(git merge-base HEAD "$main_branch")

# Get the commit messages since the current branch diverged from master
# Filter for commit messages by the current git user
commit_messages=$(git log --pretty=format:"%s" --author="$git_user <$git_email>" "$diverged_commit"..HEAD)

output_to_file() {
  debug_line "writing to temp file" "$1"
  echo "$1" >>"$temp_file"
}

debug_block "Commit Messages" "$commit_messages"

echo "$commit_messages" | while read -r line; do
  # Skip merge commits
  if [[ "$line" =~ ^Merge ]]; then
    continue
  fi

  # case: PREFIX: task - detail - another detail
  if [[ "$line" =~ ^([^:]+):[[:space:]]*(.+) ]]; then
    prefix="${BASH_REMATCH[1]}"
    message="${BASH_REMATCH[2]}"

    debug_line "prefix" "$prefix"
    debug_line "message" "$message"
    if [[ "$message" =~ ^([^-]+)[[:space:]]+-[[:space:]]+(.*) ]]; then
      task="${BASH_REMATCH[1]}"
      details="${BASH_REMATCH[2]}"
      debug_line "> task" "$task"
      debug_line "> details" "$details"
      # Process details
      IFS='-' read -ra split_details <<<"$details"
      for detail in "${split_details[@]}"; do
        processed_detail=$(trim "$detail")
        if [[ "$processed_detail" != "" ]]; then
          output_to_file "$prefix: $task - $processed_detail"
        fi
      done
    else
      output_to_file "$prefix: $message"
    fi
  # case: - detail - another detail - updated package-name
  elif [[ "$line" =~ ^- ]]; then
    line=${line#- } # Strip the first '- ' from the line

    # While we can still find ' - ' in the line
    while [[ "$line" == *' - '* ]]; do
      detail="${line%% - *}" # Everything before the first ' - '
      processed_detail=$(trim "$detail")
      if [[ "$processed_detail" != "" ]]; then
        output_to_file "CHORE: other - $processed_detail"
      fi
      line="${line#* - }" # Everything after the first ' - '
    done

    # The remaining part of the line
    processed_detail=$(trim "$line")
    if [[ "$processed_detail" != "" ]]; then
      output_to_file "CHORE: other - $processed_detail"
    fi
  else
    processed_detail=$(trim "$line")
    output_to_file "CHORE: other - $processed_detail"
  fi
done

debug_block "Temp File" "$(cat "$temp_file")"

# -----------------------------------------------------------------

echo "# Changelog"
echo

# Sort the commit messages in the temporary file and remove duplicates
sort "$temp_file" | uniq | while read -r line; do
  # Combine the prefix and task into a new prefix
  combined_prefix="${line%% -*}"

  # If this prefix is different from the previous prefix, print it as a header
  if [[ "$combined_prefix" != "$previous_prefix" ]]; then
    # Print a newline before each header except the first one
    if [[ -n "$previous_prefix" ]]; then
      echo
    fi
    echo "## $combined_prefix"
    previous_prefix="$combined_prefix"
  fi

  # Only print the details if they are not the same as the task
  task="${line%% - *}"
  details="${line#* - }"
  if [[ "$task" != "$details" ]]; then
    # Print the details of the commit message as a list item
    echo "- ${line#* - }"
  fi
done

# Delete the temporary file
rm "$temp_file"
