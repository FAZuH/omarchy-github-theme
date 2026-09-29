#!/bin/bash

THUMB_TARGET_MODE="1920x1080@60"
THUMB_TARGET_SIZE="1920x1080"
THUMB_WS=99
THUMB_MUTATED=0

thumb_read() {
    local lines
    mapfile -t lines < <(hyprctl monitors -j | python3 -c '
import json, sys
m = next((x for x in json.load(sys.stdin) if x["focused"]), None)
if m is None:
    sys.exit(1)
print(m["name"])
print("%dx%d@%.2f" % (m["width"], m["height"], m["refreshRate"]))
print("%dx%d" % (m["x"], m["y"]))
print("%g" % m["scale"])
print(" ".join(m["availableModes"]))
')
    THUMB_NAME=${lines[0]}
    THUMB_MODE_NOW=${lines[1]}
    THUMB_POS=${lines[2]}
    THUMB_SCALE=${lines[3]}
    THUMB_AVAIL=${lines[4]}
}

thumb_dim() {
    hyprctl monitors -j | python3 -c '
import json, sys
m = next(x for x in json.load(sys.stdin) if x["focused"])
print("%dx%d" % (m["width"], m["height"]))
'
}

thumb_count_ws() {
    hyprctl clients -j | python3 -c '
import json, sys
ws = sys.argv[1]
print(sum(1 for c in json.load(sys.stdin) if str(c["workspace"]["id"]) == ws))
' "$1"
}

thumb_extra_layers() {
    hyprctl layers | sed -n 's/.*namespace: \([A-Za-z0-9._-]*\).*/\1/p' \
        | grep -vE '^(omarchy-background|omarchy-bar)$' | tr '\n' ' '
}

thumb_set_mode() {
    hyprctl eval "hl.monitor({ output = \"$THUMB_NAME\", mode = \"$1\", position = \"$THUMB_POS\", scale = $THUMB_SCALE })" >/dev/null
}

thumb_restore() {
    local rc=0
    if (( THUMB_MUTATED == 0 )); then return 0; fi
    THUMB_MUTATED=0
    if ! thumb_set_mode "$THUMB_MODE_NOW"; then
        rc=1
    fi
    if [[ -n $THUMB_PREV_WS ]] && ! hyprctl dispatch "hl.dsp.focus({ workspace = '$THUMB_PREV_WS' })" >/dev/null 2>&1; then
        rc=1
    fi
    return $rc
}

trap thumb_restore EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

cmd_thumbnail() {
    local c
    for c in hyprctl grim magick python3; do
        if ! command -v "$c" >/dev/null 2>&1; then
            err "$c not found"
            return 1
        fi
    done

    thumb_read
    if [[ -z $THUMB_NAME ]]; then
        err "could not read monitor state"
        return 1
    fi
    if [[ $THUMB_AVAIL != *"$THUMB_TARGET_SIZE"* ]]; then
        err "$THUMB_NAME has no $THUMB_TARGET_SIZE mode (available: $THUMB_AVAIL)"
        return 1
    fi

    local wins layers
    wins=$(thumb_count_ws "$THUMB_WS")
    if (( wins == 0 )); then
        wrn "workspace $THUMB_WS is empty: this will be a wallpaper-only shot"
    fi
    layers=$(thumb_extra_layers)
    if [[ -n $layers ]]; then
        wrn "overlay layers visible, close them first: $layers"
    fi

    THUMB_PREV_WS=$(hyprctl activeworkspace -j | python3 -c 'import json,sys;print(json.load(sys.stdin)["id"])')

    local tmp
    if ! tmp=$(mktemp /tmp/opencode/thumb-XXXXXX.png); then
        err "cannot create temp file in /tmp/opencode"
        return 1
    fi

    # this build evaluates hyprctl args as Lua: `dispatch workspace N` and `keyword monitor`
    # fail the old way, and `keyword` reports its error while still exiting 0, so eval + hl.* only
    THUMB_MUTATED=1
    hyprctl dispatch "hl.dsp.focus({ workspace = '$THUMB_WS' })" >/dev/null || { rm -f "$tmp"; return 1; }
    sleep 0.6

    thumb_set_mode "$THUMB_TARGET_MODE" \
        || { thumb_restore; rm -f "$tmp"; return 1; }

    local i
    for ((i = 0; i < 50; i++)); do
        if [[ $(thumb_dim) == "$THUMB_TARGET_SIZE" ]]; then break; fi
        sleep 0.1
    done
    if [[ $(thumb_dim) != "$THUMB_TARGET_SIZE" ]]; then
        err "panel never reached $THUMB_TARGET_SIZE"
        thumb_restore
        rm -f "$tmp"
        return 1
    fi
    sleep 1

    if ! grim "$tmp"; then
        err "grim failed"
        thumb_restore
        rm -f "$tmp"
        return 1
    fi

    if ! thumb_restore; then
        err "restore failed, run: hyprctl reload"
    fi

    local out="$SCRIPT_DIR/preview.png"
    if ! magick "$tmp" -strip "$out"; then
        rm -f "$tmp"
        return 1
    fi
    scs "wrote $out  $(magick identify -format '%wx%h' "$out")  $(du -h "$out" | cut -f1)"

    if [[ -n $THUMBNAIL_OUT ]]; then
        case $THUMBNAIL_OUT in
            *.webp) magick "$tmp" -strip -resize '1200>' -quality 80 "$THUMBNAIL_OUT" ;;
            *) magick "$tmp" -strip "$THUMBNAIL_OUT" ;;
        esac || { rm -f "$tmp"; return 1; }

        local bytes
        bytes=$(stat -c %s "$THUMBNAIL_OUT")
        scs "wrote $THUMBNAIL_OUT  $(magick identify -format '%wx%h' "$THUMBNAIL_OUT")  $((bytes / 1024))KB"
        if [[ $THUMBNAIL_OUT == *.webp ]] && (( bytes > 102400 )); then
            wrn "over the 100KB omarchy.org/themes budget, lower -quality below 80"
        fi
    fi

    rm -f "$tmp"
    return 0
}
dev_desc thumbnail "Capture a 16:9 preview on workspace $THUMB_WS (restores the panel after)"
