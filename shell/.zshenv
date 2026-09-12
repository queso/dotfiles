export EDITOR="vim"
export GIT_EDITOR="vim"
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$HOME/go/bin:$PATH"

# Machine-local secrets/env (ATEAM_*, ACCESS_CLIENT_*, DEVTRACK_*, ...).
# Sourced here (not just .zshrc) so non-interactive shells — Claude Code
# hooks, git hooks, scripts — get them too. File is not in the dotfiles repo.
[ -f "$HOME/.env.local" ] && source "$HOME/.env.local"

# Stable ssh-agent socket, served by the ssh-agent.service user unit
# (~/.config/systemd/user/ssh-agent.service). The path never changes, so
# long-lived processes — Claude Code, tmux panes, editors — keep working
# after an agent restart instead of holding a dead /tmp/ssh-*/agent.PID.
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket"
