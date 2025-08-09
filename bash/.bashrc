export TERM='xterm-256color'

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

if ! inside_ssh && ! inside_vscode; then
	connect_to_most_recent_tmux_session
fi
# }}}

# NVM
[[ -s "${NVM_DIR}/bash_completion" ]] && \. "${NVM_DIR}/bash_completion" # This loads nvm bash_completion

# Platform specific
[[ -s "${HOME}/.bash_platform" ]] && \. "${HOME}/.bash_platform"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/khanh/.lmstudio/bin"
# End of LM Studio CLI section

