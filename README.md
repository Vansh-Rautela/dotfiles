

| Component | Purpose | Notes |
|-----------|---------|-------|
| `nvim/` | Neovim (LazyVim) configuration | Full config with plugins, LSP, keymaps, etc. |
| `hypr/` | Hyprland personal overrides | Only custom files (monitors, bindings, input, etc.) - loaded after Omarchy defaults |
| `firefox/` | Firefox userChrome/userContent, user.js | CSS customizations and prefs; extensions must be installed manually |
| `opentabletdriver/` | OpenTabletDriver config for Huion HS64 | Preserves monitor mapping and button bindings |
| `scripts/` | Personal CLI utilities | Custom scripts installed to `~/.local/bin/` or managed separately |
| `packages/additional-packages.txt` | Extra packages needed | Only packages not provided by default Omarchy |


## Installation (Fresh Omarchy)

```bash
git clone <YOUR_DOTFILES_REPO_URL> ~/dotfiles
cd ~/dotfiles
./bootstrap/install.sh
```

## Firefox Setup

1. Files in `firefox/chrome/` are copied to your profile's `chrome/` directory
2. `user.js` is copied to your profile root (sets `toolkit.legacyUserProfileCustomizations.stylesheets` etc.)
3. Extensions need manual installation from AMO or their sources - see `firefox/extensions.md`
4. Restart Firefox after changes

## OpenTabletDriver (Huion HS64)

- Config stored in `opentabletdriver/settings.json`
- Preserves tablet-to-monitor mapping (currently mapped to HDMI-A-1 area)
- Service `opentabletdriver.service` (user) is used; installer will not enable conflicting services
- Ensure user has permissions for tablet input devices (usually handled by udev rules from package)

## Neovim

- Uses LazyVim. On first run, `lazy.nvim` will install plugins automatically
- Mason is used for LSP/formatter installation; some tools may need manual install
- External tools used: see `docs/neovim-deps.md` or Mason

## Updating
```bash
# Manually copy updated files back to dotfiles/, or use scripts to sync
# Review changes before committing
git diff
git add <files>
git commit -m "Update: <description>"
```

## Rollback

```bash
./bootstrap/restore.sh
```
Backups are stored in `~/.dotfiles-backup-<timestamp>/`

