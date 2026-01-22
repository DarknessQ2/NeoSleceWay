#!/usr/bin/env python3
import subprocess
import shutil
import os
from urllib.parse import urlparse
from time import time

# =========================
# CONFIGURACIÓN UNIVERSAL
# =========================

ART_PATH = "/tmp/waybar-art.png"   # ⚠️ No cambiar
MAX_LEN = 20                       # Largo del título mostrado

# =========================
# FUNCIONES
# =========================

def cmd(args):
    """Ejecuta comandos de forma segura"""
    try:
        return subprocess.check_output(args, stderr=subprocess.DEVNULL).decode().strip()
    except:
        return ""

# =========================
# INICIALIZACIÓN
# =========================

# Asegura que el archivo de portada exista
if not os.path.exists(ART_PATH):
    open(ART_PATH, "wb").close()

# =========================
# OBTENER DATOS DE MÚSICA
# =========================

title = cmd(["playerctl", "metadata", "title"])
art   = cmd(["playerctl", "metadata", "mpris:artUrl"])

# =========================
# MANEJO DE PORTADA
# =========================

if art.startswith("file://"):
    src = urlparse(art).path
    if os.path.exists(src):
        try:
            shutil.copyfile(src, ART_PATH)
        except:
            pass

# Forzar refresco (Waybar cachea imágenes)
try:
    os.utime(ART_PATH, (time(), time()))
except:
    pass

# =========================
# SALIDA PARA WAYBAR
# =========================

if title:
    print(title[:MAX_LEN])
else:
    print("")
