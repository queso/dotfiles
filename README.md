# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Works on macOS and Linux (Ubuntu).

## Quick Start

### Mac

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow

# Clone and link
git clone git@github.com:queso/dotfiles.git ~/dotfiles
cd ~/dotfiles && stow -t ~ shell git tmux vim claude brew

# Install packages
./install.sh
```

### Linux (Ubuntu)

```bash
sudo apt-get install stow

# Clone and link
git clone git@github.com:queso/dotfiles.git ~/dotfiles
cd ~/dotfiles && stow -t ~ shell git tmux vim claude brew

# Install packages
./install.sh
```

### Post-setup

```bash
# Secrets (never committed — copy from password manager)
vim ~/.env.local

# Brain repo memory symlink (adjust path if Brain lives elsewhere)
mkdir -p ~/.claude/projects/-Users-$(whoami)-Code-Brain
ln -s ~/Code/Brain/.claude/memory ~/.claude/projects/-Users-$(whoami)-Code-Brain/memory
```

## Packages

| Package | Contents |
|---------|----------|
| `shell` | `.zshrc`, `.zshenv`, `.zprofile`, `.aliases` |
| `git` | `.gitconfig`, `.gitignore_global` |
| `tmux` | `.tmux.conf`, terminfo files |
| `vim` | `.vimrc`, `.gvimrc`, `.vim/` (Vundle plugins) |
| `claude` | Claude Code settings, statusline, custom agents |
| `brew` | `Brewfile` for Homebrew |

## Files Not Tracked

- `~/.env.local` — API keys and secrets
- `~/.ssh/` — SSH keys (regenerate per machine, config could be added later)
- `~/.kube/config` — K8s contexts (rebuilt from infra)
- `~/.claude/projects/` — session data, rebuilds naturally

## Adding New Files

```bash
# Example: track a new dotfile
cp ~/.some-config ~/dotfiles/shell/.some-config
cd ~/dotfiles && stow -R -t ~ shell
```

Or create a new package:

```bash
mkdir ~/dotfiles/newpkg
cp ~/.whatever ~/dotfiles/newpkg/.whatever
cd ~/dotfiles && stow -t ~ newpkg
```
