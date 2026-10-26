# System inventory

Audit snapshot of the source machine, taken 2026-10-27. See
`configuration-map.md` for the file-by-file default-vs-custom breakdown this
repo is built from.

## Base system

- Omarchy: `omarchy-dev 4.0.0.r7311.g2fca7fe-1`, on a local `omarchy dev-link`
  checkout at `~/omarchy` (git remote `basecamp/omarchy`, branch `quattro`,
  9 commits behind `origin/quattro` at audit time). This is a development
  setup, not a stock install -- see `packages/notes.md`.
- Arch Linux, x86_64, Hyprland (Lua-based config, Omarchy "quattro" layout)
- Shell: bash (`$SHELL`); fish is also installed but unused as the default

## What was audited and captured

- **Neovim**: LazyVim-based config at `~/.config/nvim`, heavily customized
  (34 files). Captured in full -- see `nvim/`.
- **Hyprland**: of 12 live config files, 3 contain real personal
  customization (`bindings.lua`, `looknfeel.lua`, `monitors.lua`); the rest
  are either identical to Omarchy's template or orphaned/inactive. See
  `configuration-map.md`.
- **Terminals**: alacritty, ghostty, foot, kitty, tmux all diffed against
  Omarchy's templates; all five have real personal customization, captured
  in `terminal/`. btop and starship were found identical to template and
  excluded.
- **Git**: `~/.config/git/config` diffed against Omarchy's template -- only
  the trailing `[user]`/`[credential]` blocks are personal; captured as a
  small include fragment in `git/personal.gitconfig` rather than the whole
  file.
- **GTK/Qt appearance**: theme = WhiteSur-Light (gtk) / WhiteSur-light
  (icons), font "SF Pro weight=860 11", built from source via
  `~/V4-Omarchy/WhiteSur-gtk-theme` and `WhiteSur-icon-theme`. GTK3's global
  `gtk.css` override (sharp corners) was traced to a separate theming tool
  at `~/.config/aether`, not to WhiteSur or Omarchy.
- **Firefox**: active profile resolved correctly from `profiles.ini`'s
  `[InstallXXXX]` section (`a6ojgxcr.default-release-...`), NOT the
  `[ProfileN] Default=1` flag, which points at a stale unused profile
  (`tavldzlc.default`) on this machine. `userChrome.css`/`userContent.css`
  staging directory at `~/.mozilla/firefox/firefox-themes/` confirmed
  byte-identical to what's deployed in the live profile's `chrome/` dir.
  3 real (non-built-in) extensions found.
- **OpenTabletDriver**: Huion HS64, one profile, mapped to a display region
  (X=2720, Y=450, 1600x900) that falls inside the logical bounds of
  `HDMI-A-1` as configured in `hypr/monitors.lua`. A third-party filter
  plugin ("Precision Control" by X9VoiD) is installed but disabled.
- **Packages**: `pacman -Qe` (298 explicit packages) diffed against
  Omarchy's own install manifests, not guessed. See `packages/notes.md`.

## Detected but intentionally out of scope

- **`~/.config/aether`**: a separate theme-generation application (own
  `settings.json`, wallpaper-fetching, migration state, protocol-handler
  registration) that writes theme files for alacritty, kitty, btop, vscode,
  waybar, gtk, zed, vencord, warp, zellij and more. Confirmed to be the
  actual source of this repo's `gtk/gtk-3.0/gtk.css`. Not itself captured --
  it wasn't part of the requested scope and reverse-engineering a whole
  separate app would have gone well beyond "personal customizations on top
  of Omarchy." Worth a dedicated pass if you rely on it.
- **`~/.local/bin`**: mix of pipx/uv-managed shims (`jupytext`, `sherlock`,
  `markdown_py`, `python3.13`) and a few standalone binaries (`agy` --
  ~200MB, `kimi`). None of these are hand-authored personal scripts that
  belong in a dotfiles repo; the large binary in particular should never go
  into git. Not captured.
- **`~/.config/autostart`, `~/.config/environment.d`, `~/omarchy`,
  `~/V4-Omarchy`**: present and relevant to the full desktop setup, but
  outside the explicit sections requested (Neovim/GTK/Firefox/
  OpenTabletDriver/Hyprland/packages). Noted here so you know they exist;
  not captured.

## Two Claude Code sessions worked on this task concurrently

A second session (`dotfiles-02`) had already started building this same
repo before this session began (its own `.git` init, a draft README/docs/
bootstrap scripts, and a `scripts/` directory that copied `~/.local/bin`
wholesale into the repo, including the ~200MB `agy` binary). The user
resolved the collision by having this session take over; the other session's
draft content was reviewed, and in most cases replaced with the more
rigorously-diffed version described above. The oversized `scripts/` dump and
the git object it had already written were removed before any commit.
