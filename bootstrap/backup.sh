#!/usr/bin/env bash
# Back up every path this repo is about to touch, before install.sh links it.
# Safe to run standalone at any time. Writes a manifest.txt listing exactly
# which $HOME-relative paths were captured, so restore.sh can undo precisely
# that and nothing else.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./manifest.sh
source "$DOTFILES_DIR/bootstrap/manifest.sh"

BACKUP_DIR="${1:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$BACKUP_DIR"
: > "$BACKUP_DIR/manifest.txt"

backed_up=0

backup_path() {
  local rel="$1" dest="$HOME/$1"
  # Already a symlink (ours or otherwise) -> no plain file content to lose.
  [ -L "$dest" ] && return 0
  [ -e "$dest" ] || return 0
  mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  cp -a "$dest" "$BACKUP_DIR/$rel"
  echo "$rel" >> "$BACKUP_DIR/manifest.txt"
  echo "  backed up ~/$rel"
  backed_up=$((backed_up + 1))
}

echo "Backing up into $BACKUP_DIR"

for entry in "${DEPLOY_MAP[@]}"; do
  backup_path "${entry#*:}"
done

# Targets handled outside DEPLOY_MAP (merged/copied, not symlinked)
backup_path ".config/git/config"

if [ -f "$HOME/.mozilla/firefox/profiles.ini" ]; then
  profile_rel="$("$DOTFILES_DIR/bootstrap/firefox-profile.sh" 2>/dev/null || true)"
  if [ -n "$profile_rel" ]; then
    backup_path ".mozilla/firefox/$profile_rel/chrome"
    backup_path ".mozilla/firefox/$profile_rel/user.js"
  fi
fi

echo
echo "Backed up $backed_up path(s) to $BACKUP_DIR"
echo "To undo an install: ./bootstrap/restore.sh $BACKUP_DIR"
