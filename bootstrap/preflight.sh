#!/usr/bin/env bash
# Read-only environment check. Safe to run any time; makes no changes.
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./manifest.sh
source "$DOTFILES_DIR/bootstrap/manifest.sh"

ok=0
warn=0
fail=0

pass()  { echo "  OK   $1"; ok=$((ok + 1)); }
warning() { echo "  WARN $1"; warn=$((warn + 1)); }
fail_()  { echo "  FAIL $1"; fail=$((fail + 1)); }

echo "=== Preflight: environment ==="
if [ -f /etc/os-release ]; then
  pretty="$(. /etc/os-release && echo "$PRETTY_NAME")"
  pass "OS: $pretty"
else
  warning "No /etc/os-release found"
fi

if [ -d /usr/share/omarchy ]; then
  if command -v omarchy >/dev/null 2>&1; then
    pass "Omarchy detected: $(omarchy version 2>/dev/null || echo 'version unknown')"
  else
    pass "Omarchy detected at /usr/share/omarchy"
  fi
else
  fail_ "Omarchy not detected at /usr/share/omarchy -- this repo assumes Omarchy is already installed"
fi

echo
echo "=== Preflight: required tools ==="
for cmd in git pacman systemctl; do
  if command -v "$cmd" >/dev/null 2>&1; then
    pass "$cmd found"
  else
    fail_ "$cmd missing"
  fi
done
if command -v yay >/dev/null 2>&1 || command -v paru >/dev/null 2>&1; then
  pass "AUR helper found"
else
  warning "No AUR helper (yay/paru) found -- some packages/aur-packages.txt entries will need manual install"
fi

echo
echo "=== Preflight: existing config at deploy targets ==="
for entry in "${DEPLOY_MAP[@]}"; do
  dest_rel="${entry#*:}"
  dest="$HOME/$dest_rel"
  if [ -L "$dest" ]; then
    link_target="$(readlink -f "$dest" 2>/dev/null || true)"
    repo_target="$(readlink -f "$DOTFILES_DIR/${entry%%:*}" 2>/dev/null || true)"
    if [ "$link_target" = "$repo_target" ]; then
      pass "$dest_rel already linked to this repo"
    else
      warning "$dest_rel is a symlink to something else ($link_target)"
    fi
  elif [ -e "$dest" ]; then
    warning "$dest_rel exists and will be backed up before linking"
  else
    pass "$dest_rel does not exist yet (clean install)"
  fi
done

echo
echo "=== Preflight: Firefox ==="
if [ -f "$HOME/.mozilla/firefox/profiles.ini" ]; then
  pass "Firefox profiles.ini found"
else
  warning "No Firefox profiles.ini -- run Firefox once before installing chrome customizations"
fi

echo
echo "=== Preflight: OpenTabletDriver ==="
if command -v otd-daemon >/dev/null 2>&1 || pacman -Qq opentabletdriver >/dev/null 2>&1; then
  pass "OpenTabletDriver package present"
else
  warning "OpenTabletDriver not installed -- install.sh can install it via the AUR helper"
fi

echo
echo "=== Summary: $ok ok, $warn warnings, $fail failures ==="
[ "$fail" -eq 0 ]
