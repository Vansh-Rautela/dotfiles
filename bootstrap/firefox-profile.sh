#!/usr/bin/env bash
# Print the relative path (under ~/.mozilla/firefox/) of the profile that
# Firefox will actually launch into.
#
# profiles.ini can contain BOTH a legacy "Default=1" flag on a [ProfileN]
# section AND an "[InstallXXXXXXXX]" section with its own Default=<path> --
# modern Firefox uses the Install section to pick the profile, and it does
# not have to agree with the legacy flag (a stale/old profile can still be
# flagged Default=1). Prefer the Install section; fall back to the legacy
# flag only if no Install section exists.
set -euo pipefail

INI="$HOME/.mozilla/firefox/profiles.ini"
[ -f "$INI" ] || exit 1

awk '
  /^\[/ {
    if (in_profile && is_default && path != "" && legacy_default == "") legacy_default = path
    if ($0 ~ /^\[Install/) { in_install = 1; in_profile = 0 }
    else if ($0 ~ /^\[Profile/) { in_profile = 1; in_install = 0; path = ""; is_default = 0 }
    else { in_install = 0; in_profile = 0 }
    next
  }
  in_install && /^Default=/   { sub(/^Default=/, ""); install_default = $0 }
  in_profile && /^Path=/      { sub(/^Path=/, ""); path = $0 }
  in_profile && /^Default=1/  { is_default = 1 }

  END {
    if (in_profile && is_default && path != "" && legacy_default == "") legacy_default = path
    if (install_default != "") print install_default
    else if (legacy_default != "") print legacy_default
  }
' "$INI"
