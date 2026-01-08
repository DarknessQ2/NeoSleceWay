#!/usr/bin/env bash

# Directorio de temas
THEME_DIR="$HOME/.config/waybar/themes"
mkdir -p "$THEME_DIR"

# Obtener lista de temas existentes
THEMES=$(ls "$THEME_DIR" | sed 's/\.css//g')

# Menú principal
choice=$(printf "%s\n+ Añadir Tema" "$THEMES" | rofi -dmenu -p "Seleccionar Tema")

[ -z "$choice" ] && exit 0

if [ "$choice" == "+ Añadir Tema" ]; then
    # 1. Nombre del tema
    NAME=$(rofi -dmenu -p "Nombre del nuevo tema:")
    [ -z "$NAME" ] && exit 0

    # 2. Color Primario
    HEX1=$(rofi -dmenu -p "Color Primario (Detalles/Iconos) - Ej: #ffffff")
    [[ ! $HEX1 =~ ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]] && exit 1

    # 3. Color Secundario
    HEX2=$(rofi -dmenu -p "Color Secundario (Textos suaves) - Ej: #888888")
    [[ ! $HEX2 =~ ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]] && HEX2="#888888"

    # 4. Color de Fondo (Background)
    BG_HEX=$(rofi -dmenu -p "Color de Fondo (Ej: #1a1a1a o escribe 'transparent')")

    # Lógica para el fondo
    if [ "$BG_HEX" == "transparent" ]; then
        BG_LINE="background-color: transparent;"
        BORDER_LINE="border: none;"
    else
        # Si el usuario pone un hex, lo usamos. Si no, por defecto gris oscuro.
        [[ ! $BG_HEX =~ ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]] && BG_HEX="#1a1a1a"
        BG_LINE="background-color: $BG_HEX;"
        BORDER_LINE="border: 1.5px solid $HEX1;"
    fi

    # 5. Crear el archivo CSS
    FILENAME="$THEME_DIR/$NAME.css"

    cat <<EOF > "$FILENAME"
* {
    border: none; border-radius: 14px;
    font-family: "DaddyTimeMono Nerd Font", sans-serif;
    font-size: 15px; min-height: 0;
}

window#waybar {
    $BG_LINE
    $BORDER_LINE
    color: #e0e0e0;
}

#workspaces, #group-music, #group-apps, #group-sistema, #group-reloj {
    background: rgba(100, 100, 100, 0.2);
    margin: 4px 2px;
    padding: 0px 8px;
}

/* Color Primario */
#clock.time, #network, #taskbar button.active, #pulseaudio, #custom-notification {
    color: $HEX1;
}

#taskbar button.active {
    background-color: $HEX1;
    color: #1a1a1a;
}

scale highlight {
    background-color: $HEX1;
}

/* Color Secundario */
#custom-music, #clock.date, #network#ssid {
    color: $HEX2;
}

#custom-music-time {
    color: $HEX1;
    font-weight: bold;
}

/* Configuración de Taskbar */
#taskbar button {
    margin: 4px 2px; padding: 0px 8px; border-radius: 10px;
    background-color: rgba(255, 255, 255, 0.1);
}
#taskbar button image { padding: 2px; opacity: 0.6; }
#taskbar button.active image { opacity: 1; }
EOF

    notify-send "Tema '$NAME' creado" "Fondo: $BG_HEX | Primario: $HEX1"
    choice="$NAME"
fi

# Aplicar y reiniciar
ln -sf "$THEME_DIR/$choice.css" ~/.config/waybar/style.css
pkill waybar && waybar &
