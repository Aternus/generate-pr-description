# Pull Request (PR) Description Generator

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
$ git clone https://github.com/Aternus/pull-request-description.git
$ cd pull-request-description
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

The script follows these steps:

1. It creates a temporary file to store the filtered commit messages.

2. The current Git user's name and email are retrieved.

3. The commit where the current branch diverged from the master branch is
   identified.

4. Commit messages since the branch divergence, filtered by the current Git
   user, are retrieved.

5. Each commit message is processed and categorized based on the prefix, task,
   and details.

6. If the task is the same as the details, the commit is assigned to the "CHORE"
   group under the "other" task.

7. The details are split by hyphens ('-') and processed.

8. Leading and trailing whitespace in each detail are removed.

9. The processed commit messages are appended to the temporary file.

10. The script generates a changelog-like PR description by sorting the commit
    messages and removing duplicates.

11. The commit messages are grouped by prefixes, and each group is printed as a
    header.

12. The details of each commit message are printed as a list item.

13. Finally, the temporary file is deleted.

## Example

### Input

Assume we have the following commit messages in the branch since it diverged
from the master:

```
- FEATURE: Added a new feature A.
- FIX: Fixed a critical bug in module B.
- FEATURE: Added another feature C.
- CHORE: other - Updated dependencies.
- FIX: Fixed an issue related to feature A.
```

### Output

When running the script, it will generate the following PR description:

```markdown
# Changelog

## FEATURE

- Added a new feature A.
- Added another feature C.

## FIX

- Fixed a critical bug in module B.
- Fixed an issue related to feature A.

## CHORE: other

- Updated dependencies.
```

## Contributing

Contributions to this repository are welcome. Feel free to open issues or submit
pull requests to suggest improvements, report bugs, or add new features.

For collaborations, please reach out
via [LinkedIn](https://www.linkedin.com/in/kirilreznik/).

## License

This project is licensed under the [MIT License](LICENSE).
