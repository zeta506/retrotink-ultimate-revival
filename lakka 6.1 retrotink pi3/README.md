# RetroTINK Ultimate + Lakka 6.1 + Raspberry Pi 3 (aarch64)

## Hardware

- **Raspberry Pi 3** (aarch64)
- **RetroTINK Ultimate** (conectado por GPIO/DPI)
- **CRT Sony Wega** (componente)
- **Audio** por jack 3.5mm
- **Controles** SAFFUN 2.4GHz wireless SNES (Vendor: 0079, Product: 0126)
  - Home = B12 (abre menu RetroArch)

## Archivos

| Archivo | Destino | Descripcion |
|---|---|---|
| `config.txt` | Raiz de SD | Config DPI + timings + audio |
| `retroarch-overrides.txt` | Raiz de SD | Config RetroArch (solo primer boot) |
| `wifi-config.txt` | Raiz de SD | WiFi preconfigurado |
| `retrotink/` | Raiz de SD | Carpeta completa |
| `retrotink/SuperResolucion.ttf` | (dentro de carpeta) | Fuente custom ultra-ancha para 2048x240 |
| `retrotink/setup.sh` | (dentro de carpeta) | Script de configuracion automatica |

## Pasos despues de flashear

1. Flashear **Lakka 6.1 RPi3.aarch64** en la SD
   - Descarga: https://www.lakka.tv/get/linux/rpi/

2. Copiar todos los archivos a la raiz de la SD (`F:\` o la letra que tenga):
   - `config.txt`
   - `retroarch-overrides.txt`
   - `wifi-config.txt`
   - `retrotink/` (carpeta completa)

3. Insertar SD en la Pi y encender

4. En el menu de Lakka: **Main Menu > Services > SSH > ON**

5. Desde PowerShell en la PC:
   ```
   ssh-keygen -R 192.168.1.37
   ssh root@192.168.1.37
   ```
   Contrasena: `root`

6. Correr el script de setup:
   ```
   sh /flash/retrotink/setup.sh
   ```

7. Listo!

## Que hace cada archivo

### config.txt
- Salida DPI 24-bit por GPIO usando `vc4-kms-dpi-generic`
- Timings **2048x240p @ 60Hz** NTSC (reloj SNES/NES)
- Audio habilitado por jack 3.5mm
- HDMI desactivado

### retroarch-overrides.txt (solo primer boot)
- Menu RGUI con aspect ratio 4:3
- Widgets desactivados, texto OSD con fuente SuperResolucion
- VSync, integer scaling, threaded video
- Audio ALSA `hw:1,0` (jack)
- Home (B12) abre menu
- Rewind desactivado (rendimiento Pi 3)

### setup.sh
- Copia fuente SuperResolucion a `/storage/fonts/`
- Activa SSH permanentemente
- Desactiva `menu_enable_widgets` (RetroArch lo sobreescribe al reiniciar)
- Aplica fuente y audio al config de RetroArch

### wifi-config.txt
- SSID: `########`

## Timings disponibles

Editar `config.txt` y descomentar solo uno:

| Modo | Resolucion | Clock |
|---|---|---|
| **240p NTSC** (activo) | 2048x240 @ 60Hz | 42954545 |
| 480p | 2048x480 @ 60Hz | 85909090 |
| 720p | 1280x720 @ 60Hz | 74239049 |
| 240p 120Hz | 1920x240 @ 120Hz | 75170000 |

Hay una carpeta `lakka 6.1 retrotink 480i` con config para 480i interlaced.

## Fuente SuperResolucion

Fuente TTF custom generada con `generate_font.py`. Diseñada para compensar la compresion horizontal de 2048x240 en un CRT 4:3:

- **Ratio**: bloques 768x120 (6.4:1) para que se vean cuadrados en pantalla
- **Estilo**: bloques cuadrados, sin curvas
- **Ancho variable**: signos de puntuacion mas estrechos que letras
- Para regenerar: `py generate_font.py`

## Notas

- SSH se desactiva con cada reflasheo, hay que activarlo manualmente
- La fuente se borra con cada reflasheo, `setup.sh` la reinstala
- `menu_enable_widgets` se sobreescribe al reiniciar RetroArch, `setup.sh` lo corrige parando RetroArch antes de editarlo
- La IP puede cambiar, verificar en el router o en Lakka: **Main Menu > Information > Network Information**
