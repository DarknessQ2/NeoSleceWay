#!/usr/bin/env bash
# Uso: double_click.sh <modulo> <comando>

MOD="$1"
CMD="$2"
TMP="/tmp/waybar_${MOD}_click"

if [ -f "$TMP" ] && [ $(($(date +%s%3N) - $(cat "$TMP"))) -lt 400 ]; then
    # Segundo click rápido: ejecutar comando
    rm -f "$TMP"
    $CMD &
else
    # Primer click: guardar timestamp
    date +%s%3N > "$TMP"
fi
