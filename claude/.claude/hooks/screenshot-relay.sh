#!/usr/bin/env bash
# Screenshot Relay Hook
# Detects macOS screenshot paths in prompts,
# SFTPs them from the Mac, and rewrites paths to local /tmp/screenshots/
#
# Uses sftp with glob patterns instead of scp because macOS uses NFD Unicode
# decomposition in filenames, which breaks exact-path lookups over SFTP/SCP.

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

if [ -z "$PROMPT" ]; then
  exit 0
fi

# Match /var/folders/ or /Users/ paths ending in image extensions
# Allow spaces in paths (macOS screenshot names have spaces)
PATHS=$(echo "$PROMPT" | grep -oP '(/var/folders|/Users)/[^\n"'"'"']*?\.(png|jpg|jpeg|gif|webp)' || true)

if [ -z "$PATHS" ]; then
  exit 0
fi

mkdir -p /tmp/screenshots

REWRITTEN="$PROMPT"
FAILED=""

while IFS= read -r MACPATH; do
  FILENAME=$(basename "$MACPATH")
  LOCALPATH="/tmp/screenshots/$FILENAME"

  # Strip extension from path to build a glob prefix (handles NFD Unicode)
  GLOB_PREFIX="${MACPATH%.*}"

  # Use sftp with glob to fetch the file
  if sftp macbook <<SFTP_EOF > /dev/null 2>&1
get "${GLOB_PREFIX}"* /tmp/screenshots/
SFTP_EOF
  then
    # Verify the file arrived
    if [ -f "$LOCALPATH" ]; then
      REWRITTEN=$(printf '%s' "$REWRITTEN" | sed "s|$(printf '%s' "$MACPATH" | sed 's/[&/\]/\\&/g')|$LOCALPATH|g")
    else
      # File might have landed with slightly different name due to NFD, find it
      LANDED=$(ls -t /tmp/screenshots/ | head -1)
      if [ -n "$LANDED" ]; then
        LOCALPATH="/tmp/screenshots/$LANDED"
        REWRITTEN=$(printf '%s' "$REWRITTEN" | sed "s|$(printf '%s' "$MACPATH" | sed 's/[&/\]/\\&/g')|$LOCALPATH|g")
      else
        FAILED="${FAILED}Fetched but can't find: $MACPATH\n"
      fi
    fi
  else
    FAILED="${FAILED}Could not fetch: $MACPATH\n"
  fi
done <<< "$PATHS"

if [ -n "$FAILED" ]; then
  REWRITTEN="$REWRITTEN

[Screenshot relay error: $(echo -e "$FAILED")]"
fi

echo "$REWRITTEN"
