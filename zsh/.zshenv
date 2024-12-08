# Aliases
alias v='$EDITOR'
alias lg='lazygit'
alias ls='ls -G'
alias ll='ls -lG'
alias lsa='ls -lahG'

export GPG_TTY=$(tty)

# PATH
export PATH="${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:${PATH}"

# Secrets
[ -f ~/.secrets ] && source ~/.secrets

# Asdf
[[ -s "${HOME}/.asdf/asdf.sh" ]] && . ${HOME}/.asdf/asdf.sh
fpath=(${ASDF_DIR}/completions $fpath)

# GOLANG
export GOPATH="${HOME}/go"
export ASDF_GOLANG_MOD_VERSION_ENABLED=true
export PATH="${GOPATH}/bin:${PATH}"

# Rust
[[ -s "${HOME}/.cargo/env" ]] && . "${HOME}/.cargo/env"
export PATH="${HOME}/.cargo/bin:${PATH}"
export PATH="/usr/local/opt/rust/bin:${PATH}"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --smart-case --glob "!.git/*" --glob "!node_modules/*"'

# Ruby
export GEM_HOME="${HOME}/.gem"
export PATH="${GEM_HOME}/bin:${PATH}"
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"
export PATH="${PATH}:${HOME}/.rvm/bin"

# NodeJS
export NPM_CONFIG_PREFIX="${HOME}/.npm-global"
export PATH="${NPM_CONFIG_PREFIX}/bin:${PATH}"

# Java
export PATH="${JAVA_HOME}/bin:${PATH}"

# NVM
export NVM_DIR="${HOME}/.nvm"
[[ -s "${NVM_DIR}/nvm.sh" ]] && . "${NVM_DIR}/nvm.sh"

# ripgrep
export RIPGREP_CONFIG_PATH="${HOME}/.rgrc"

# LANG
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Flutter
export FVM_HOME="${HOME}/fvm"
export FLUTTER_VERSION="3.3"
export PATH="${FVM_HOME}/versions/${FLUTTER_VERSION}/bin:${PATH}"
export PATH="${HOME}/.pub-cache/bin:${PATH}"

# direnv
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# thefuck
if command -v thefuck &> /dev/null; then
  eval "$(thefuck --alias)"
fi

