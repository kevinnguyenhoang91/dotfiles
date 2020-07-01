ZSH_THEME="clean"

plugins=(git docker-compose zsh-autosuggestions)

export GEM_HOME="$HOME/.gem"
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:$GEM_HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/.rvm/bin"
export ZSH=~/.oh-my-zsh
export EDITOR=nvim
export NVM_DIR="$HOME/.nvm"
export RIPGREP_CONFIG_PATH="$HOME/.rgrc"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --smart-case --glob "!.git/*" --glob "!node_modules/*"'
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="$PATH:$HOME/Projects/flutter/bin"

[ -s "$ZSH/oh-my-zsh.sh" ] && . "$ZSH/oh-my-zsh.sh"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.secrets ] && source ~/.secrets
[ -f ~/.zsh/z.lua/z.lua ] && eval "$(lua ~/.zsh/z.lua/z.lua --init zsh enhanced once)"
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ] && source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# aliases
alias v='nvim'
alias vc='nvim ~/.config/nvim/init.vim'
alias zb='z -b'
# alias find='fd'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=121'

# tmux {{{
connect_to_most_recent_tmux_session() {
  if _not_in_tmux; then
    if _any_tmux_sessions; then
      tmux attach -t "$(_most_recent_tmux_session)"
    else
      tmux
    fi
  fi
}

# Returns the name of the most recent tmux session, sorted by time the session
# was last attached.
_most_recent_tmux_session(){
  tmux list-sessions -F "#{session_last_attached} #{session_name}" | \
    sort -r | \
    cut -d' ' -f2 | \
    head -1
}

_not_in_tmux() {
  [[ -z "$TMUX" ]]
}

_any_tmux_sessions() {
  [[ -n "$(tmux ls 2>/dev/null)" ]]
}

inside_ssh(){
  [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]
}

# if ! inside_ssh; then
#   connect_to_most_recent_tmux_session
# fi
# }}}
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/khanh/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/khanh/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/khanh/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/khanh/google-cloud-sdk/completion.zsh.inc'; fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/khanh/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/khanh/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/khanh/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/khanh/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

