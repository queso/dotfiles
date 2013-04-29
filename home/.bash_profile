# Setup rbenv

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Variables

export EDITOR="vim"
export GIT_EDITOR="vim"
export PATH="./binstubs:$HOME/.rbenv/bin:/usr/local/share/npm/bin:$PATH"

# Aliases

alias b="bundle"
alias bi="b install --binstubs=binstubs --path vendor"
alias bu="b update"
alias be="b exec"
alias binit="bi && b package && echo 'vendor/ruby' >> .gitignore"

# Set up prompt

function parse_git_branch {
git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
}

function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "☠"
}


function parse_ruby_version {
  rbenv version | sed -e 's/ .*//'
}

function proml {
  local        BLUE="\[\033[0;34m\]"
  local         RED="\[\033[0;31m\]"
  local   LIGHT_RED="\[\033[1;31m\]"
  local      YELLOW="\[\033[1;33m\]"
  local       GREEN="\[\033[0;32m\]"
  local LIGHT_GREEN="\[\033[1;32m\]"
  local       WHITE="\[\033[1;37m\]"
  local  LIGHT_GRAY="\[\033[0;37m\]"
  local NONE="\[\033[0m\]"    
  case $TERM in
    xterm*)
    TITLEBAR='\[\033]0;\u@\h:\W\007\]'
    ;;
    *)
    TITLEBAR=""
    ;;
  esac

PS1="${TITLEBAR}\
$BLUE[$LIGHT_GRAY\u:\W$GREEN\$(parse_git_branch)$BLUE][$YELLOW\$(parse_ruby_version)$BLUE]\
$GREEN\$$NONE "
PS2='> '
PS4='+ '
}
proml
