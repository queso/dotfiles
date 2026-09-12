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
| `claude` | Claude Code settings, statusline, custom agents, screenshot relay hook |
| `ssh` | SSH config (screenshot relay ControlMaster for magi → Mac) |
| `claude` | Claude Code settings, statusline, custom agents, `hooks/` (herdr agent-state hook) |
| `brew` | `Brewfile` for Homebrew |
| `herdr` | `.config/herdr/config.toml` (ctrl+j prefix, `prefix+=` rebalance) and `bin/herdr-rebalance` |

## herdr (agent runtime)

Stowed config covers the prefix key and the rebalance binding. The rest is a one-time
setup per machine, after `brew bundle`:

```bash
brew services start herdr                 # server under launchd (Linux: a systemd user unit + enable-linger)
herdr integration install claude          # rewrites ~/.claude/hooks/herdr-agent-state.sh (already stowed) + settings hook
git clone git@github.com:queso/herdmates ~/Code/OpenSource/herdmates && cd ~/Code/OpenSource/herdmates
git checkout lead-width-override          # until caioniehues/herdmates#136 merges
herdr plugin link ~/Code/OpenSource/herdmates
cargo install --path . --root ~/.local    # plugin link does not build; needs rustup's toolchain bin on PATH
```

Never start `herdr server` from inside a Claude Code session: panes inherit
`CLAUDE_CODE_CHILD_SESSION`, transcript saving turns off, and restart resume dies.

The `claude()` function in `shell/.aliases` routes through the herdmates shim only inside a
herdr pane and sets `TEAMMUX_LEAD_WIDTH=50` (the lead's share at spawn). `prefix+=` equalizes
every pane afterwards. The rebalance binding in `config.toml` uses an absolute path; edit it on
a machine whose home is not `/Users/josh`.

## Screenshot Relay (magi only)

Drag-and-drop screenshots into remote Claude Code sessions over SSH+tmux. A `UserPromptSubmit` hook detects macOS screenshot paths in prompts, SFTPs the image from the Mac, and rewrites the path to a local `/tmp/screenshots/` path.

### Setup on a fresh magi

```bash
# 1. Install avahi-daemon for mDNS resolution
sudo apt install avahi-daemon

# 2. Generate dedicated SSH key (read-only, SFTP-only)
ssh-keygen -t ed25519 -f ~/.ssh/screenshot_relay -N "" -C "magi-screenshot-relay"

# 3. Add public key to Mac's ~/.ssh/authorized_keys (replace YOUR_KEY):
#    command="/usr/libexec/sftp-server",no-pty,no-agent-forwarding,no-port-forwarding,from="MAGI_IP" YOUR_KEY

# 4. Verify connection
sftp macbook <<< "ls /Users/josh/Desktop"

# 5. Add cron cleanup (daily 3am, 24hr TTL)
echo '0 3 * * * find /tmp/screenshots -type f -mmin +1440 -delete 2>/dev/null' | crontab -
```

The SSH config (`~/.ssh/config`) and hook script (`~/.claude/hooks/screenshot-relay.sh`) are managed by stow. The SSH key is per-machine — regenerate it and add to the Mac each time.

## Files Not Tracked

- `~/.env.local` — API keys and secrets
- `~/.ssh/screenshot_relay*` — SSH keys (regenerate per machine)
- `~/.kube/config` — K8s contexts (rebuilt from infra)
- `~/.claude/projects/` — session data, rebuilds naturally
- `~/.config/herdr/` runtime files (sockets, logs, `session.json`, `plugins/`) — only `config.toml` and `bin/` are stowed

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
