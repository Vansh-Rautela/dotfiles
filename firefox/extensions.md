# Firefox extensions

Read from the active profile's `extensions.json` on the source machine.
Firefox doesn't support reliably exporting/restoring extension installs or
their internal settings from the CLI, so these need manual reinstall.

| Name | Extension ID | Source | Notes |
|------|-------------|--------|-------|
| uBlock Origin | `uBlock0@raymondhill.net` | [AMO](https://addons.mozilla.org/firefox/addon/ublock-origin/) | Filter lists/custom rules are stored in the extension's own IndexedDB storage, not exported here -- reconfigure manually if customized. |
| Enhancer for YouTube | `enhancerforyoutube@maximerf.addons.mozilla.org` | [AMO](https://addons.mozilla.org/firefox/addon/enhancer-for-youtube/) | Settings not exported. |
| Sidebery | `{3c078156-979c-498b-8990-85f7987dd929}` | [AMO](https://addons.mozilla.org/firefox/addon/sidebery/) | Tree-style sidebar; its layout/tab-group state is session data, not exported. |

`newtab@mozilla.org` also appears in `extensions.json` but is Firefox's own
built-in New Tab component, not something you installed -- no action needed.

## Restoration steps

1. Run `bootstrap/install.sh` (or copy `firefox/chrome/*` and `firefox/user.js`
   manually) so `toolkit.legacyUserProfileCustomizations.stylesheets` is set
   and the userChrome/userContent CSS is in place.
2. Open Firefox, go to `about:addons`, and install each extension above from
   AMO (or paste its AMO page URL into the address bar).
3. For uBlock Origin: if you had custom filter lists or "My filters" rules
   beyond the defaults, you'll need to re-add them manually (Settings ->
   re-enable lists you used, or paste custom rules back in) -- this repo has
   no record of them.
4. For Sidebery: reconfigure sidebar panels/tree behavior to taste; tab
   groups/tree state don't survive a reinstall regardless.
5. Restart Firefox.
