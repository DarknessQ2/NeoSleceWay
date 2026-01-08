#!/usr/bin/env bash

STATE=$(nmcli -t -f WIFI g)

if [ "$STATE" != "enabled" ]; then
  echo '{"text":"󰤮","tooltip":"Wi-Fi apagado"}'
  exit 0
fi

ACTIVE=$(nmcli -t -f DEVICE,STATE dev | grep ":connected")

if [ -z "$ACTIVE" ]; then
  echo '{"text":"󰤯","tooltip":"Desconectado"}'
  exit 0
fi

SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2)

echo "{\"text\":\"󰤨 $SSID\",\"tooltip\":\"Conectado a $SSID\"}"
