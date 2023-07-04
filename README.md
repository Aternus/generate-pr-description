# Generate Pull Request (PR) Description

**10x Devs: Automating PR Descriptions**

This repository hosts a Bash script that generates a pull request (PR)
description based on the commit history of a branch in a Git repository. The
script extracts commit messages, filters them by the current Git user, and
processes them to create a changelog-like PR description.

## Prerequisites

- Bash (Bourne Again SHell) should be installed on your system.

## Usage

1. Clone or download the repository.
2. Navigate to the repository's directory.

```bash
$ git clone https://github.com/Aternus/generate-pr-description.git
$ cd generate-pr-description
```

3. Make the Bash script executable.

```bash
$ chmod +x generate-pr-description.sh
```

4. Add the script to the `$PATH` environment variable to enable running it from
   any directory. This can be done by creating a symbolic link in a directory
   that is already in the `$PATH`.

```bash
$ ln -s "$PWD/generate-pr-description.sh" /usr/local/bin/generate-pr-description
```

Now you can run the script from any directory using its name.

```bash
$ generate-pr-description
```

## How it Works

This bash script generates a neatly formatted changelog from the commit history
of a Git repository, specifically targeting commits made by the user running the
script. The script will not work if run outside a Git repository or if
there's no master or main branch available.

Let's break down the working of the script:

1. **Check for Git repository**: The script first checks if the current
   directory is part of a Git repository.

2. **Temporary File**: The script creates a temporary file to store the filtered
   commit messages.

3. **Git User Information**: The script retrieves the name and email of the
   current Git user.

4. **Main Branch Check**: The script checks what is the primary branch of the
   repository.

5. **Diverged Commit**: The script determines the commit where the current
   branch diverged from the main branch.

6. **Commit Messages**: The script extracts all commit messages made by the
   current Git user after the divergence from the main branch.

7. **Processing Commit Messages**: The script then processes each commit message
   one by one. Merge commit messages are skipped.

8. **Generate Changelog**: The script generates a changelog by sorting and
   removing duplicates from the commit messages stored in the temporary file.
   The changelog groups commit messages by their prefixes and tasks, and prints
   them under their respective headers. Only details that are not the same as
   the task are printed as list items.

9. **Clean Up**: Finally, the script deletes the temporary file to clean up.

Please note that the script expects commit messages to follow a specific
format (like `prefix: task - details`). If your commit messages do not follow
this format, the script may not work as expected.

### Example

#### Input

Assume we have the following commit messages in the branch since it diverged
from the master:

```
- added a detail - then added another detail - but forgot to add prefix and task!
CHORE: added just the prefix and the task
- forgot to add the prefix and the task
did something quick via GitHub UI
FIX: another thingy - fixed an edge case that we missed last time
FEAT: something awesome - created the skeleton - created the tests
```

#### Output

When running the script, it will generate the following PR description:

```markdown
# Changelog

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
- fixed an edge case that we missed last time
```

## Contributing

Contributions to this repository are welcome. Feel free to open issues or submit
pull requests to suggest improvements, report bugs, or add new features.

For collaborations, please reach out
via [LinkedIn](https://www.linkedin.com/in/kirilreznik/).

## License

This project is licensed under the [MIT License](LICENSE).
