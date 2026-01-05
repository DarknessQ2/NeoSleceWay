#!/usr/bin/env python3
import subprocess
import shutil
import os
from urllib.parse import urlparse
from time import time

ART = "/tmp/waybar-art.png"
PLAYER = "plasma-browser-integration"

def cmd(args):
    try:
        return subprocess.check_output(args, stderr=subprocess.DEVNULL).decode().strip()
    except:
        return ""

# 🔹 asegurar archivo desde el arranque
if not os.path.exists(ART):
    open(ART, "wb").close()

title = cmd(["playerctl", "--player", PLAYER, "metadata", "title"])
art   = cmd(["playerctl", "--player", PLAYER, "metadata", "mpris:artUrl"])

if art.startswith("file://"):
    src = urlparse(art).path
    if os.path.exists(src):
        shutil.copyfile(src, ART)

# 🔥 FORZAR CAMBIO REAL (aunque sea la misma imagen)
os.utime(ART, (time(), time()))

print(title[:20] if title else "")
