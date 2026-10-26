#!/usr/bin/env bash
# Undo an install using a backup created by backup.sh (or by install.sh,
# which calls backup.sh automatically before linking anything).
#
# Only touches the exact $HOME-relative paths listed in that backup's
# manifest.txt -- never anything broader (no deleting unrelated parts of
# ~/.config).
set -euo pipefail

usage() {
  echo "Usage: $0 [path-to-backup-dir]"
  echo
  echo "Available backups:"
  ls -1d "$HOME"/.dotfiles-backup-* 2>/dev/null || echo "  (none found)"
}

BACKUP_DIR="${1:-}"
if [ -z "$BACKUP_DIR" ]; then
  usage
  echo
  read -r -p "Enter backup directory to restore from: " BACKUP_DIR
fi

if [ ! -d "$BACKUP_DIR" ]; then
  echo "Not a directory: $BACKUP_DIR" >&2
  exit 1
fi
if [ ! -f "$BACKUP_DIR/manifest.txt" ]; then
  echo "No manifest.txt in $BACKUP_DIR -- refusing to guess what to restore." >&2
  exit 1
fi

echo "Restoring from $BACKUP_DIR"
restored=0

while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  src="$BACKUP_DIR/$rel"
  dest="$HOME/$rel"

  if [ ! -e "$src" ]; then
    echo "  skip ~/$rel (missing in backup)"
    continue
  fi

  # Only remove the exact target path -- if it's our symlink, unlink it;
  # if a real file/dir got there some other way since the backup, leave it
  # and warn rather than silently destroying unrelated changes.
  if [ -L "$dest" ]; then
    rm -f "$dest"
  elif [ -e "$dest" ]; then
    echo "  WARNING: ~/$rel is a real file/dir, not the symlink this repo created." \
         "Leaving it in place; restored copy written to ${dest}.restored-$(date +%s) instead." >&2
    dest="${dest}.restored-$(date +%s)"
  fi

  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
  echo "  restored ~/$rel"
  restored=$((restored + 1))
done < "$BACKUP_DIR/manifest.txt"

echo
echo "Restored $restored path(s) from $BACKUP_DIR"
