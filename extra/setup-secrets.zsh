#!/bin/zsh

# Path variables
SECRETS_FILE="$HOME/.secrets.zsh"
DOTFILES_GITIGNORE="$HOME/dotfiles/.gitignore"
ZSHRC="$HOME/.zshrc"

# 1. Create secrets file if missing
if [ ! -f "$SECRETS_FILE" ]; then
  echo "# Add your secrets as export VAR=VALUE" > "$SECRETS_FILE"
  chmod 600 "$SECRETS_FILE"
  echo "Created $SECRETS_FILE"
fi

# 2. Ensure .secrets.zsh is in .gitignore
if [ -f "$DOTFILES_GITIGNORE" ]; then
  if ! grep -qxF '.secrets.zsh' "$DOTFILES_GITIGNORE"; then
    echo '.secrets.zsh' >> "$DOTFILES_GITIGNORE"
    echo "Added .secrets.zsh to $DOTFILES_GITIGNORE"
  fi
fi

# 3. Add sourcing to .zshrc if not present
SOURCE_LINE='if [ -f "$HOME/.secrets.zsh" ]; then source "$HOME/.secrets.zsh"; fi'
if ! grep -qxF "$SOURCE_LINE" "$ZSHRC"; then
  echo "$SOURCE_LINE" >> "$ZSHRC"
  echo "Updated $ZSHRC to source secrets"
fi

echo "Secrets integration automated. Add your secrets to $SECRETS_FILE."
