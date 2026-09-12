#!/usr/bin/env bash
# File Relay Hook (magi side) — scp -O variant
# Detects macOS file paths in prompts (screenshots, docs, data files),
# fetches them from the Mac over the LOCKED relay key, and rewrites paths
# to local /tmp/screenshots/.
#
# Replaces the earlier sftp-glob version. The relay key on the laptop is
# now forced to screenshot-scp-only (read-only, type+path allowlisted), so
# this side must speak legacy scp: `scp -O macbook:<exact-path>`.
#
# NFD handling: macOS stores filenames NFD-normalized while prompts often
# carry NFC. The old version globbed to dodge the mismatch; the wrapper
# forbids globs, so instead we try both normalization forms as exact
# fetches. Screenshots are ASCII and hit on the first try; accented names
# resolve on the NFD attempt.
#
# Cutover order (see conduit-magi security-posture.md §3.2): install the
# wrapper + swap the key on the laptop FIRST, then install this file at
# ~/.claude/hooks/screenshot-relay.sh. Doing it the other way round breaks
# the relay in the gap.

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

if [ -z "$PROMPT" ]; then
  exit 0
fi

# Allowlisted-prefix paths ending in an allowlisted type. Prefixes match the
# laptop wrapper (/var/folders, ~/Desktop, ~/Downloads) so we don't attempt
# fetches the wrapper will reject. NO json — credential-adjacent, and the
# wrapper refuses it regardless.
PATHS=$(echo "$PROMPT" | grep -oP '(/var/folders/|/Users/josh/Desktop/|/Users/josh/Downloads/)[^\n"'"'"']*?\.(png|jpg|jpeg|gif|webp|heic|heif|xlsx|xls|csv|tsv|pdf)' || true)

if [ -z "$PATHS" ]; then
  exit 0
fi

mkdir -p /tmp/screenshots

REWRITTEN="$PROMPT"
FAILED=""

# Emit NFC then NFD forms of a string (one per line, order preserved,
# de-duplicated). Falls back to the raw string if python3 is unavailable.
normalize_variants() {
  if command -v python3 >/dev/null 2>&1; then
    MACPATH="$1" python3 - <<'PY'
import os, unicodedata
s = os.environ["MACPATH"]
seen = []
for form in ("NFC", "NFD"):
    v = unicodedata.normalize(form, s)
    if v not in seen:
        seen.append(v)
        print(v)
PY
  else
    printf '%s\n' "$1"
  fi
}

while IFS= read -r MACPATH; do
  [ -n "$MACPATH" ] || continue
  FILENAME=$(basename "$MACPATH")
  LOCALPATH="/tmp/screenshots/$FILENAME"
  fetched=""

  while IFS= read -r CAND; do
    [ -n "$CAND" ] || continue
    # Exact fetch. The remote path is one argument; scp quotes it for the
    # wire and the laptop wrapper reconstructs + validates it.
    #
    # ControlPath=none / ControlMaster=no are REQUIRED: the ssh_config
    # `Host macbook` enables connection multiplexing (a leftover from the
    # sftp relay), which is incompatible with a forced-command scp key —
    # you cannot run a master shell over a connection locked to one
    # `scp -f`. BatchMode keeps a hung auth from blocking the prompt.
    if scp -O -o ControlPath=none -o ControlMaster=no -o BatchMode=yes \
           -o ConnectTimeout=10 -o LogLevel=ERROR \
           "macbook:$CAND" /tmp/screenshots/ >/dev/null 2>&1; then
      fetched=1
      break
    fi
  done <<VARIANTS
$(normalize_variants "$MACPATH")
VARIANTS

  if [ -n "$fetched" ]; then
    if [ ! -f "$LOCALPATH" ]; then
      # NFD-on-disk may land under a different byte-name; take the newest.
      LANDED=$(ls -t /tmp/screenshots/ | head -1 || true)
      [ -n "$LANDED" ] && LOCALPATH="/tmp/screenshots/$LANDED"
    fi
    # iPhone photos arrive as HEIC, which Claude can't view. Convert to JPG
    # and hand the prompt the JPG path instead. Converter deps live in
    # ~/.local/share/screenshot-relay (see heic-to-jpg.js).
    case "$LOCALPATH" in
      *.heic|*.HEIC|*.heif|*.HEIF)
        if JPGPATH=$(node "$HOME/.claude/hooks/heic-to-jpg.js" "$LOCALPATH" 2>/dev/null) && [ -f "$JPGPATH" ]; then
          LOCALPATH="$JPGPATH"
        else
          FAILED="${FAILED}Fetched but could not convert HEIC: $LOCALPATH\n"
        fi
        ;;
    esac
    REWRITTEN=$(printf '%s' "$REWRITTEN" | sed "s|$(printf '%s' "$MACPATH" | sed 's/[&/\]/\\&/g')|$LOCALPATH|g")
  else
    FAILED="${FAILED}Could not fetch: $MACPATH\n"
  fi
done <<< "$PATHS"

if [ -n "$FAILED" ]; then
  REWRITTEN="$REWRITTEN

[Screenshot relay error: $(echo -e "$FAILED")]"
fi

echo "$REWRITTEN"
