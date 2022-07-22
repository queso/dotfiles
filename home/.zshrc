export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(brew dotenv git ssh-agent)

source $ZSH/oh-my-zsh.sh

ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}☠️ "

source ~/.aliases
source ~/.zshenv

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
