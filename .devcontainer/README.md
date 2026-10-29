# Dotfiles Devcontainer

## Devcontainer CLI

- Install the Devcontainer CLI

```sh
npm install -g @devcontainers/cli
```

- Run this command in the project folder

```sh
devcontainer up --workspace-folder .
```

- Enter the shell of the created devcontainer

```sh
devcontainer exec --workspace-folder . zsh
```
