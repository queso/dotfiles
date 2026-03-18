export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(brew dotenv git ssh-agent)

source $ZSH/oh-my-zsh.sh

source ~/.aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.env.local ] && source ~/.env.local
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}☠ "
