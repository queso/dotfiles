#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Get the containing folder name (current working directory)
folder_name=$(basename "$PWD")

# Get git branch and dirty status
if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    # Check if working tree is dirty (using --no-optional-locks to avoid lock issues)
    if ! git --no-optional-locks diff-index --quiet HEAD -- 2>/dev/null; then
        git_status="{$branch ☠️}"
    else
        git_status="{$branch}"
    fi
else
    git_status=""
fi

# Extract model display name
model=$(echo "$input" | jq -r '.model.display_name')

# Calculate context usage percentage and create progress bar
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    # Sum all token types (using // 0 to handle nulls)
    current=$(echo "$usage" | jq '(.input_tokens // 0) + (.output_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0) | floor')
    size=$(echo "$input" | jq '.context_window.context_window_size')
    pct=$((current * 100 / size))

    # Create progress bar (20 characters wide, each char = 5%)
    filled=$((pct / 5))
    [ $filled -gt 20 ] && filled=20

    # Build bar with ANSI colors - same char (█) ensures alignment
    # Color based on usage: green <35%, yellow 35-50%, red >50%
    if ((pct > 50)); then
        filled_color='\033[91m'  # bright red
    elif ((pct > 35)); then
        filled_color='\033[93m'  # bright yellow
    else
        filled_color='\033[92m'  # bright green
    fi

    bar=""
    for ((i=0; i<20; i++)); do
        if ((i < filled)); then
            bar+="${filled_color}█\033[0m"
        else
            bar+='\033[90m█\033[0m'
        fi
    done
    context_info=$(printf '%b %3d%%' "$bar" "$pct")
else
    bar=""
    for ((i=0; i<20; i++)); do bar+='\033[90m█\033[0m'; done
    context_info=$(printf '%b   0%%' "$bar")
fi

# Get current date/time (US format: M/D/YY H:MMa/p)
current_time=$(date +"%-m/%-d/%y %-l:%M%P")

# Get local weather with 20-minute read-through cache
weather_cache="$HOME/.claude/weather-cache.txt"
cache_max_age=3600  # 1 hour in seconds

if [ -f "$weather_cache" ]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        cache_age=$(( $(date +%s) - $(stat -f %m "$weather_cache") ))
    else
        cache_age=$(( $(date +%s) - $(stat -c %Y "$weather_cache") ))
    fi
else
    cache_age=$((cache_max_age + 1))
fi

if [ "$cache_age" -gt "$cache_max_age" ]; then
    fresh=$(curl -s --max-time 2 "wttr.in/?format=%c+%t&u" 2>/dev/null)
    if [ -n "$fresh" ]; then
        echo "$fresh" > "$weather_cache"
        weather="$fresh"
    elif [ -f "$weather_cache" ]; then
        weather=$(cat "$weather_cache")
    else
        weather="N/A"
    fi
else
    weather=$(cat "$weather_cache")
fi

# Check if Agent Teams feature is enabled
if [ "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" = "1" ]; then
    agent_teams="Agent Teams ✅"
else
    agent_teams="Agent Teams ❌"
fi

# Output the status line with folder name and git status
if [ -n "$git_status" ]; then
    printf '[%s] %s %s | %s | %s | %s | %s' "$folder_name" "$git_status" "$model" "$context_info" "$agent_teams" "$current_time" "$weather"
else
    printf '[%s] %s | %s | %s | %s | %s' "$folder_name" "$model" "$context_info" "$agent_teams" "$current_time" "$weather"
fi
