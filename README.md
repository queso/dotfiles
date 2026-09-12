# dotfiles

Managed with [chezmoi](https://www.chezmoi.io). Source repo is `~/dotfiles` (this repo),
targets are real files in `$HOME`. macOS and Linux (Ubuntu now; Rocky and Arch later).

## New machine

```bash
ssh-keygen -t ed25519     # add the public key to GitHub
curl -fsSL https://raw.githubusercontent.com/queso/dotfiles/main/bootstrap.sh | bash
```

That installs chezmoi, clones this repo to `~/dotfiles`, applies every managed file, and runs the
scripts in order: system packages (apt on Linux, Homebrew everywhere), the shared `brew/Brewfile`
(install-only, re-run when the Brewfile changes), tmux terminfo, the herdr service, the herdmates
plugin. Then by hand: Dank Mono (paid font), `~/.env.local`, `claude` to authenticate.

## Day to day

- Edit files in `$HOME`, then `chezmoi re-add` and commit here. Or `chezmoi edit --apply <file>`.
- `chezmoi status` shows drift; `chezmoi diff` shows it in full; `chezmoi apply --force <file>` discards it.
- A Claude Code SessionStart hook (`.claude/hooks/chezmoi-drift.sh`) puts any drift into every
  agent session's context. A nightly job (`~/.local/bin/chezmoi-readd`, launchd on macOS,
  systemd timer on Linux) re-adds, commits as `re-add from <host>`, and pushes.
- Per-box files that are never in the repo: `~/.gitconfig.local` (included from `.gitconfig`),
  `~/.claude/settings.local.json` (model, autoUpdates, permissions), `~/.env.local`.

## Layout

| source | target |
|---|---|
| `dot_zshrc`, `dot_zshenv`, `dot_zprofile`, `dot_aliases`, `dot_oh-my-zsh/` | shell |
| `dot_gitconfig`, `dot_gitignore_global` | git (box-specific bits in `~/.gitconfig.local`) |
| `dot_tmux.conf`; `tmux/terminfo/` are sources for the terminfo script | tmux |
| `dot_vimrc`, `dot_gvimrc`, `dot_vim/` (plugins install into `~/.vim/plugged` per box) | vim |
| `dot_claude/` (settings, CLAUDE.md, agents, commands, hooks, statusline) | Claude Code |
| `dot_config/herdr/` (config with ctrl+j prefix and `prefix+=` rebalance, `bin/herdr-rebalance`) | herdr |
| `dot_config/systemd/user/` (Linux only): `herdr`, `herdr@<house>`, `chezmoi-readd.timer` | services |
| `Library/LaunchAgents/` (macOS only): nightly re-add | services |
| `dot_ssh/config` (Linux only, magi's) | ssh |
| `brew/Brewfile` | not a target; consumed by the bundle script |

## herdr

macOS runs the server under `brew services`; Linux under `systemctl --user` (`herdr` for the
default session, `herdr@<house>` per named session). Never start `herdr server` from inside a
Claude session: panes inherit `CLAUDE_CODE_CHILD_SESSION`, transcript saving turns off, and
restart resume dies. The `claude()` function in `dot_aliases` routes through the herdmates shim
inside herdr panes and sets `TEAMMUX_LEAD_WIDTH=50`. `magi <house> [<room> [dir]]` attaches to
a house on magi.

## Not tracked

`~/.ssh/` keys, `~/.kube/config`, `~/.claude/` runtime state (projects, plugins, credentials),
`~/.config/herdr/` runtime files (sockets, logs, session.json, plugins).
