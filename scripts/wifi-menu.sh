#!/usr/bin/env bash

# =========================
# UTILIDADES
# =========================

notify() {
    command -v notify-send >/dev/null && notify-send "$1" "$2"
}

# =========================
# SELECCIÓN DE RED
# =========================

chosen_network=$(nmcli -t -f SSID device wifi list \
    | grep -v '^--' \
    | awk 'NF && !seen[$0]++' \
    | rofi -dmenu -i -p "📡 Seleccionar Wi-Fi")

# Cancelado
[ -z "$chosen_network" ] && exit 0

# =========================
# CONEXIÓN EXISTENTE
# =========================

if nmcli -t -f NAME connection show | grep -Fxq "$chosen_network"; then
    if nmcli connection up "$chosen_network"; then
        notify "Wi-Fi" "Conectado a $chosen_network"
        exit 0
    fi
fi

# =========================
# PEDIR CONTRASEÑA
# =========================

password=$(rofi -dmenu -password -p "🔐 Contraseña para $chosen_network")
[ -z "$password" ] && exit 1

# =========================
# CONECTAR
# =========================

if nmcli device wifi connect "$chosen_network" password "$password"; then
    notify "Wi-Fi" "Conectado a $chosen_network"
else
    notify "Error Wi-Fi" "No se pudo conectar a $chosen_network"
fi
