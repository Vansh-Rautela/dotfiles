# Package notes

## How this list was built

`pacman -Qe` (explicitly installed packages) on the source machine was diffed
against Omarchy's own install manifests (`omarchy-base.packages`,
`omarchy-x86_64-only.packages`, `omarchy-other.packages`, read from the
Omarchy source checkout) -- not against "common sense." That brought ~298
explicit packages down to ~124 genuinely additional ones, split here into
`pacman.txt` (installable from core/extra/multilib/Omarchy's own `[omarchy]`
repo -- confirmed via `pacman -Si`) and `aur.txt` (confirmed foreign via
`pacman -Qm`, needs an AUR helper).

## Deliberately excluded

**Base-system packages** present on any Arch install regardless of Omarchy:
`linux`, `linux-headers`, `intel-ucode`, `sudo`. Installing these from a
dotfiles repo doesn't make sense -- they're handled by the Arch install
itself / kernel management.

**Detected but not installed (legacy, superseded by Omarchy quattro's
Quickshell-based bar):** `waybar`, `waybar-module-pacman-updates-git`,
`wttrbar`, `wttrbar-debug`. `waybar.service` is disabled and no `waybar`
process was running at audit time; several `waybar*.omarchy-upgrade-to-
quattro.*.bak` directories under `~/.config/` confirm this is leftover from
before the quattro bar switch. Not included here -- reinstall manually if
you actually still want waybar as a fallback bar.

**Omarchy dev-build packages** (`omarchy-dev`, `omarchy-keyring`,
`omarchy-settings-dev`): the source machine runs `omarchy-dev` with a local
`omarchy dev-link`'d git checkout on the `quattro` branch, tracking
`basecamp/omarchy` upstream. That's a development setup for working on
Omarchy itself, not a personal customization -- not included here. If you
want to replicate that specific setup, see Omarchy's own `CONTRIBUTING`/dev
docs, not this repo.

## Theming is NOT fully captured by these package lists

- **GTK theme (WhiteSur-Light) and icon theme (WhiteSur-light)** are built
  from source, not packaged. The source machine has working clones at
  `~/V4-Omarchy/WhiteSur-gtk-theme` and `~/V4-Omarchy/WhiteSur-icon-theme`
  (each has its own `install.sh`). To reproduce: clone both repos and run
  their installers, then select the theme via `nwg-look` or
  `gsettings set org.gnome.desktop.interface gtk-theme WhiteSur-Light`.
  See `docs/installation.md` for the exact commands.
- `orchis-theme` and `papirus-icon-theme` above ARE packaged (pacman), but
  were not the ones actually selected in `gtk/gtk-3.0/settings.ini` /
  `gtk/gtk-4.0/settings.ini` on the source machine -- they were present on
  disk as alternatives/leftovers. Install if you want them as options.

## Not captured at all: "Aether"

A separate theme-generation tool was found at `~/.config/aether` (its own
`settings.json`, wallpaper-fetching config, migration state) that writes
theme files for many apps (alacritty, kitty, btop, vscode, waybar, gtk,
zed, vencord, warp, zellij...). It's confirmed to be the actual source of
`gtk/gtk-3.0/gtk.css` in this repo (the "Aether Theme with Sharp Corners"
header). It was NOT otherwise captured or deeply investigated -- it wasn't
part of the original request, and reverse-engineering a whole separate
application was out of scope for this pass. If you use it deliberately,
worth auditing and capturing properly in a follow-up.
