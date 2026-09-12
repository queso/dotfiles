#!/bin/bash
# New machine: git + an ssh key on GitHub, then this. chezmoi clones the repo to
# ~/dotfiles, applies every managed file as a real copy, and runs the scripts
# (system packages, Brewfile, terminfo, herdr service, herdmates).
#   curl -fsSL https://raw.githubusercontent.com/queso/dotfiles/main/bootstrap.sh | bash
set -e
if ! command -v chezmoi >/dev/null 2>&1; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
fi
chezmoi init --apply --source "$HOME/dotfiles" git@github.com:queso/dotfiles.git
