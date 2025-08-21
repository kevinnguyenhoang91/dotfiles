# SHELL SCRIPT Style Guide

## Google Shell Script Style Guide Summary

- **File Extension**: Use `.sh` for shell scripts.

- **Shebang**: Use `#!/bin/bash` for Bash scripts.

- **Indentation**: Use 2 spaces per indentation level. No tabs.

- **Line Length**: Limit lines to 80 characters.

- **Naming**:
  - File names: Lowercase, words separated by hyphens (`my-script.sh`).
  - Variable names: Lowercase with underscores (`my_var`).
  - Constants: All uppercase with underscores (`MY_CONST`).
  - Functions: Lowercase with underscores (`my_function`).

- **Quoting**: Always quote variables: `"$var"`.

- **Command Substitution**: Use `$(...)` instead of backticks.

- **Comments**: Use `#` for comments. Place a space after `#`.

- **Functions**:

  ```bash
  my_function() {
    # function body
  }
  ```

- **Error Handling**: Use `set -e` and `set -u` at the top for safer scripts.

- **Readability**: Use blank lines to separate logical sections.

- **Pipelines**: Avoid unnecessary pipelines; prefer simple commands.

- **Exit Codes**: Use explicit `exit` codes.

For full details, see: [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
