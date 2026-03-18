#!/bin/bash
# Cross-platform package installer
set -e

if [[ "$(uname)" == "Darwin" ]]; then
  echo "Installing packages via Homebrew..."
  brew bundle --file="$(dirname "$0")/brew/Brewfile"

elif command -v apt-get &>/dev/null; then
  echo "Installing packages via apt..."
  sudo apt-get update

  # Packages available in default Ubuntu repos
  sudo apt-get install -y \
    git jq wget unzip coreutils fzf parallel age \
    ansible docker.io tmux mkcert

  # AWS CLI v2
  if ! command -v aws &>/dev/null; then
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip -qo /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install
    rm -rf /tmp/aws /tmp/awscliv2.zip
  fi

  # glow
  if ! command -v glow &>/dev/null; then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt-get update && sudo apt-get install -y glow
  fi

  # gh CLI
  if ! command -v gh &>/dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update && sudo apt-get install -y gh
  fi

  # Terraform
  if ! command -v terraform &>/dev/null; then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update && sudo apt-get install -y terraform
  fi

  # kubectl
  if ! command -v kubectl &>/dev/null; then
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update && sudo apt-get install -y kubectl
  fi

  # Helm
  if ! command -v helm &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
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
    KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    curl -fsSL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" | sudo tar xz -C /usr/local/bin kubeseal
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
