#!/usr/bin/env bash

# =========================
# RUTAS
# =========================
CONFIG_FILE="$HOME/.config/waybar/config"
STYLE_FILE="$HOME/.config/waybar/style.css"
THEME_DIR="$HOME/.config/waybar/themes"
WALL_DIR="$HOME/Pictures/Wallpapers"
ROFI_THEME="$HOME/.config/rofi/sway.rasi"

# Líneas exactas para tu estructura actual
L_CAVA=118      # Línea de CAVA
L_CONTROL=129   # Línea de Controles

# Crear carpetas si no existen
mkdir -p "$THEME_DIR"

notify() { command -v notify-send >/dev/null && notify-send -u low "Waybar" "$1"; }

apply_waybar() {
    pkill waybar
    sleep 0.5
    waybar > /dev/null 2>&1 &
}

# =========================
# LÓGICA DE EDICIÓN DE CSS
# =========================

check_css_status() {
    local LINEA=$1
    if sed "${LINEA}q;d" "$STYLE_FILE" | grep -q "opacity: 1"; then
        echo "[ON]"
    else
        echo "[OFF]"
    fi
}

toggle_css_line() {
    local LINEA=$1
    local NOMBRE=$2

    CONTENT=$(sed "${LINEA}q;d" "$STYLE_FILE")

    if [[ "$NOMBRE" == "Controles" ]]; then
        # LÓGICA CONTROLES: Colapso total usando variables de color de tu CSS
        local ON="opacity: 1; min-width: 20px; margin: 6px 4px; padding: 10px 10px; font-size: 13px; border: 1px solid @accent-alpha; background: @bg-hover; color: @accent;"
        local OFF="opacity: 0; min-width: 0px; margin: 0px; padding: 0px; font-size: 0px; border: 0px solid transparent; "

        if echo "$CONTENT" | grep -q "opacity: 1"; then
            sed -i "${LINEA}s/.*/$OFF/" "$STYLE_FILE"
            notify "Controles: Ocultos"
        else
            sed -i "${LINEA}s/.*/$ON/" "$STYLE_FILE"
            notify "Controles: Visibles"
        fi
    else
        # LÓGICA CAVA: Solo Opacidad
        if echo "$CONTENT" | grep -q "opacity: 1"; then
            sed -i "${LINEA}s/opacity: 1/opacity: 0/" "$STYLE_FILE"
            notify "CAVA: Invisible"
        else
            sed -i "${LINEA}s/opacity: 0/opacity: 1/" "$STYLE_FILE"
            notify "CAVA: Visible"
        fi
    fi
}

# =========================
# MENÚ PRINCIPAL
# =========================
MODE=$(printf "🎨 Temas\n⚙️ Modificar Módulos\n🖼 Wallpapers\n📋 Clipboard\n📝 Notas" | rofi -dmenu -theme "$ROFI_THEME" -p "Configuración")
[ -z "$MODE" ] && exit 0

if [[ "$MODE" == "⚙️ Modificar Módulos" ]]; then
    MENU="📊 CAVA $(check_css_status $L_CAVA)\n🎵 Controles $(check_css_status $L_CONTROL)"
    CHOICE=$(printf "%b" "$MENU" | rofi -dmenu -theme "$ROFI_THEME" -p "Módulos")
    [ -z "$CHOICE" ] && exit 0
    case "$CHOICE" in
        "📊 CAVA"*)      toggle_css_line $L_CAVA "CAVA" ;;
        "🎵 Controles"*) toggle_css_line $L_CONTROL "Controles" ;;
    esac
    apply_waybar
    exit 0
fi

# =========================
# SECCIÓN TEMAS (ESTRUCTURA MAESTRA INTEGRADA)
# =========================
if [[ "$MODE" == "🎨 Temas" ]]; then
    THEMES=$(find "$THEME_DIR" -maxdepth 1 -type f -name "*.css" -printf "%f\n" | sed 's/\.css//')
    THEMES="$THEMES"$'\n'"+ Nuevo Tema"
    choice=$(printf "%s\n" "$THEMES" | rofi -dmenu -theme "$ROFI_THEME" -p "Temas")
    [ -z "$choice" ] && exit 0

    if [[ "$choice" == "+ Nuevo Tema" ]]; then
        TEMA=$(rofi -dmenu -theme "$ROFI_THEME" -p "Nombre del tema")
        [ -z "$TEMA" ] && exit 0
        BG_WIN=$(rofi -dmenu -theme "$ROFI_THEME" -p "Color Fondo Ventana (rgba)")
        BG_MAIN=$(rofi -dmenu -theme "$ROFI_THEME" -p "Color Fondo Burbuja (hex)")
        BG_HOVER=$(rofi -dmenu -theme "$ROFI_THEME" -p "Color Hover (hex)")
        ACCENT=$(rofi -dmenu -theme "$ROFI_THEME" -p "Color Acento Principal (hex)")
        ACCENT_ALPHA=$(rofi -dmenu -theme "$ROFI_THEME" -p "Color Acento Alpha (rgba)")
        TXT_MAIN=$(rofi -dmenu -theme "$ROFI_THEME" -p "Color Texto Principal (hex)")
        TXT_SOFT=$(rofi -dmenu -theme "$ROFI_THEME" -p "Color Texto Secundario (hex)")

        cat <<EOF > "$THEME_DIR/$TEMA.css"
/* =============================================================================
 * Waybar Style - ${TEMA} (Generado por Modelo Maestro)
 * ============================================================================= */

/* 1) VARIABLES VISUALES */
@define-color bg-window ${BG_WIN};
@define-color bg-main ${BG_MAIN};
@define-color bg-hover ${BG_HOVER};
@define-color bg-hover-soft ${BG_HOVER};
@define-color accent ${ACCENT};
@define-color accent-alpha ${ACCENT_ALPHA};
@define-color accent-urgent ${TXT_SOFT};
@define-color text-main ${TXT_MAIN};
@define-color text-soft ${TXT_SOFT};

* {
  border: none;
  border-radius: 16px;
  font-family: "JetBrainsMono Nerd Font", monospace;
  font-size: 13px;
  min-height: 0;
  transition: all 0.25s ease;
}

window#waybar {
  background: @bg-window;
}

/* ==============================
 * 2) BURBUJAS GENERALES
 * ============================== */
#workspaces,
#group-reloj-drawer,
#group-config-drawer,
#network,
#pulseaudio,
#backlight,
#battery,
#cpu,
#memory,
#clock,
#tray,
#window,
#custom-notification,
#custom-musica {
margin: 6px 4px;
padding: 2px 12px;
background: @bg-main;
color: @text-main;
border: 1px solid @accent-alpha;
font-weight: 600;
}

/* ==============================
 * 3) CONTROLES DE MÚSICA Y POWER
 * ============================== */
#custom-musica,
#custom-prev,
#custom-play-pause,
#custom-next,
#custom-logout,
#custom-suspend,
#custom-reboot,
#custom-power,
#custom-config-icon {
margin: 6px 4px;
padding: 6px 10px;
background: @bg-main;
color: @text-main;
border: 1px solid @accent-alpha;
font-weight: 600;
min-width: 20px;
}

/* ==============================
 * 4) HOVER GLOBAL
 * ============================== */
#workspaces:hover,
#network:hover,
#pulseaudio:hover,
#clock:hover,
#custom-prev:hover,
#custom-play-pause:hover,
#custom-next:hover,
#custom-logout:hover,
#custom-suspend:hover,
#custom-reboot:hover,
#custom-power:hover,
#custom-config-icon:hover {
border: 1px solid @accent;
background: @bg-hover;
color: @accent;
}

/* ==============================
 * 5) WORKSPACES
 * ============================== */
#workspaces button {
padding: 0 5px;
color: @text-soft;
}

#workspaces button.active {
background: @accent;
color: #1e1e2e;
}

#workspaces button.urgent {
background: @accent-urgent;
color: #1e1e2e;
}

/* ==============================
 * 6) SLIDERS Y TOOLTIP
 * ============================== */


  /* LÍNEA 118: */ #custom-musica { opacity: 1; margin: 4px; padding: 4px; }

/* L120 */
/* L121 */
/* L122 */
/* L123 */
/* L124 */
/* L125 */
/* L126 */
/* L127 */
/* L128 */
/* LÍNEA 129: */ #custom-prev, #custom-play-pause, #custom-next { opacity: 1; min-width: 20px; margin: 6px 4px; padding: 10px 10px; font-size: 13px; border: 1px solid @accent-alpha; background: @bg-hover; color: @accent; }

#custom-musica {
color: @text-soft;
background: @bg-main;
color: @text-main;
border: 1px solid @accent-alpha;
margin: 4px;
padding: 4px;
}

scale trough {
  background-color: @bg-hover;
  border-radius: 10px;
  min-width: 70px;
}

scale highlight {
  background-color: @accent;
  border-radius: 10px;
}

tooltip {
  background: #1e1e2e;
  color: @text-main;
  border: 1px solid @accent;
  border-radius: 14px;
}
EOF
        choice="$TEMA"
    fi

    ln -sf "$THEME_DIR/$choice.css" "$STYLE_FILE"
    apply_waybar
    notify "Tema aplicado: $choice"
fi

# =========================
# WALLPAPERS
# =========================
if [[ "$MODE" == "🖼 Wallpapers" ]]; then
    tmp_dir="/tmp/wallpreview"
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"

    read -r -d '' prog <<EOF
{
    path=\$0
    name=gensub(".*/", "", "g", path)

    system("cp \"" path "\" \"$tmp_dir/" name "\"")

    print name "\0icon\x1f$tmp_dir/" name
}
EOF

    WALL=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) \
        | gawk "$prog" \
        | rofi -dmenu -show-icons -theme "$ROFI_THEME" -p "Wallpapers")

    [[ -z "$WALL" ]] && exit 0

    FULL_PATH=$(find "$WALL_DIR" -type f -iname "$WALL" | head -n 1)

    export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"

    awww img "$FULL_PATH"

    notify "Fondo: $WALL"
fi


# =========================
# CLIPBOARD (IMÁGENES LIMPIAS)
# =========================
if [[ "$MODE" == "📋 Clipboard" ]]; then
    tmp_dir="/tmp/clippreview"
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"

    read -r -d '' prog <<EOF
BEGIN { img_count=0 }

{
    id=\$1
    line=\$0

    if (line ~ /binary.*(jpg|jpeg|png|bmp)/) {
        img_count++
        name="Imagen " img_count
        out="$tmp_dir/" id ".png"

        system("cliphist decode <<<" id " > " out)

        print name "\0icon\x1f" out "\0info\x1f" id
    } else {
        print line "\0info\x1f" id
    }
}
EOF

    MENU=$( (echo "🧹 Vaciar Clipboard"; cliphist list) \
        | gawk "$prog" \
        | rofi -dmenu -show-icons -theme "$ROFI_THEME" -p "Clipboard")

    [[ -z "$MENU" ]] && exit 0


    if [[ "$MENU" == "🧹 Vaciar Clipboard" ]]; then
        cliphist wipe
        notify "Clipboard limpiado"
        exit 0
    fi

    ID=$(echo "$MENU" | sed -n 's/.*\x00info\x1f//p')

    cliphist decode <<<"$ID" | wl-copy

    notify "Copiado"
fi
# =========================
# NOTAS (BLOC DE NOTAS)
# =========================
# =========================
# NOTAS (BLOC DE NOTAS)
# =========================
if [[ "$MODE" == "📝 Notas" ]]; then
    NOTES_DIR="$HOME/.config/waybar/notas"
    mkdir -p "$NOTES_DIR"

    ACTION=$(printf "📝 Nueva Nota\n📖 Ver/Editar Notas\n❌ Eliminar Nota" | rofi -dmenu -theme "$ROFI_THEME" -p "Notas")
    [[ -z "$ACTION" ]] && exit 0

    case "$ACTION" in

        "📝 Nueva Nota")
            TITLE=$(rofi -dmenu -theme "$ROFI_THEME" -p "Título")
            [[ -z "$TITLE" ]] && exit 0

            FILE="$NOTES_DIR/$TITLE.txt"

            # crear archivo vacío y abrirlo
            touch "$FILE"
            mousepad "$FILE" &

            notify "Editando: $TITLE"
        ;;

        "📖 Ver/Editar Notas")
            NOTE=$(ls "$NOTES_DIR" 2>/dev/null | rofi -dmenu -theme "$ROFI_THEME" -p "Notas")
            [[ -z "$NOTE" ]] && exit 0

            mousepad "$NOTES_DIR/$NOTE" &
        ;;

        "❌ Eliminar Nota")
            NOTE=$(ls "$NOTES_DIR" 2>/dev/null | rofi -dmenu -theme "$ROFI_THEME" -p "Eliminar")
            [[ -z "$NOTE" ]] && exit 0

            rm -f "$NOTES_DIR/$NOTE"

            notify "Nota eliminada: $NOTE"
        ;;

    esac

    exit 0
fi
