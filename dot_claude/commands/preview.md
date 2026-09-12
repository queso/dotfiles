---
description: Open a markdown file in a tmux split pane with glow
---

Open the file `$ARGUMENTS` in a tmux split pane using glow for rendered markdown preview.

Use the Bash tool to run:
```
tmux split-window -h "glow -p '$ARGUMENTS'"
```

If the file path is relative, resolve it against the current working directory. If no argument is provided, ask the user which file they want to preview.
