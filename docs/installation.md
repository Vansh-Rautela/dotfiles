# Installation

Assumes a working Omarchy install already exists. This repo only layers
personal customizations on top -- it never installs Omarchy itself.

## Quick start

```bash
git clone <YOUR_DOTFILES_REPO_URL> ~/dotfiles
cd ~/dotfiles
./bootstrap/install.sh --dry-run   # preview every change first
./bootstrap/install.sh
```

Re-running `install.sh` is safe -- already-correct symlinks are detected and
skipped, and packages already installed are left alone (`--needed`).

## What install.sh does, in order

1. `bootstrap/preflight.sh` -- read-only checks (Omarchy present? git/pacman/
   systemctl available? what already exists at each deploy target?). Asks
   before continuing if anything failed.
2. `bootstrap/backup.sh` -- copies every real file/dir currently at a deploy
   target into `~/.dotfiles-backup-<timestamp>/`, with a `manifest.txt` of
   exactly what it touched.
3. Prompts to install `packages/pacman.txt` via `pacman -S --needed`, then
   `packages/aur.txt` via `yay`/`paru` if one is installed (skipped with a
   message otherwise).
4. Symlinks every entry in `bootstrap/manifest.sh`'s `DEPLOY_MAP` from the
   repo into `$HOME`.
5. Adds an `[include]` to `~/.config/git/config` pointing at
   `git/personal.gitconfig`, without touching Omarchy's own aliases/defaults
   in that file. Safe to re-run (checked for idempotency).
6. Resolves the actually-active Firefox profile (see
   `bootstrap/firefox-profile.sh` -- prefers the `[InstallXXXX]` section over
   the legacy `Default=1` flag, which can point at a stale profile) and
   copies `firefox/chrome/` + `firefox/user.js` into it.
7. Enables `opentabletdriver.service` if the package is installed, and
   prints the monitor-mapping caveat below.

`--skip-packages` skips step 3 if you'd rather install packages yourself.

## Neovim

Nothing extra to do -- on first launch, `lazy.nvim` installs all plugins
automatically. LSP servers/formatters/linters are managed through Mason from
inside Neovim (`:Mason`); none are vendored in this repo.

## GTK/Qt theme (WhiteSur)

Not packaged -- built from source. If you want the exact appearance:

```bash
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-gtk-theme && ./install.sh
cd ../WhiteSur-icon-theme && ./install.sh
```

Then select the theme (install.sh already deploys the `settings.ini` files
that reference it, so this just needs the theme files to exist):

```bash
nwg-look   # or: gsettings set org.gnome.desktop.interface gtk-theme WhiteSur-Light
```

## OpenTabletDriver (Huion HS64)

`install.sh` deploys `opentabletdriver/settings.json` and enables the
service. Two things to verify afterward:

1. **Monitor mapping is machine-specific.** The deployed profile maps the
   tablet to a display region that assumes `HDMI-A-1` at position `1920x0`,
   mode `1600x900@60` (exactly what `hypr/monitors.lua` configures). If your
   monitor layout differs, open the OpenTabletDriver GUI and redraw the
   display area to match your actual external monitor's position/resolution
   -- don't assume it'll just work.
2. **"Precision Control" filter plugin** is referenced in `settings.json`
   but was disabled on the source machine, and its compiled `.dll` is not
   vendored here. If you want it: open OpenTabletDriver's plugin manager and
   install from
   `https://github.com/X9VoiD/VoiDPlugins/releases/download/0.4.1/PrecisionControl.zip`
   (URL also recorded in
   `opentabletdriver/plugins/Precision Control/metadata.json`), then
   re-enable the filter in the GUI if desired.

Check detection with `otd-gui` or `systemctl --user status
opentabletdriver.service`; confirm pen/button mapping against
`opentabletdriver/settings.json`'s `Bindings` section (Ctrl+Z on tip, H on
eraser button, express keys bound to Keypad0/2/7 and Ctrl+Z).

## Firefox

`install.sh` copies the chrome CSS and `user.js` into whichever profile
Firefox will actually launch (resolved from `profiles.ini`, not guessed).
Restart Firefox afterward. Extensions need manual installation -- see
`firefox/extensions.md`.

## Rollback

```bash
./bootstrap/restore.sh                       # lists backups, prompts for one
./bootstrap/restore.sh ~/.dotfiles-backup-20261027-004512   # or specify directly
```

Only restores the exact paths listed in that backup's `manifest.txt` --
never anything broader.
