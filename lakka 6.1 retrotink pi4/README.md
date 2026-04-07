# RetroTINK Ultimate + Lakka 6.1 + Raspberry Pi 4 (aarch64)

## Hardware

- **Raspberry Pi 4** (aarch64)
- **RetroTINK Ultimate** (conectado por GPIO/DPI)
- **CRT Sony Wega** (componente)
- **Audio** por jack 3.5mm
- **Controles** SAFFUN 2.4GHz wireless SNES (Vendor: 0079, Product: 0126)
  - Home = B12 (abre menu RetroArch)

## Diferencias con Pi 3

| | Pi 3 | Pi 4 |
|---|---|---|
| GPIO DPI | Funciona directo | Necesita `gpio=0-27=a2,np` |
| Audio jack | `hw:1,0` | `hw:2,0` (dos HDMI antes del jack) |
| GPU mem | 128MB suficiente | 128MB suficiente |
| Overlay | `vc4-kms-dpi-generic` | Igual |

## Archivos

| Archivo | Destino | Descripcion |
|---|---|---|
| `config.txt` | Raiz de SD | Config DPI + GPIO Pi 4 + timings + audio |
| `retroarch-overrides.txt` | Raiz de SD | Config RetroArch (solo primer boot) |
| `wifi-config.txt` | Raiz de SD | WiFi preconfigurado |
| `retrotink/` | Raiz de SD | Carpeta completa |
| `retrotink/SuperResolucion.ttf` | (dentro de carpeta) | Fuente custom ultra-ancha para 2048x240 |
| `retrotink/setup.sh` | (dentro de carpeta) | Script de configuracion automatica |

## Pasos despues de flashear

1. Flashear **Lakka 6.1 RPi4.aarch64** en la SD
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

6. **Verificar dispositivo de audio** (puede ser diferente a Pi 3):
   ```
   aplay -l
   ```
   El jack en Pi 4 es `hw:2,0` (card 0: vc4hdmi0, card 1: vc4hdmi1, card 2: Headphones).

7. Correr el script de setup:
   ```
   sh /flash/retrotink/setup.sh
   ```

8. Listo!

## Notas

- La Pi 4 necesita `gpio=0-27=a2,np` para activar DPI en los GPIO
- El dispositivo de audio puede ser diferente al de Pi 3 — verificar con `aplay -l`
- SSH se desactiva con cada reflasheo
- La fuente y widgets se reinstalan con `setup.sh`
- La IP puede cambiar — verificar en router o en Lakka
