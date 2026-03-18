#!/bin/bash
# Full new machine bootstrap.
# Prerequisites: git, ssh key added to GitHub.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/queso/dotfiles/main/bootstrap.sh | bash
#   — or —
#   git clone git@github.com:queso/dotfiles.git ~/dotfiles && ~/dotfiles/bootstrap.sh
set -e

DOTFILES="$HOME/dotfiles"

# Clone if not already present
if [ ! -d "$DOTFILES" ]; then
  git clone git@github.com:queso/dotfiles.git "$DOTFILES"
fi

# Install stow
if ! command -v stow &>/dev/null; then
  if [[ "$(uname)" == "Darwin" ]]; then
    brew install stow
  else
    sudo apt-get update && sudo apt-get install -y stow
  fi
fi

# Link all packages
cd "$DOTFILES"
stow -t ~ --adopt shell git tmux vim claude brew
# Reset any adopted files back to repo versions
git checkout .

# Compile custom terminfo entries (italic support)
for ti in "$DOTFILES"/tmux/terminfo/*.terminfo; do
  [ -f "$ti" ] && tic -x "$ti"
done

# Install packages
"$DOTFILES/install.sh"

# vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -es +PlugInstall +qall 2>/dev/null || true

# Claude Code
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo ""
echo "Bootstrap complete. Manual steps remaining:"
echo "  1. Populate ~/.env.local with API keys"
echo "  2. Run 'claude' to authenticate"
echo "  3. Clone Brain repo and create memory symlink:"
echo "     git clone git@github.com:queso/Brain ~/Code/Brain"
echo "     mkdir -p ~/.claude/projects/-Users-\$(whoami)-Code-Brain"
echo "     ln -s ~/Code/Brain/.claude/memory ~/.claude/projects/-Users-\$(whoami)-Code-Brain/memory"
