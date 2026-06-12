#!/usr/bin/env bash
#
# install.sh — развёртывание dotfiles на новой машине
# Запускать из корня репо: ~/dotfiles/install.sh
#
# Что делает:
#   1. Stow всех пакетов (создаёт симлинки в ~/.config и ~)
#   2. Клонирует TPM (менеджер плагинов tmux)
#   3. Клонирует nvim-config (отдельный репо)
#   4. Восстанавливает GTK-тему/иконки/курсор из dconf-дампа
#   5. Копирует userChrome/userContent тему в активный профиль Thunderbird

set -euo pipefail  # стоп при первой ошибке, неинициализированной переменной, ошибке в пайпе

# Корень репо = папка, где лежит сам скрипт (работает из любого cwd)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Пакеты Stow (имена папок в репо)
PACKAGES=(ghostty zsh tmux hypr rofi waybar environment)

echo "==> Проверка зависимостей"
for cmd in stow git dconf; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ОШИБКА: '$cmd' не установлен. Поставь: sudo apt install $cmd"
        exit 1
    fi
done

echo "==> Stow пакетов: ${PACKAGES[*]}"
for pkg in "${PACKAGES[@]}"; do
    if [[ -d "$pkg" ]]; then
        stow -v --restow --target="$HOME" "$pkg"
    else
        echo "  пропуск: пакета '$pkg' нет в репо"
    fi
done

echo "==> TPM (менеджер плагинов tmux)"
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
    echo "  уже есть, пропуск"
else
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "  установлен. Внутри tmux нажми: prefix + I — поставит плагины"
fi

echo "==> nvim-config"
NVIM_DIR="$HOME/.config/nvim"
if [[ -d "$NVIM_DIR" ]]; then
    echo "  ~/.config/nvim уже существует, пропуск"
else
    git clone git@github.com:wnchstrr/nvim-config "$NVIM_DIR"
fi

echo "==> Восстановление GTK-темы (dconf)"
DCONF_FILE="$DOTFILES_DIR/gtk-interface.dconf"
if [[ -f "$DCONF_FILE" ]]; then
    dconf load /org/gnome/desktop/interface/ < "$DCONF_FILE"
    echo "  тема/иконки/курсор восстановлены"
else
    echo "  пропуск: $DCONF_FILE не найден"
fi

echo "==> Тема Thunderbird (userChrome/userContent)"
# Профиль TB машинозависим (имя сгенерировано), поэтому ищем его в profiles.ini,
# а не симлинкаем через stow. Тема — это файлы в <профиль>/chrome/.
TB_DIR="$HOME/.thunderbird"
TB_THEME_SRC="$DOTFILES_DIR/thunderbird/chrome"
if [[ -d "$TB_THEME_SRC" && -f "$TB_DIR/profiles.ini" ]]; then
    # Берём путь default-профиля из profiles.ini (строка Path= у Default=1)
    profile=$(awk -F= '/^Path=/{p=$2} /^Default=1/{print p; exit}' "$TB_DIR/profiles.ini")
    if [[ -n "$profile" && -d "$TB_DIR/$profile" ]]; then
        mkdir -p "$TB_DIR/$profile/chrome"
        cp "$TB_THEME_SRC"/*.css "$TB_DIR/$profile/chrome/"
        echo "  тема скопирована в $profile/chrome/"
        echo "  ВКЛЮЧИ в TB: Settings → Config Editor →"
        echo "    toolkit.legacyUserProfileCustomizations.stylesheets = true, перезапусти TB"
    else
        echo "  пропуск: не нашёл default-профиль в profiles.ini"
    fi
else
    echo "  пропуск: нет thunderbird/chrome или TB ещё не запускался (нет profiles.ini)"
fi

echo ""
echo "==> Готово."
echo "    Не забудь вручную:"
echo "      - tmux: prefix + I (плагины)"
echo "      - TB: включить legacyUserProfileCustomizations.stylesheets (см. выше)"
echo "      - Пакеты ставить НЕ через snap (система snap-free):"
echo "          apt → ghostty, waybar, rofi, swaybg, swaync, hyprshot, stow..."
echo "          tarball → Thunderbird (~/.local/lib), Telegram (/opt)"
echo "          flatpak → Signal (org.signal.Signal)"
echo "          Mozilla apt repo → Firefox (см. README про pinning)"
