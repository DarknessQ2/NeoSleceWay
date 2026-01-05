#!/usr/bin/env bash

# Configuración del tema (puedes cambiar 'glue_pro_blue' por 'solarized' o 'network')
THEME="glue_pro_blue"

# 1. Seleccionar red Wi-Fi
# Usamos sed para limpiar el asterisco de la red actual y awk para evitar duplicados
chosen_network=$(nmcli -t -f SSID device wifi list | grep -v '^--' | awk 'NF && !seen[$0]++' | rofi -dmenu -i -theme "$THEME" -p "📡 Seleccionar Wi-Fi")

# Salir si no se selecciona nada
[ -z "$chosen_network" ] && exit 0

# 2. Comprobar si la red ya tiene una conexión guardada
# En lugar de borrar siempre, intentamos conectar. Si falla por falta de pass, pedimos.
check_connection=$(nmcli -t -f NAME connection show | grep -w "$chosen_network")

if [ -n "$check_connection" ]; then
    nmcli connection up "$chosen_network" && notify-send "Conectado" "Conexión exitosa a $chosen_network" && exit 0
fi

# 3. Pedir contraseña si es nueva o falló lo anterior
password=$(rofi -dmenu -password -theme "$THEME" -p "🔐 Contraseña para $chosen_network")

# Salir si el usuario cancela la contraseña
[ -z "$password" ] && exit 1

# 4. Intentar conectar
if nmcli device wifi connect "$chosen_network" password "$password"; then
    notify-send "Wi-Fi" "Conectado exitosamente a $chosen_network"
else
    notify-send "Error" "No se pudo conectar a $chosen_network"
fi
