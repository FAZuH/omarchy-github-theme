# Usage

Beyond the [README](../README.md) happy path.

## Backgrounds

```sh
omarchy theme bg next      # cycle bundled + personal wallpapers
omarchy theme bg-switcher  # pick visually
omarchy theme bg current   # what is showing now
```

The cycle merges two pools: the theme's `backgrounds/` and your own files
in `~/.config/omarchy/backgrounds/github/`. Put personal wallpapers there —
that directory survives theme reinstalls and is never published.

## Updating

`omarchy theme install` clones the repo into
`~/.config/omarchy/themes/github`, wiping that directory first. To pull
theme updates, just install again from the repo URL (or local clone) and
re-apply with `omarchy theme set github`. Your wallpapers in
`~/.config/omarchy/backgrounds/github/` are untouched.

## Lock screen

Lock with `omarchy system lock`. The password prompt and blur follow the
theme automatically; `unlock.png` supplies the lock-screen mark.
