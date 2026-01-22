#!/usr/bin/env bash

# =========================
# CONFIGURACIÓN BÁSICA
# =========================

THEME_DIR="$HOME/.config/waybar/themes"
STYLE_LINK="$HOME/.config/waybar/style.css"

mkdir -p "$THEME_DIR"

# =========================
# UTILIDADES
# =========================

notify() {
    command -v notify-send >/dev/null && notify-send "$1" "$2"
}

is_hex() {
    [[ $1 =~ ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]]
}

# =========================
# MENÚ PRINCIPAL
# =========================

THEMES=$(ls "$THEME_DIR" 2>/dev/null | sed 's/\.css//g')
choice=$(printf "%s\n+ Añadir Tema" "$THEMES" | rofi -dmenu -p "Tema Waybar")

[ -z "$choice" ] && exit 0

# =========================
# CREAR NUEVO TEMA
# =========================

if [ "$choice" = "+ Añadir Tema" ]; then
    NAME=$(rofi -dmenu -p "Nombre del tema")
    [ -z "$NAME" ] && exit 0

    HEX1=$(rofi -dmenu -p "Color primario (#RRGGBB)")
    is_hex "$HEX1" || exit 0

    HEX2=$(rofi -dmenu -p "Color secundario (#RRGGBB)")
    is_hex "$HEX2" || HEX2="#aaaaaa"

    BG=$(rofi -dmenu -p "Fondo (#RRGGBB o 'transparent')")

    if [ "$BG" = "transparent" ]; then
        BG_LINE="background-color: transparent;"
        BORDER_LINE="border: none;"
    else
        is_hex "$BG" || BG="#1a1a1a"
        BG_LINE="background-color: $BG;"
        BORDER_LINE="border: 1.5px solid $HEX1;"
    fi

    FILE="$THEME_DIR/$NAME.css"

    cat <<EOF > "$FILE"
/* =========================
   Tema Waybar: $NAME
   Color primario: $HEX1
   Color secundario: $HEX2
   ========================= */

* {
    border: none;
    border-radius: 14px;
    font-size: 15px;
    min-height: 0;
}

window#waybar {
    $BG_LINE
    $BORDER_LINE
    color: #ffffff;
}

/* Grupos principales */
#workspaces, #group-music, #group-apps, #group-sistema, #group-reloj {
    background: rgba(255,255,255,0.08);
    margin: 4px 2px;
    padding: 0 8px;
}

/* Color primario */
#clock.time,
#network,
#pulseaudio,
#custom-notification,
#taskbar button.active {
    color: $HEX1;
}

#taskbar button.active {
    background-color: $HEX1;
}

/* Color secundario */
#custom-music,
#clock.date,
#network#ssid {
    color: $HEX2;
}

/* Sliders */
scale highlight {
    background-color: $HEX1;
}

/* Taskbar */
#taskbar button {
    background: rgba(255,255,255,0.1);
    margin: 4px 2px;
    padding: 0 8px;
    border-radius: 10px;
}

#taskbar button image {
    opacity: 0.6;
}

#taskbar button.active image {
    opacity: 1;
}
EOF

    notify "Tema creado" "$NAME"
    choice="$NAME"
fi

# =========================
# APLICAR TEMA
# =========================

ln -sf "$THEME_DIR/$choice.css" "$STYLE_LINK"
pkill waybar && waybar & disown
