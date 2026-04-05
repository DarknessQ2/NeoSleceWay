#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/sway.rasi"

notify() {
    command -v notify-send >/dev/null && notify-send -u low -i "network-wireless" "Wi-Fi Manager" "$1";
}

nmcli device wifi rescan &>/dev/null &

RAW_NETWORKS=$(nmcli --terse --fields "SSID,SECURITY,BARS" device wifi list | grep -v '^--')
SAVED_CONNS=$(nmcli --terse --fields "NAME" connection show)

MENU="󰑐  Volver a Escanear\n"
MENU+="--- \n"

while IFS=":" read -r ssid security bars; do
    [[ -z "$ssid" ]] && continue
    if echo "$SAVED_CONNS" | grep -Fxq "$ssid"; then
        MENU+="$ssid ✅ ($bars)\n"
    elif [[ "$security" != "--" ]]; then
        MENU+="$ssid 🔒 ($bars)\n"
    else
        MENU+="$ssid 󰔡 ($bars)\n"
    fi
done <<< "$RAW_NETWORKS"

MENU+="\n--- \n📂 Olvidar Red Guardada"

# Mostrar Rofi
CHOICE=$(echo -e "$MENU" | rofi -dmenu -theme "$ROFI_THEME" -p "📡 Wi-Fi" -i)
[ -z "$CHOICE" ] && exit 0

# Volver a escanear
if [[ "$CHOICE" == *"Volver a Escanear"* ]]; then
    notify "Buscando redes nuevas..."
    nmcli device wifi rescan
    sleep 1
    exec "$0"
fi

# Olvidar red
if [[ "$CHOICE" == *"Olvidar Red Guardada"* ]]; then
    SAVED_NAME=$(echo "$SAVED_CONNS" | rofi -dmenu -theme "$ROFI_THEME" -p "Seleccionar para borrar")
    [ -z "$SAVED_NAME" ] && exit 0
    nmcli connection delete "$SAVED_NAME" && notify "Red olvidada: $SAVED_NAME"
    exit 0
fi

# Conectar
SSID=$(echo "$CHOICE" | sed 's/ ✅//; s/ 🔒//; s/ 󰔡//; s/ (.*)$//')

SEC_TYPE=$(nmcli --terse --fields "SSID,SECURITY" device wifi list | grep "^$SSID:" | cut -d: -f2 | head -n1)

if echo "$SAVED_CONNS" | grep -Fxq "$SSID"; then
    notify "Conectando a $SSID..."
    nmcli connection up "$SSID" && notify "Conectado exitosamente"
else
    # Red nueva
    if [[ "$SEC_TYPE" != "--" ]]; then
        # Pedir contraseña **directamente en la misma línea de Rofi**
        PASS=$(rofi -dmenu -theme "$ROFI_THEME" -p "🔐 $SSID password" -password)
        [ -z "$PASS" ] && exit 0
        nmcli device wifi connect "$SSID" password "$PASS" && notify "Conectado y guardado" || notify "Error al conectar"
    else
        nmcli device wifi connect "$SSID" && notify "Conectado a red abierta"
    fi
fi
