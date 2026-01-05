# NeoSleceWay

![NeoSleceWay Banner](./assets/banner.gif)


**NeoSleceWay** es un **panel superior minimalista y moderno para Waybar**, diseñado para **usuarios de Sway/Hyprland**.  
Centraliza **música, sistema y aplicaciones** con un diseño elegante, colores translúcidos y bordes redondeados.

---

## 🚀 Características

### 💻 Sistema
- Red WiFi con SSID visible
- Controles de volumen integrados
- Brillo de pantalla ajustable
- Notificaciones desplegables
- Reloj y fecha con estilo

### 🎵 Música
- Carátula de la canción actual (actualización automática)
- Botones: anterior, reproducir/pausar, siguiente
- Tiempo restante de la canción
- Título y artista de la canción

> ⚠️ **Importante:** Los scripts de música dentro de `~/.config/waybar/scripts/` son críticos.  
> No modifiques archivos como `memory.py`, scripts de actualización de carátula o scripts de `playerctl`. Alterar estos archivos puede romper:
> - La actualización automática de la carátula  
> - Los botones de control de música (reproducir/pausar, siguiente, anterior)  
> - El tiempo restante de la canción  
> Siempre haz backup antes de cualquier cambio.

### 🖼 Estética
- Bordes redondeados y fondo translúcido
- Tema de colores inspirado en **Catppuccin**
- Animaciones suaves y deslizamiento de elementos
- Fuente: *DaddyTimeMono Nerd Font*

### 📂 Aplicaciones
- Drawer de aplicaciones
- Barra de tareas con íconos clicables

---

## ⚡ Instalación

1. Clona el repositorio:

```bash
git clone https://github.com/tuusuario/NeoSleceWay.git ~/.config/waybar

