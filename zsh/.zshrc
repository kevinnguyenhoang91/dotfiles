# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git docker-compose zsh-autosuggestions zsh-syntax-highlighting aliases 1password argocd battery bazel autoenv branch brew colorize command-not-found direnv fzf kubectl jira macos man node pip pipenv python qrcode repo rsync ssh ssh-agent thefuck tldr torrent transfer vi-mode vscode virtualenv vim-interaction xcode yarn zsh-navigation-tools encode64)

export ZSH=~/.oh-my-zsh
export TERM='xterm-256color'
[[ -s "${ZSH}/oh-my-zsh.sh" ]] && . "${ZSH}/oh-my-zsh.sh"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=121'

# History settings
export HISTFILE=${HOME}/.zsh_history
export HISTFILESIZE=50000
export HISTSIZE=50000
export HISTTIMEFORMAT="[%F %T] "
setopt extended_history share_history
setopt hist_find_no_dups hist_reduce_blanks

# cd without the need of typing cd
setopt auto_cd

# Edit command line in full screen editor
autoload edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Moving around line
bindkey '^A' beginning-of-line '^E' end-of-line '^W' backward-kill-word

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

# Plugins
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ] && source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
[ -f ~/.zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh ] && source ~/.zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh

# tmuxp {{{
tmuxpp() {
  # Assumes all configs exist in directories named ~/.tmuxp/*.yaml
  local config=$(fd --glob '*.yaml' ~/.tmuxp | fzf --multi --prompt="tmuxp Saved Sessions > " --height=~50% --layout=reverse --border --exit-0 --print0)

  # If I exit fzf without selecting a config, don't run tmuxp
  [[ -z $config ]] && echo "No config selected" && return
  config=$(echo -n "$config" | tr '\0' ' ')
  config=$(echo -n "$config" | sed 's/[[:space:]]*$//')
  if command -v tmuxp &> /dev/null; then
    config_array=(${(s: :)config})
    tmuxp load -dy "${config_array[@]}"
  fi
}
# }}}

# tmux {{{
connect_to_most_recent_tmux_session() {
if command -v tmux &> /dev/null; then
  if _not_in_tmux; then
    if _any_tmux_sessions; then
      tmux attach -t "$(_most_recent_tmux_session)"
    else
      tmuxpp
    fi
  fi
fi
}

# Returns the name of the most recent tmux session, sorted by time the session
# was last attached.
_most_recent_tmux_session() {
  tmux list-sessions -F "#{session_last_attached} #{session_name}" |
    sort -r |
    cut -d' ' -f2 |
    head -1
}

_not_in_tmux() {
  [[ -z "${TMUX}" ]]
}

_any_tmux_sessions() {
  [[ -n "$(tmux ls 2>/dev/null)" ]]
}

inside_ssh() {
  [[ -n "${SSH_CLIENT}" ]] || [[ -n "${SSH_TTY}" ]]
}

inside_vscode() {
  [[ -n "${TERM_PROGRAM}" ]] && [[ "${TERM_PROGRAM}" == *"vscode"* ]]
}

inside_iterm() {
  [[ -n "${TERM_PROGRAM}" ]] && [[ "${TERM_PROGRAM}" == *"iTerm.app"* ]]
}

if ! inside_ssh && ! inside_vscode && ! inside_iterm; then
  connect_to_most_recent_tmux_session
fi
# }}}

# NVM
[[ -s "${NVM_DIR}/bash_completion" ]] && . "${NVM_DIR}/bash_completion" # This loads nvm bash_completion

# Platform specific
[[ -s "${HOME}/.zplatform" ]] && . "${HOME}/.zplatform"

# The next line updates PATH for the Google Cloud SDK.
if [[ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]]; then . "${HOME}/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [[ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f ${HOME}/.dart-cli-completion/zsh-config.zsh ]] && . ${HOME}/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
