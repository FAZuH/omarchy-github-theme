# Design

How this theme translates GitHub Dark into an Omarchy theme, and why each
choice was made. For wallpaper rights, see [LICENSES.md](../LICENSES.md).

## Color source

Every key in `colors.toml` is either a token from GitHub's official design
tokens
([`@primer/primitives` v11.10.0](https://github.com/primer/primitives),
`dist/css/functional/themes/dark.css`, fetched via jsDelivr) or one of the
three derived values listed below. Each token is named in a comment above
its key.

`colors.toml` is the single source of truth. At `omarchy theme set` time,
Omarchy regenerates kitty, ghostty, alacritty, foot, Hyprland, the shell
bar, btop, and helix configs from these keys via templates. That is why a
git-installed theme must not bundle those files: `omarchy theme set` skips
`*.lua`, `alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`, and
`vscode.json` at staging and names them on stderr.

`mode = "dark"` marks the theme for Omarchy's light/dark handling. It maps
to no Primer token.

## Token mapping

| `colors.toml` key | Primer token |
|---|---|
| `background` | `--bgColor-default` |
| `darker_background` | `--bgColor-inset` |
| `lighter_background` | `--bgColor-muted` |
| `foreground` | `--fgColor-default` |
| `dark_foreground` | `--fgColor-muted` |
| `bright_foreground` | `--fgColor-onEmphasis` |
| `accent` | `--fgColor-accent` |
| `selection` | `--bgColor-emphasis` |
| `muted` | `--fgColor-disabled` / `--ansi-blackBright` |
| `red` … `magenta` | `--ansi-*` |
| `bright_red` … `bright_magenta` | `--ansi-*Bright` |
| `orange` | `--fgColor-severe` |
| `brown` | `--data-brown-color-emphasis` |
| `hyprland_active_border` | `--fgColor-accent` → `--fgColor-default` gradient |

Three keys are derived, not tokens, and none of the three appear in
`dark.css` v11.10.0:

- `dark_background` (`#0a0d12`), one step below default for layered
  surfaces.
- `light_foreground` (`#d0d7de`), a midpoint for secondary text.
- `hyprland_inactive_border` (`#30363d`), a darker inactive border than
  `--borderColor-default` (`#3d444d`), which the theme already uses for
  `selection`.

## Icon layer

`icons.theme` names the GTK icon theme applied via `omarchy-theme-set-gnome`
at every `omarchy theme set`. It is `Yaru-blue-dark` rather than
`Yaru-blue`, for one visible reason: Yaru's non-symbolic panel icons
(`audio-volume-*`) are filled `#333` for light panels, so apps that
request the non-symbolic name (pavucontrol's mute button, for one) render
a glyph invisible on dark surfaces. The `-dark` variant resolves those names
into Yaru-dark's `#fff` panel set. Symbolic icons are unaffected either way;
GTK recolors them from the foreground.

## Wallpapers

The bundled set is personal curation, not GitHub artwork: four Arknights
pieces, one shrine-maiden illustration, one SpaceX photo. Filenames
describe content (`0-arknights-wetland-dusk.jpg`, …) so the background
switcher shows readable labels. All rights stay with the original owners;
details and the takedown policy are in [LICENSES.md](../LICENSES.md).

## Previews

- `preview.png`: real desktop screenshot on this theme.
- `preview-unlock.png`: real lock-screen capture (blurred wallpaper +
  themed password prompt). Captured with a timed `grim` while locked:
  arm `(sleep 5; grim out.png) &`, then `omarchy-shell lock lock`.
  Plain `loginctl lock-session` does not engage the Omarchy locker.
- `unlock.png`: recolored pixel OMARCHY mark (`#58a6ff`). Omarchy's lock
  screen does not read it; `omarchy-plymouth-set-by-theme` passes it to
  Plymouth as the boot splash logo.
