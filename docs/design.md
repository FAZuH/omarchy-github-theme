# Design

How this theme translates GitHub Dark into an Omarchy theme, and why each
choice was made. For wallpaper rights, see [LICENSES.md](../LICENSES.md).

## Color source

Every color comes from GitHub's official design tokens —
[`@primer/primitives` v11.10.0](https://github.com/primer/primitives),
`dist/css/functional/themes/dark.css` (fetched via jsDelivr). No
hand-picked hex values: if GitHub updates a token, the new value ports
over directly.

`colors.toml` is the single source of truth. At `omarchy theme set` time,
Omarchy regenerates kitty, ghostty, alacritty, foot, Hyprland, the shell
bar, btop, and helix configs from these keys via templates — which is why
a git-installed theme must not bundle those files (the installer drops
`*.lua`, terminal configs, and `vscode.json`).

## Token mapping

| `colors.toml` key | Primer token | Hex |
|---|---|---|
| `background` | `--bgColor-default` | `#0d1117` |
| `darker_background` | `--bgColor-inset` | `#010409` |
| `lighter_background` | `--bgColor-muted` | `#151b23` |
| `foreground` | `--fgColor-default` | `#f0f6fc` |
| `dark_foreground` | `--fgColor-muted` | `#9198a1` |
| `bright_foreground` | `--fgColor-onEmphasis` | `#ffffff` |
| `accent` | `--fgColor-accent` | `#4493f8` |
| `selection` | `--bgColor-emphasis` | `#3d444d` |
| `muted` | `--fgColor-disabled` / `--ansi-blackBright` | `#656c76` |
| `red` … `magenta` | `--ansi-*` | `#ff7b72` … `#be8fff` |
| `bright_red` … `bright_magenta` | `--ansi-*Bright` | `#ffa198` … `#d2a8ff` |
| `orange` | `--fgColor-severe` | `#db6d28` |
| `brown` | `--data-brown-color-emphasis` | `#94774c` |
| `hyprland_inactive_border` | `--borderColor-default` (classic) | `#30363d` |
| `hyprland_active_border` | accent → white gradient | `#4493f8` → `#f0f6fc` |

Two keys are derived, not tokens: `dark_background` (`#0a0d12`, one step
below default for layered surfaces) and `light_foreground` (`#d0d7de`, a
midpoint for secondary text).

## Icon layer

`icons.theme` names the GTK icon theme applied via `omarchy-theme-set-gnome`
at every `omarchy theme set`. It is `Yaru-blue-dark`, not the `Yaru-blue`
most Omarchy themes ship, for one visible reason: Yaru's non-symbolic panel
icons (`audio-volume-*`) are filled `#333` for light panels, so apps that
request the non-symbolic name — pavucontrol's mute button, for one — render
a glyph invisible on dark surfaces. The `-dark` variant resolves those names
into Yaru-dark's `#fff` panel set. Symbolic icons are unaffected either way;
GTK recolors them from the foreground.

## Wallpapers

The bundled set is personal curation, not GitHub artwork: four Arknights
pieces, one shrine-maiden illustration, one deck-crew photo. Filenames
describe content (`0-arknights-wetland-dusk.jpg`, …) so the background
switcher shows readable labels. All rights stay with the original owners —
details and takedown policy in [LICENSES.md](../LICENSES.md).

## Previews

- `preview.png` — real desktop screenshot on this theme.
- `preview-unlock.png` — real lock-screen capture (blurred wallpaper +
  themed password prompt). Captured with a timed `grim` while locked:
  arm `(sleep 5; grim out.png) &`, then `omarchy-shell lock lock`.
  Plain `loginctl lock-session` does not engage the Omarchy locker.
- `unlock.png` — recolored pixel OMARCHY mark (`#58a6ff`) used on the
  lock screen.
