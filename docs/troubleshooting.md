# Troubleshooting

## install.sh / backup.sh / restore.sh

- **"Preflight reported failures"**: usually means Omarchy itself isn't
  detected, or `git`/`pacman`/`systemctl` is missing. This repo assumes a
  working Omarchy install -- it won't bootstrap one for you.
- **Re-running install.sh seems to do nothing**: that's expected once
  everything is already linked -- `preflight.sh`/`install.sh` print
  "already linked" for anything that matches. Check `git status` in
  `~/dotfiles` if you want to confirm nothing's actually drifted.
- **A deploy target has a real file where a symlink should be**: `backup.sh`
  preserves it under `~/.dotfiles-backup-<timestamp>/` before `install.sh`
  replaces it. If you need it back, `restore.sh` reads that backup's
  `manifest.txt` and restores only those exact paths.
- **restore.sh warns "real file/dir, not the symlink this repo created"**:
  something else wrote to that path after the backup was taken. It won't
  silently overwrite that -- it writes the restored copy alongside with a
  `.restored-<timestamp>` suffix instead, so you can compare and merge by
  hand.

## Hyprland

- **`hyprctl reload` reports an error after editing `hypr/*.lua`**: check
  `hyprctl configerrors`. Since `bindings.lua`/`looknfeel.lua`/
  `monitors.lua` are symlinked back into this repo, edits are live
  immediately -- a typo breaks your running session the same way it would
  without this repo.
- **Monitor layout doesn't match `monitors.lua`**: run `hyprctl monitors
  all` to see actual connector names (`eDP-1`, `HDMI-A-1`, etc.) -- these
  vary by machine/dock/cable and `monitors.lua` hardcodes them for the
  source machine. Edit the `output = "..."` fields to match your hardware.
- **The 4 orphaned hypr files weren't restored**
  (`envs.conf`/`hypridle.conf`/`hyprlock.conf`/`hyprmodoro.conf`): confirmed
  during the audit that nothing active `require`s/sources them (idle/lock is
  handled by `omarchy-sleep-lock.service` instead). If something on your
  system actually does reference them, that's a difference from the source
  machine worth re-checking before assuming they're safe to ignore.

## OpenTabletDriver

- **Tablet area doesn't align with the monitor**: see the monitor-mapping
  caveat in `docs/installation.md` -- the display region in
  `settings.json` is tied to the source machine's exact monitor positions
  and resolutions.
- **Pen works but Precision Control filter has no effect**: it's disabled
  by default in the deployed `settings.json` (it was disabled on the source
  machine too) and its plugin binary isn't vendored -- see
  `docs/installation.md` for the reinstall URL.
- **Service not running**: `systemctl --user status
  opentabletdriver.service`; `journalctl --user -u opentabletdriver -e` for
  logs.

## Firefox

- **userChrome.css doesn't apply**: confirm
  `toolkit.legacyUserProfileCustomizations.stylesheets` is `true` in
  `about:config` (set via the deployed `user.js`, but only takes effect on
  profiles that didn't already have a conflicting value) -- and that you
  restarted Firefox, not just reloaded.
- **Wrong profile got the chrome files**: `bootstrap/firefox-profile.sh`
  resolves the profile Firefox will actually launch from the
  `[InstallXXXX]` section of `profiles.ini`. If you have multiple Firefox
  installs (e.g. stable + beta) sharing `~/.mozilla`, there may be more
  than one Install section -- this script takes whichever one appears last
  in the file. Check `~/.mozilla/firefox/profiles.ini` by hand if you have
  an unusual multi-install setup.

## Packages

- **AUR package install fails**: `packages/aur.txt` requires `yay` or
  `paru`; `install.sh` skips that file with a message if neither is found.
  Install one first, or `makepkg` each package manually.
- **A package in `packages/pacman.txt` isn't found**: a few entries
  (`cursor-bin`, `claude-desktop`, `visual-studio-code-bin`, etc.) come from
  Omarchy's own `[omarchy]` pacman repo, not core/extra. Confirm
  `/etc/pacman.conf` has an `[omarchy]` repo section (present by default on
  any Omarchy install) and `pacman -Sy` has been run.

## Not fully tested

This was audited and built on the source machine itself (Hyprland config
diffs were verified against the live Omarchy templates, the Firefox profile
resolver was tested against the live `profiles.ini`, `firefox/chrome` was
diff-verified byte-identical to the deployed profile chrome dir), but a
**fresh-machine install has not been performed**. Specifically unverified:

- Whether `packages/pacman.txt`/`aur.txt` actually installs cleanly
  end-to-end on a clean Omarchy system (only individually spot-checked a
  few package names via `pacman -Si`/`pacman -Qm`).
- Whether the WhiteSur theme install steps in `docs/installation.md`
  reproduce the exact appearance (the source machine's copies under
  `~/V4-Omarchy/` were inspected for their origin, not rebuilt from scratch
  during this pass).
- OpenTabletDriver pen/button behavior after a real redeploy to different
  hardware -- only the mapping's internal consistency (display region vs.
  `monitors.lua`) was checked, not a live tablet test on a second machine.

Shell syntax (`bash -n`) and basic structural checks are covered by
`tests/validate.sh` -- run it after any change to the bootstrap scripts.
