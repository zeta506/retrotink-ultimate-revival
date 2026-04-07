# RetroTINK Ultimate + Lakka 6.1 + Raspberry Pi 5 (aarch64)

## Hardware

- **Raspberry Pi 5** (aarch64)
- **RetroTINK Ultimate** (conectado por GPIO/DPI)
- **CRT Sony Wega** (componente)
- **Audio** por jack 3.5mm
- **Controles** SAFFUN 2.4GHz wireless SNES (Vendor: 0079, Product: 0126)
  - Home = B12 (abre menu RetroArch)

## Ventajas de Pi 5

- **480i interlazado nativo** via chip RP1 (Pi 3/4 no lo soportan)
- Mayor rendimiento para emuladores mas exigentes (N64, PSP, Dreamcast)
- Mismo overlay `vc4-kms-dpi-generic`

## Archivos

| Archivo | Destino | Descripcion |
|---|---|---|
| `config.txt` | Raiz de SD | Config DPI 240p (por defecto) |
| `config_480i.txt` | Respaldo | Config DPI 480i interlazado nativo |
| `retroarch-overrides.txt` | Raiz de SD | Config RetroArch (solo primer boot) |
| `wifi-config.txt` | Raiz de SD | WiFi preconfigurado |
| `retrotink/` | Raiz de SD | Carpeta completa |
| `retrotink/SuperResolucion.ttf` | (dentro de carpeta) | Fuente custom ultra-ancha para 2048x240 |
| `retrotink/setup.sh` | (dentro de carpeta) | Script de configuracion automatica |

## Pasos despues de flashear

1. Flashear **Lakka 6.1 RPi5.aarch64** en la SD
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

6. **Verificar dispositivo de audio** (puede ser diferente a Pi 3/4):
   ```
   aplay -l
   ```
   Si el jack NO es `hw:1,0`, editar el setup.sh antes de correrlo.

7. Correr el script de setup:
   ```
   sh /flash/retrotink/setup.sh
   ```

8. Listo!

## Cambiar a 480i

Para usar 480i interlazado nativo (ideal para juegos PS1/PS2 que usan 480i):

1. Renombrar `config.txt` a `config_240p.txt`
2. Renombrar `config_480i.txt` a `config.txt`
3. Rebootear

## Comparacion Pi 3 vs Pi 4 vs Pi 5

| | Pi 3 | Pi 4 | Pi 5 |
|---|---|---|---|
| GPIO DPI | Directo | `gpio=0-27=a2,np` | Directo (RP1) |
| 480i nativo | No | No | **Si** |
| Overlay | `vc4-kms-dpi-generic` | Igual | Igual |
| Rendimiento | Basico (NES/SNES/Genesis) | Medio (N64/PS1) | Alto (PSP/DC/Saturn) |

## Notas

- Pi 5 **no tiene jack 3.5mm de audio** — necesitaras un DAC USB o audio por HDMI
- SSH se desactiva con cada reflasheo
- La fuente y widgets se reinstalan con `setup.sh`
- La IP puede cambiar — verificar en router o en Lakka
- **EXPERIMENTAL**: Esta configuracion no ha sido probada. Puede requerir ajustes.
