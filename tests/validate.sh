#!/usr/bin/env bash
# Structural sanity checks that don't require touching the live system.
# Safe to run anywhere, anytime -- no side effects.
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

fail=0
check() { echo "  OK   $1"; }
bad()   { echo "  FAIL $1"; fail=$((fail + 1)); }

echo "=== Shell syntax ==="
for f in bootstrap/*.sh; do
  if bash -n "$f" 2>/tmp/validate-err; then
    check "$f"
  else
    bad "$f: $(cat /tmp/validate-err)"
  fi
done
rm -f /tmp/validate-err

if command -v shellcheck >/dev/null 2>&1; then
  echo
  echo "=== shellcheck ==="
  for f in bootstrap/*.sh tests/*.sh; do
    if shellcheck -S warning "$f"; then
      check "$f"
    else
      bad "$f: shellcheck warnings above"
    fi
  done
else
  echo
  echo "  (shellcheck not installed -- skipping lint pass)"
fi

echo
echo "=== manifest.sh DEPLOY_MAP sources exist ==="
# shellcheck source=../bootstrap/manifest.sh
source "$DOTFILES_DIR/bootstrap/manifest.sh"
for entry in "${DEPLOY_MAP[@]}"; do
  src="${entry%%:*}"
  if [ -e "$DOTFILES_DIR/$src" ]; then
    check "$src"
  else
    bad "$src: listed in DEPLOY_MAP but missing from the repo"
  fi
done

echo
echo "=== No obviously-oversized files (>5MB) ==="
while IFS= read -r -d '' f; do
  bad "unexpectedly large file: $f ($(du -h "$f" | cut -f1))"
done < <(find . -path ./.git -prune -o -type f -size +5M -print0)

echo
echo "=== No obvious secrets ==="
pattern='BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY|AKIA[0-9A-Z]{16}|xox[baprs]-'
if grep -RInE "$pattern" --exclude-dir=.git . ; then
  bad "possible secret material matched above"
else
  check "no private-key/AWS-key/Slack-token patterns found"
fi

echo
echo "=== Firefox profile resolver (informational, depends on local machine) ==="
if [ -f "$HOME/.mozilla/firefox/profiles.ini" ]; then
  resolved="$(bash "$DOTFILES_DIR/bootstrap/firefox-profile.sh" 2>/dev/null || true)"
  if [ -n "$resolved" ]; then
    check "resolved active profile: $resolved"
  else
    bad "could not resolve an active profile from profiles.ini"
  fi
else
  echo "  (no local profiles.ini -- skipping, not a repo problem)"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "All checks passed."
else
  echo "$fail check(s) failed."
fi
exit "$fail"
