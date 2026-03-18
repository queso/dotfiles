# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Works on macOS and Linux (Ubuntu).

## New Machine Setup

### 1. SSH key

```bash
ssh-keygen -t ed25519
# Add ~/.ssh/id_ed25519.pub to GitHub
```

### 2. Bootstrap

```bash
git clone git@github.com:queso/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

That's it. The bootstrap script handles:
- Installing stow and linking all packages
- Installing platform packages (brew on mac, apt on linux)
- vim-plug and all vim plugins
- Claude Code (native installer)
- oh-my-zsh

### 3. Manual steps after bootstrap

```bash
# Secrets (copy from password manager)
vim ~/.env.local

# Brain repo + Claude memory symlink
git clone git@github.com:queso/Brain ~/Code/Brain
mkdir -p ~/.claude/projects/-Users-$(whoami)-Code-Brain
ln -s ~/Code/Brain/.claude/memory ~/.claude/projects/-Users-$(whoami)-Code-Brain/memory

# Authenticate Claude Code
claude
```

## Packages

| Package | Contents |
|---------|----------|
| `shell` | `.zshrc`, `.zshenv`, `.zprofile`, `.aliases` |
| `git` | `.gitconfig`, `.gitignore_global` |
| `tmux` | `.tmux.conf`, terminfo files |
| `vim` | `.vimrc`, `.gvimrc`, `.vim/` (vim-plug, plugins installed on setup) |
| `claude` | Claude Code settings, statusline, custom agents |
| `brew` | `Brewfile` for Homebrew |

## Files Not Tracked

- `~/.env.local` — API keys and secrets
- `~/.ssh/` — SSH keys (regenerate per machine)
- `~/.kube/config` — K8s contexts (rebuilt from infra)
- `~/.claude/projects/` — session data, rebuilds naturally

## Adding New Files

```bash
# Add to an existing package
cp ~/.some-config ~/dotfiles/shell/.some-config
cd ~/dotfiles && stow -R -t ~ shell

# Or create a new package
mkdir ~/dotfiles/newpkg
cp ~/.whatever ~/dotfiles/newpkg/.whatever
cd ~/dotfiles && stow -t ~ newpkg
```
