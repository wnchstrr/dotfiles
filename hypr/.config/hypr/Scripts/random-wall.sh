#!/usr/bin/env bash
# Случайные обои через hyprpaper IPC + запись в source-конфиг для персистентности
set -euo pipefail

WALL_DIRS=("$HOME/Pictures/Wallpapers" "$HOME/Pictures/walls")
MONITOR="${1:-eDP-2}"
STATE_CONF="$HOME/.cache/hypr/current-wall.conf"

# случайный файл нужных форматов, .git исключён
wall=$(find "${WALL_DIRS[@]}" -type d -name .git -prune -o \
    -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print \
    | shuf -n 1)

[ -z "$wall" ] && { notify-send "random-wall" "Нет картинок"; exit 1; }

# сменить сейчас (текущая сессия)
hyprctl hyprpaper wallpaper "$MONITOR, $wall, cover"

# записать для следующего старта (hyprpaper прочитает через source)
mkdir -p "$(dirname "$STATE_CONF")"
cat > "$STATE_CONF" << CONF
wallpaper {
    monitor = $MONITOR
    path = $wall
    fit_mode = cover
}
CONF
