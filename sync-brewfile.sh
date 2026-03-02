#!/usr/bin/env bash
set -euo pipefail

# Sync Brewfile with currently installed Homebrew packages.
# Preserves the existing file's organization, comments, and ordering.
# Removed packages are dropped in place; new packages are appended
# under an "Unsorted" heading for manual organization.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"

if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed." >&2
    exit 1
fi

if [[ ! -f "$BREWFILE" ]]; then
    echo "Error: No existing Brewfile found at $BREWFILE" >&2
    echo "Create one manually first, then use this script to keep it in sync." >&2
    exit 1
fi

echo "Syncing Brewfile with installed packages..."

# Capture currently installed packages as newline-separated lists
installed_brews=$(brew leaves)
installed_casks=$(brew list --cask 2>/dev/null || true)
installed_taps=$(brew tap)

# Track which installed packages we've seen in the Brewfile
seen_brews=""
seen_casks=""
seen_taps=""

# Process existing Brewfile line by line, preserving structure
output=""
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^brew\ \"([^\"]+)\" ]]; then
        pkg="${BASH_REMATCH[1]}"
        if echo "$installed_brews" | grep -qxF "$pkg"; then
            output+="$line"$'\n'
            seen_brews+="$pkg"$'\n'
        else
            echo "  Removed: $line"
        fi
    elif [[ "$line" =~ ^cask\ \"([^\"]+)\" ]]; then
        pkg="${BASH_REMATCH[1]}"
        if echo "$installed_casks" | grep -qxF "$pkg"; then
            output+="$line"$'\n'
            seen_casks+="$pkg"$'\n'
        else
            echo "  Removed: $line"
        fi
    elif [[ "$line" =~ ^tap\ \"([^\"]+)\" ]]; then
        tap="${BASH_REMATCH[1]}"
        if echo "$installed_taps" | grep -qxF "$tap"; then
            output+="$line"$'\n'
            seen_taps+="$tap"$'\n'
        else
            echo "  Removed: $line"
        fi
    else
        # Comments, blank lines, and anything else: keep as-is
        output+="$line"$'\n'
    fi
done < "$BREWFILE"

# Find newly installed packages not yet in the Brewfile
new_taps=""
while IFS= read -r tap; do
    [[ -z "$tap" ]] && continue
    if ! echo "$seen_taps" | grep -qxF "$tap"; then
        new_taps+="$tap"$'\n'
    fi
done < <(echo "$installed_taps" | sort)

new_brews=""
while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    if ! echo "$seen_brews" | grep -qxF "$pkg"; then
        new_brews+="$pkg"$'\n'
    fi
done < <(echo "$installed_brews" | sort)

new_casks=""
while IFS= read -r cask; do
    [[ -z "$cask" ]] && continue
    if ! echo "$seen_casks" | grep -qxF "$cask"; then
        new_casks+="$cask"$'\n'
    fi
done < <(echo "$installed_casks" | sort)

# Append new packages under an "Unsorted" heading
if [[ -n "$new_taps" || -n "$new_brews" || -n "$new_casks" ]]; then
    output+=$'\n'"# Unsorted (new since last organization)"$'\n'
    while IFS= read -r tap; do
        [[ -z "$tap" ]] && continue
        echo "  Added: tap \"$tap\""
        output+="tap \"$tap\""$'\n'
    done <<< "$new_taps"
    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        echo "  Added: brew \"$pkg\""
        output+="brew \"$pkg\""$'\n'
    done <<< "$new_brews"
    while IFS= read -r cask; do
        [[ -z "$cask" ]] && continue
        echo "  Added: cask \"$cask\""
        output+="cask \"$cask\""$'\n'
    done <<< "$new_casks"
fi

# Write result, squeezing runs of consecutive blank lines
printf '%s' "$output" | cat -s > "$BREWFILE"

echo
echo "Wrote $BREWFILE"
echo "Review the diff before committing:"
echo "  git diff Brewfile"
