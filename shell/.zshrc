export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(brew dotenv git ssh-agent)

source $ZSH/oh-my-zsh.sh

source ~/.aliases

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
