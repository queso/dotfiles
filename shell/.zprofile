if [[ "$(uname)" == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi

[ -d /home/linuxbrew/.linuxbrew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"
