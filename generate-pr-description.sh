#!/usr/bin/env bash
# ------------------------------------------------------------------
# [Kiril Reznik] PR Description Generator
# ------------------------------------------------------------------

# Create a temporary file to store the filtered commit messages
temp_file=$(mktemp)

# Get the current git user's name and email
git_user=$(git config user.name)
git_email=$(git config user.email)

# Find the commit where the current branch diverged from master
diverged_commit=$(git merge-base HEAD master)

# Get the commit messages since the current branch diverged from master
# Filter for commit messages by the current git user
commit_messages=$(git log --pretty=format:"%s" --author="$git_user <$git_email>" $diverged_commit..HEAD)

# DEBUG
# echo "START commit_messages"
# echo "$commit_messages"
# echo "END commit_messages"
# echo

echo "$commit_messages" | while read -r line; do
  # Skip merge commits
  if [[ "$line" == Merge* ]]; then
    continue
  fi

  # Extract the prefix and the message from each line of the commit history
  prefix="${line%%:*}"
  message="${line#*: }"

  # Split the message into a task and the remaining details
  task="${message%% - *}"
  details="${message#* - }"

  # DEBUG
  # echo
  # echo "prefix: $prefix"
  # echo "task: $task"
  # echo "details: $details"
  # echo

  # If task is the same as details, reassign the commit into the "chore" group, under the "other" task
  if [[ "$task" == "$details" ]]; then
    prefix="CHORE"
    task="other"
  fi

  # Split the details by '-' and store the pieces into the 'split_details' array
  IFS='-' read -ra split_details <<<"$details"

  # Loop through each piece in the 'split_details' array
  for detail in "${split_details[@]}"; do
    # Remove leading and trailing whitespace from each detail
    trimmed_detail="${detail#"${detail%%[![:space:]]*}"}"
    trimmed_detail="${trimmed_detail%"${trimmed_detail##*[![:space:]]}"}"

    # DEBUG
    # echo
    # echo "trimmed detail: $trimmed_detail"
    # echo

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

  # Print the details of the commit message as a list item
  echo "- ${line#* - }"
done

# Delete the temporary file
rm "$temp_file"
