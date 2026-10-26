#!/usr/bin/env bash
# Deploy this repo's personal-customization layer onto an existing Omarchy
# install. Idempotent: safe to re-run. Never touches Omarchy's own files
# under /usr/share/omarchy, never reboots/restarts Hyprland/changes the
# bootloader, and only escalates privileges for package installation.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./manifest.sh
source "$DOTFILES_DIR/bootstrap/manifest.sh"

DRY_RUN=false
SKIP_PACKAGES=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --skip-packages) SKIP_PACKAGES=true ;;
    -h|--help)
      echo "Usage: $0 [--dry-run] [--skip-packages]"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

$DRY_RUN && echo "=== DRY RUN: no changes will be made ==="

echo
"$DOTFILES_DIR/bootstrap/preflight.sh" || {
  echo
  read -r -p "Preflight reported failures. Continue anyway? [y/N] " -n 1 REPLY
  echo
  [[ "$REPLY" =~ ^[Yy]$ ]] || exit 1
}

echo
if $DRY_RUN; then
  echo "[DRY RUN] Would back up any existing files at deploy targets (see bootstrap/backup.sh)"
else
  "$DOTFILES_DIR/bootstrap/backup.sh"
fi

# --- Packages -----------------------------------------------------------
install_package_list() {
  local file="$1" cmd_desc="$2"
  local -a pkgs=()
  [ -f "$file" ] || return 0
  while IFS= read -r line; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)" # trim whitespace
    [ -n "$line" ] && pkgs+=("$line")
  done < "$file"
  [ "${#pkgs[@]}" -eq 0 ] && return 0

  echo "$cmd_desc:"
  printf '  %s\n' "${pkgs[@]}"
  if $DRY_RUN; then
    echo "[DRY RUN] Would prompt to install the above"
    return 0
  fi
  read -r -p "Install missing packages from this list? [y/N] " -n 1 REPLY
  echo
  [[ "$REPLY" =~ ^[Yy]$ ]] || return 0
  "${@:3}" --needed "${pkgs[@]}" || echo "  (some packages failed -- see output above)"
}

if ! $SKIP_PACKAGES; then
  echo
  install_package_list "$DOTFILES_DIR/packages/pacman.txt" "Official-repo packages" sudo pacman -S

  aur_helper=""
  command -v yay >/dev/null 2>&1 && aur_helper=yay
  [ -z "$aur_helper" ] && command -v paru >/dev/null 2>&1 && aur_helper=paru
  if [ -n "$aur_helper" ]; then
    echo
    install_package_list "$DOTFILES_DIR/packages/aur.txt" "AUR packages (via $aur_helper)" "$aur_helper" -S
  else
    echo
    echo "No AUR helper found -- skipping packages/aur.txt (install yay/paru, or install those manually)"
  fi
fi

# --- Symlinked configs ----------------------------------------------------
deploy_link() {
  local rel_src="$1" rel_dest="$2"
  local src="$DOTFILES_DIR/$rel_src" dest="$HOME/$rel_dest"

  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
    echo "  already linked: ~/$rel_dest"
    return 0
  fi

  if $DRY_RUN; then
    echo "  [DRY RUN] would link ~/$rel_dest -> $src"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  # backup.sh already preserved any real file/dir here; safe to remove now.
  rm -rf "$dest"
  ln -s "$src" "$dest"
  echo "  linked ~/$rel_dest -> $src"
}

echo
echo "=== Deploying symlinked configs ==="
for entry in "${DEPLOY_MAP[@]}"; do
  deploy_link "${entry%%:*}" "${entry#*:}"
done

# --- Git: merge via [include], never touch Omarchy's own config file ------
echo
echo "=== Git personal config ==="
GIT_CONFIG="$HOME/.config/git/config"
if $DRY_RUN; then
  echo "  [DRY RUN] would ensure [include] path = $DOTFILES_DIR/git/personal.gitconfig in $GIT_CONFIG"
else
  mkdir -p "$(dirname "$GIT_CONFIG")"
  touch "$GIT_CONFIG"
  if grep -qF "$DOTFILES_DIR/git/personal.gitconfig" "$GIT_CONFIG" 2>/dev/null; then
    echo "  already included in $GIT_CONFIG"
  else
    {
      echo ""
      echo "[include]"
      echo "	path = $DOTFILES_DIR/git/personal.gitconfig"
    } >> "$GIT_CONFIG"
    echo "  added [include] to $GIT_CONFIG"
  fi
fi

# --- Firefox: copy (not symlink) into the active profile ------------------
echo
echo "=== Firefox ==="
if [ -f "$HOME/.mozilla/firefox/profiles.ini" ]; then
  profile_rel="$("$DOTFILES_DIR/bootstrap/firefox-profile.sh" 2>/dev/null || true)"
  if [ -n "$profile_rel" ]; then
    profile_dir="$HOME/.mozilla/firefox/$profile_rel"
    echo "  active profile: $profile_rel"
    if $DRY_RUN; then
      echo "  [DRY RUN] would copy firefox/chrome/* -> $profile_dir/chrome/"
      echo "  [DRY RUN] would copy firefox/user.js -> $profile_dir/user.js"
    else
      mkdir -p "$profile_dir/chrome"
      cp -r "$DOTFILES_DIR/firefox/chrome/." "$profile_dir/chrome/"
      cp "$DOTFILES_DIR/firefox/user.js" "$profile_dir/user.js"
      echo "  copied chrome/ and user.js into $profile_dir"
    fi
    echo "  extensions need manual install -- see firefox/extensions.md"
  else
    echo "  could not resolve the active profile from profiles.ini -- skipped"
  fi
else
  echo "  no profiles.ini found -- launch Firefox once first, then re-run install.sh"
fi

# --- OpenTabletDriver service ----------------------------------------------
echo
echo "=== OpenTabletDriver ==="
if command -v otd-daemon >/dev/null 2>&1 || pacman -Qq opentabletdriver >/dev/null 2>&1; then
  if $DRY_RUN; then
    echo "  [DRY RUN] would enable --now opentabletdriver.service"
  else
    systemctl --user enable --now opentabletdriver.service 2>&1 | sed 's/^/  /' || true
  fi
  echo "  NOTE: opentabletdriver/settings.json maps the tablet to a display area that"
  echo "  assumes HDMI-A-1 at position 1920x0, mode 1600x900@60 (see hypr/monitors.lua)."
  echo "  If your monitor layout differs, re-map the tablet area in the OpenTabletDriver GUI."
  echo "  The 'Precision Control' filter plugin is referenced in settings.json but was"
  echo "  DISABLED on the source machine and its .dll is not vendored here -- see"
  echo "  opentabletdriver/plugins/'Precision Control'/metadata.json for the download URL"
  echo "  if you want to reinstall and re-enable it."
else
  echo "  opentabletdriver not installed -- install packages/aur.txt first, then re-run"
fi

echo
echo "=== Install complete ==="
echo "Manual steps still required:"
echo "  - Neovim: plugins install automatically on first launch (lazy.nvim)"
echo "  - Firefox: restart the browser for userChrome/userContent changes to take effect"
echo "  - Firefox: install extensions listed in firefox/extensions.md"
echo "  - GTK/Qt theme: WhiteSur is built from source, not packaged -- see docs/installation.md"
echo "  - Run tests/validate.sh to sanity-check the deployed state"
