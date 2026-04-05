#!/usr/bin/env python3
import subprocess
import json
import sys
import os

def main():
    # Caracteres de barras híbridos (vertical + lateral ultra suave)
    bars_chars = [" ", "▁","▂","▃","▄","▅","▆","▇","█","▉","▊","▋","▌","▍","▎","▏"]

    # Comando para ejecutar cava
    cmd = ["cava", "-p", os.path.expanduser("~/.config/cava/config_waybar")]

    # Iniciamos el proceso
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)

    try:
        for line in process.stdout:
            # CAVA en modo ascii raw escupe: 0;1;4;...;
            values = line.strip().split(';')[:-1]
            if not values:
                continue

            bar_string = ""
            for v in values:
                try:
                    idx = int(v)
                    # Ajuste dinámico al tamaño del array (IMPORTANTE con más niveles)
                    idx = max(0, min(idx, len(bars_chars) - 1))
                    bar_string += bars_chars[idx]
                except:
                    bar_string += " "

            print(json.dumps({"text": bar_string, "icon": "󰎈"}), flush=True)

    except Exception:
        process.terminate()
        sys.exit(1)

if __name__ == "__main__":
    main()
