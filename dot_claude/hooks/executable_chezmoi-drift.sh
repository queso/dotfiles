#!/usr/bin/env bash
# SessionStart hook: surface dotfiles drift to the agent, in its context, before it does anything.
# Managed files live in $HOME as real copies; tools rewrite them; this is how that gets noticed.
set -uo pipefail
export PATH="/opt/homebrew/bin:/home/linuxbrew/.linuxbrew/bin:$HOME/.local/bin:$PATH"
command -v chezmoi >/dev/null 2>&1 || exit 0
[ -f "$HOME/.config/chezmoi/chezmoi.toml" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# `chezmoi verify` is not the gate: it also fails when a run_onchange_ script is
# merely pending, and those rows (code R) are not drift — no file in $HOME was
# edited and there is nothing to re-add. Keep only rows about real targets.
status=$(chezmoi status 2>/dev/null | grep -v '^.\?R ' | head -20)
[ -n "$status" ] || exit 0

msg="Dotfiles drift on $(hostname -s): these chezmoi-managed files differ from the source repo at $(chezmoi source-path 2>/dev/null). A capital M in the second column means the copy in \$HOME was edited in place. Run \`chezmoi diff\` to see the change, then \`chezmoi re-add\` to pull it into the repo and commit, or \`chezmoi apply\` to discard it. Do not leave managed files edited without re-adding.
$status"
jq -n --arg v "$msg" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$v}}'
