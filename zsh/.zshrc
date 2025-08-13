# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Global variables
# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="random"
export ZSH=~/.oh-my-zsh
export TERM='xterm-256color'
export GPG_TTY=$(tty)
export GOPATH="${HOME}/go"
export ASDF_GOLANG_MOD_VERSION_ENABLED=true
export GEM_HOME="${HOME}/.gem"
export NPM_CONFIG_PREFIX="${HOME}/.npm-global"
export NVM_DIR="${HOME}/.nvm"
export RIPGREP_CONFIG_PATH="${HOME}/.rgrc"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export FVM_HOME="${HOME}/fvm"
export FLUTTER_VERSION="3.3"
export DISABLE_AUTO_TITLE='false'
export HISTFILE=${HOME}/.zsh_history
export HISTFILESIZE=50000
export HISTSIZE=50000
export HISTTIMEFORMAT="[%F %T] "

# Paths
export PATH="${HOME}/.local/bin:/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin:/home/linuxbrew/.linuxbrew/bin:${GOPATH}/bin:${HOME}/.cargo/bin:/usr/local/opt/rust/bin:${GEM_HOME}/bin:${NPM_CONFIG_PREFIX}/bin:${JAVA_HOME}/bin:${FVM_HOME}/versions/${FLUTTER_VERSION}/bin:${HOME}/.pub-cache/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:${PATH}"

# Plugins
plugins=(
  git docker-compose zsh-autosuggestions zsh-syntax-highlighting aliases
  1password argocd battery bazel branch colorize command-not-found direnv fzf
  kubectl jira macos man node pip pipenv python qrcode repo rsync ssh ssh-agent
  thefuck tldr torrent transfer vi-mode vscode virtualenv vim-interaction xcode
  yarn zsh-navigation-tools encode64
)

# Aliases
alias v='$EDITOR'
alias lg='lazygit'
alias lzd='lazydocker'
alias ls='ls -G'
alias ll='ls -lG'
alias lsa='ls -lahG'
alias nv='nvim -c "lua require\"persistence\".load()"'

# FZF
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --smart-case --glob "!.git/*" --glob "!node_modules/*"'

# oh-my-zsh
[[ -s "${ZSH}/oh-my-zsh.sh" ]] && . "${ZSH}/oh-my-zsh.sh"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=121'

# History settings
setopt extended_history share_history
setopt hist_find_no_dups hist_reduce_blanks

# cd without the need of typing cd
setopt auto_cd

# Edit command line in full screen editor
autoload edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Moving around line
bindkey '^A' beginning-of-line '^E' end-of-line '^F' backward-kill-word '^W' forward-word

# Completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle -e ':completion:*:approximate:*' \
  max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'
zstyle ':completion:*' format '%BCompleting %d%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' menu select

# Z.lua
[[ -f ~/.zsh/z.lua/z.lua ]] && eval "$(lua ~/.zsh/z.lua/z.lua --init zsh enhanced once)"

# Plugin sources
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ]] && source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
[[ -f ~/.zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh ]] && source ~/.zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh

# tmuxp
tmuxpp() {
  local subdir=$1
  local config=$(fd --glob '*.yaml' ~/.tmuxp/${subdir} | fzf --multi --prompt="tmuxp Saved Sessions > " --height=~50% --layout=reverse --border --exit-0 --print0)
  [[ -z $config ]] && echo "No config selected" && return
  config=$(echo -n "$config" | tr '\0' ' ')
  config=$(echo -n "$config" | sed 's/[[:space:]]*$//')
  if command -v tmuxp &> /dev/null; then
    config_array=(${(s: :)config})
    tmuxp load -dy "${config_array[@]}"
  fi
}

# NVM
[[ -s "${NVM_DIR}/bash_completion" ]] && . "${NVM_DIR}/bash_completion" # This loads nvm bash_completion

# Platform specific
[[ -s "${HOME}/.zplatform" ]] && . "${HOME}/.zplatform"

# Google Cloud SDK
[[ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]] && . "${HOME}/google-cloud-sdk/path.zsh.inc"
[[ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

# Dart CLI Completion
[[ -f ${HOME}/.dart-cli-completion/zsh-config.zsh ]] && . ${HOME}/.dart-cli-completion/zsh-config.zsh || true

# direnv
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# thefuck
if command -v thefuck &> /dev/null; then
  eval "$(thefuck --alias)"
fi

# autoenv
[[ -s "/usr/local/opt/autoenv/activate.sh" ]] && . /usr/local/opt/autoenv/activate.sh

# Asdf
[[ -s "${HOME}/.asdf/asdf.sh" ]] && . ${HOME}/.asdf/asdf.sh
fpath=(${ASDF_DIR}/completions $fpath)

# Rust
[[ -s "${HOME}/.cargo/env" ]] && . "${HOME}/.cargo/env"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Ruby
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"

# NVM
[[ -s "${NVM_DIR}/nvm.sh" ]] && . "${NVM_DIR}/nvm.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# atuin
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/khanh/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/khanh/.lmstudio/bin"
# End of LM Studio CLI section

if [ -f "$HOME/.secrets.zsh" ]; then source "$HOME/.secrets.zsh"; fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/user/google-cloud-sdk/path.zsh.inc' ]; then . '/home/user/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/user/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/user/google-cloud-sdk/completion.zsh.inc'; fi
