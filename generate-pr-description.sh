#!/usr/bin/env bash
# ------------------------------------------------------------------
# [Kiril Reznik] Generate PR Description
# ------------------------------------------------------------------

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
main_branch=$(git rev-parse --abbrev-ref HEAD | grep -q "master" && echo "master" || echo "main")

# Find the commit where the current branch diverged from the main branch
diverged_commit=$(git merge-base HEAD "$main_branch")

# Get the commit messages since the current branch diverged from master
# Filter for commit messages by the current git user
commit_messages=$(git log --pretty=format:"%s" --author="$git_user <$git_email>" "$diverged_commit"..HEAD)

# DEBUG
#echo "START commit_messages"
#echo "$commit_messages"
#echo "END commit_messages"
#echo

echo "$commit_messages" | while read -r line; do
  # Skip merge commits
  if [[ "$line" == Merge* ]]; then
    continue
  fi

  # Check if the line starts with a hyphen or doesn't contain a ':'
  if [[ "$line" == -* || ! "$line" == *:* ]]; then
    # Split the message by '-' and store the pieces into the 'split_details' array
    IFS='-' read -ra split_details <<<"${line#- }"

    # Loop through each piece in the 'split_details' array
    for detail in "${split_details[@]}"; do
      # Remove leading and trailing whitespace from each detail
      trimmed_detail="${detail#"${detail%%[![:space:]]*}"}"
      trimmed_detail="${trimmed_detail%"${trimmed_detail##*[![:space:]]}"}"

      if [[ "$trimmed_detail" == "" ]]; then
        continue
      fi

      # Append the processed commit message to the temporary file
      echo "CHORE: other - $trimmed_detail" >>"$temp_file"
    done
    continue
  fi

  # Extract the prefix and the message from each line of the commit history
  prefix="${line%%:*}"
  message="${line#*: }"

  # Split the message into a task and the remaining details
  task="${message%% - *}"
  details="${message#* - }"

  # If task is the same as details (meaning no details were provided),
  # add the commit into its own category without further processing
  if [[ "$task" == "$details" ]]; then
    echo "$line" >>"$temp_file"
    continue
  fi

  # Split the details by '-' and store the pieces into the 'split_details' array
  IFS='-' read -ra split_details <<<"$details"

  # Loop through each piece in the 'split_details' array
  for detail in "${split_details[@]}"; do
    # Remove leading and trailing whitespace from each detail
    trimmed_detail="${detail#"${detail%%[![:space:]]*}"}"
    trimmed_detail="${trimmed_detail%"${trimmed_detail##*[![:space:]]}"}"

    if [[ "$trimmed_detail" == "" ]]; then
      continue
    fi

    # Append the processed commit message to the temporary file
    echo "$prefix: $task - $trimmed_detail" >>"$temp_file"
  done
done

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
