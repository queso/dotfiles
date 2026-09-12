#!/bin/bash
# Cross-platform package installer
set -e

if [[ "$(uname)" == "Darwin" ]]; then
  echo "Installing packages via Homebrew..."
  brew bundle --file="$(dirname "$0")/brew/Brewfile"

elif command -v apt-get &>/dev/null; then
  echo "Installing system-tier packages via apt..."
  sudo apt-get update

  # System tier only: everything else comes from Homebrew (brew/Brewfile)
  sudo apt-get install -y \
    git curl zsh stow build-essential docker.io

  # Homebrew (Linux)
  if [ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # Third-party taps require a one-time trust grant before brew will load their formulae.
  brew trust derailed/k9s hashicorp/tap 2>/dev/null || true

  echo "Installing packages via Homebrew..."
  brew bundle --file="$(dirname "$0")/brew/Brewfile"
fi

echo "Packages installed."
