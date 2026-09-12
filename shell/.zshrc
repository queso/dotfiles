export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# ssh-agent plugin dropped: .zshenv pins SSH_AUTH_SOCK to the systemd
# ssh-agent.service user socket, which supersedes it.
plugins=(brew dotenv git)

source $ZSH/oh-my-zsh.sh

source ~/.aliases

# Go
export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"

# Set COLORTERM for truecolor support (SSH doesn't forward it)
if [[ -z "$COLORTERM" ]]; then
  case "$TERM" in
    xterm-ghostty|ghostty|xterm-256color|alacritty|tmux-256color*)
      export COLORTERM=truecolor
      ;;
  esac
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.env.local ] && source ~/.env.local
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun completions
[ -s "/tmp/bunlatest/_bun" ] && source "/tmp/bunlatest/_bun"

# direnv (per-directory env, e.g. KUBECONFIG per cluster repo)
eval "$(direnv hook zsh)"

# gpg-agent's ssh socket uses pinentry-curses; it can only prompt on a tty it
# knows about. Without this, ssh-add against the gnupg socket fails with
# "agent refused operation" (bit the content pipeline, 2026-08-26).
if [[ -o interactive ]] && tty -s; then
  export GPG_TTY=$(tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
fi

export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/swift/usr/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
