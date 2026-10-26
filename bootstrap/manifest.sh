#!/usr/bin/env bash
# Single source of truth for what this repo deploys.
# install.sh, backup.sh, and restore.sh all source this file so the list of
# managed paths can never drift between them.
#
# DEPLOY_MAP entries are "repo/relative/path:$HOME/relative/path".
# Directories are deployed as a single symlink (the whole dir becomes a link
# into the repo). Files are deployed as individual symlinks.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DEPLOY_MAP=(
  "nvim:.config/nvim"
  "hypr/bindings.lua:.config/hypr/bindings.lua"
  "hypr/looknfeel.lua:.config/hypr/looknfeel.lua"
  "hypr/monitors.lua:.config/hypr/monitors.lua"
  "terminal/alacritty/alacritty.toml:.config/alacritty/alacritty.toml"
  "terminal/ghostty/config:.config/ghostty/config"
  "terminal/foot/foot.ini:.config/foot/foot.ini"
  "terminal/kitty/kitty.conf:.config/kitty/kitty.conf"
  "terminal/tmux/tmux.conf:.config/tmux/tmux.conf"
  "gtk/gtk-3.0/settings.ini:.config/gtk-3.0/settings.ini"
  "gtk/gtk-3.0/gtk.css:.config/gtk-3.0/gtk.css"
  "gtk/gtk-4.0/settings.ini:.config/gtk-4.0/settings.ini"
  "gtk/gtkrc-2.0:.gtkrc-2.0"
  "opentabletdriver/settings.json:.config/OpenTabletDriver/settings.json"
)

# Handled separately in install.sh/backup.sh/restore.sh because they don't
# follow the simple "symlink into $HOME" pattern:
#   - git/personal.gitconfig   -> merged via `[include]` in ~/.config/git/config
#   - firefox/chrome, user.js  -> copied (not symlinked) into the active profile
