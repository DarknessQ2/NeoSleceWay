#!/bin/bash
playerctl --follow metadata | while read -r _; do
  pkill -RTMIN+1 waybar
done
