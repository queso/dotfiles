#!/bin/bash
# Cross-platform package installer
set -e

if [[ "$(uname)" == "Darwin" ]]; then
  echo "Installing packages via Homebrew..."
  brew bundle --file="$(dirname "$0")/brew/Brewfile"

elif command -v apt-get &>/dev/null; then
  echo "Installing packages via apt..."
  sudo apt-get update
  sudo apt-get install -y \
    git jq wget coreutils fzf parallel age \
    awscli ansible terraform docker.io tmux mkcert \
    kubectl helm

  # gh CLI
  if ! command -v gh &>/dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update && sudo apt-get install -y gh
  fi

  # k9s
  if ! command -v k9s &>/dev/null; then
    curl -fsSL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz | sudo tar xz -C /usr/local/bin k9s
  fi

  # k3d
  if ! command -v k3d &>/dev/null; then
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  fi

  # kubectx/kubens
  if ! command -v kubectx &>/dev/null; then
    sudo apt-get install -y kubectx
  fi

  # kubeseal
  if ! command -v kubeseal &>/dev/null; then
    curl -fsSL https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-linux-amd64 -o /tmp/kubeseal
    sudo install /tmp/kubeseal /usr/local/bin/kubeseal
  fi

  # n (Node version manager)
  if ! command -v n &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | sudo bash -s install lts
  fi

  # pnpm
  if ! command -v pnpm &>/dev/null; then
    curl -fsSL https://get.pnpm.io/install.sh | sh -
  fi

  # bun
  if ! command -v bun &>/dev/null; then
    curl -fsSL https://bun.sh/install | bash
  fi
fi

echo "Packages installed."
