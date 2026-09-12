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
| `dot_config/nvim/` (LazyVim; `lazy-lock.json` pins plugins across boxes) | neovim |
| `dot_vimrc`, `dot_gvimrc`, `dot_vim/` (plugins install into `~/.vim/plugged` per box) | vim, kept as fallback until 2026-10-12 |
| `dot_claude/` (settings, CLAUDE.md, agents, commands, hooks, statusline) | Claude Code |
| `dot_config/herdr/` (config with ctrl+j prefix and `prefix+=` rebalance, `bin/herdr-rebalance`) | herdr |
| `dot_config/systemd/user/` (Linux only): `herdr`, `herdr@<house>`, `chezmoi-readd.timer` | services |
| `Library/LaunchAgents/` (macOS only): nightly re-add | services |
| `dot_ssh/config` (Linux only, magi's) | ssh |
| `brew/Brewfile` | not a target; consumed by the bundle script |

## neovim

LazyVim, seeded from the upstream starter (`803bc18`) and kept as a chezmoi target at
`~/.config/nvim`. First `nvim` on a new box bootstraps lazy.nvim, installs the pinned plugins,
and compiles treesitter parsers; give it a few minutes and then `:checkhealth`.

Four things differ from stock LazyVim, all in `lua/config/` and `lua/plugins/josh.lua`:

- **Leader is backslash, not `<Space>`.** Set in `lua/config/options.lua`, which LazyVim loads
  after its own defaults, so the whole keymap tree follows (`\ff` finds files, `\e` opens the
  explorer). `<Space>` keeps its old job of toggling `hlsearch`, and `maplocalleader` moves to
  `,` so it does not collide. Every LazyVim doc and video says `<Space>`; here, type `\`.
- Ported from `.vimrc`: `relativenumber` off, `timeoutlen=250`, no backup files, colorcolumn at
  81, arrow keys disabled, `<C-p>` for git files, `\l` for buffers, `\rw` to strip trailing
  whitespace, trailing whitespace highlighted, the `inpsection` abbreviation.
- `gd` opens the definition in a vertical split, as the old CoC mapping did. It replaces the
  entry in LazyVim's LSP keymap list rather than shadowing it, because those maps are
  buffer-local.
- Extras are imported in `lua/config/lazy.lua`, not toggled in `:LazyExtras`. That keeps the set
  versioned with the config and keeps `lazyvim.json` (per-box bookkeeping) out of the repo.

CoC, syntastic, airline, Command-T and the vim-plug language plugins have no port: native LSP,
conform, lualine and the treesitter langs replace them. `~/.vim` and `~/.vimrc` stay managed
until 2026-10-12 so `vim` still works if something here does not.

## herdr

macOS runs the server under `brew services`; Linux under `systemctl --user` (`herdr` for the
default session, `herdr@<house>` per named session). Never start `herdr server` from inside a
Claude session: panes inherit `CLAUDE_CODE_CHILD_SESSION`, transcript saving turns off, and
restart resume dies. The `claude()` function in `dot_aliases` routes through the herdmates shim
inside herdr panes and sets `TEAMMUX_LEAD_WIDTH=50`. `magi <house> [<room> [dir]]` attaches to
a house on magi.

## Not tracked

`~/.ssh/` keys, `~/.kube/config`, `~/.claude/` runtime state (projects, plugins, credentials),
`~/.config/herdr/` runtime files (sockets, logs, session.json, plugins),
`~/.config/nvim/lazyvim.json` (which NEWS entries were read), and neovim's own state under
`~/.local/share/nvim` and `~/.local/state/nvim` (plugins, parsers, mason tools, undo).
