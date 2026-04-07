# RetroTINK Ultimate + Lakka Nightly 6.1-20260322 + Raspberry Pi 5

## Hardware

- **Raspberry Pi 5** (aarch64, kernel 6.12.77)
- **RetroTINK Ultimate** (conectado por GPIO/DPI, RGB888 24-bit)
- **CRT Sony Wega** (componente)
- **Audio** por DAC USB C-Media (hw:2,0 - Pi 5 no tiene jack 3.5mm)

## Que tiene de especial este build

Este Lakka nightly usa **kernel 6.12.77** que incluye los parches de
**interlazado DPI via PIO** de Raspberry Pi (marzo 2025). Esto permite:

- **Boot en 240p** (modo base para menu y juegos retro)
- **Cambio dinamico a 480i** para juegos que lo necesitan (Tekken 3 arcade, etc.)
- **PIO sync**: El bloque PIO del RP1 genera VSYNC correcto para interlazado
  snooping GPIO1 (DE) y GPIO3 (HSYNC), override en GPIO2 (VSYNC)

## Imagen base

`Lakka-RPi5.aarch64-6.1-20260322-ac47637.img.gz` (Lakka Nightly)
Descarga: https://nightly.builds.lakka.tv/latest/RPi5.aarch64/

## Configuracion

### config.txt - DPI 2048x240p @ 42.95MHz

```ini
dtoverlay=vc4-kms-dpi-generic
dtparam=rgb888
dtparam=clock-frequency=42954545
dtparam=hactive=2048,hfp=180,hsync=202,hbp=300
dtparam=vactive=240,vfp=3,vsync=5,vbp=14
dtparam=hsync-invert,vsync-invert
```

- htotal=2730, hfreq=15,734 Hz (NTSC estandar)
- vtotal=262, vfreq=60 Hz
- NO necesita `dtparam=interlaced` en boot - SwitchRes cambia dinamicamente

### RetroArch - Super Resolution 2560

```ini
crt_switch_resolution = "1"
crt_switch_resolution_super = "2560"
aspect_ratio_index = "0"
custom_viewport_width = "1920"
custom_viewport_height = "240"
custom_viewport_x = "320"
custom_viewport_y = "0"
```

- Super=2560: NES 256x10=2560, MD 320x8=2560, SNES 256x10=2560
- Viewport 4:3: 1920px centrado en 2560 (offset 320)
- SwitchRes cambia a 480i automaticamente para juegos interlazados
- Boot en 2048 (config.txt), SwitchRes cambia a 2560 al iniciar RetroArch

### Override MAME para 480i

```ini
# /storage/.config/retroarch/config/MAME/MAME.cfg
aspect_ratio_index = "22"
custom_viewport_width = "1920"
custom_viewport_height = "480"
custom_viewport_x = "320"
custom_viewport_y = "0"
```

Sin este override, el CRT switch code fuerza aspect ratio 10.67 (2560/240)
para todos los modos, incluyendo 480i. Con `aspect_ratio_index = "22"`
(ASPECT_RATIO_CORE) + viewport 1920x480, el aspect se calcula correctamente
para 480i. Viewport 4:3: 1920px centrado en 2560 (offset 320), altura 480.

## Pasos para reproducir

### 1. Flashear Lakka Nightly

Flashear `Lakka-RPi5.aarch64-6.1-20260322-ac47637.img.gz` con Balena Etcher.

### 2. Copiar archivos a la SD

Copiar a la particion boot (LAKKA):
- `config.txt` (reemplazar el existente)
- `retroarch-overrides.txt` (en la raiz)
- `wifi-config.txt` (en la raiz)
- `retrotink/` (carpeta completa)

### 3. Primer boot

Insertar SD en Pi 5, encender. Esperar a que Lakka bootee.
Activar SSH desde Main Menu > Services > SSH > ON.

### 4. Correr setup.sh

```bash
ssh root@<IP>  # password: root
sh /flash/retrotink/setup.sh
```

El script hace:
1. Copia fuente SuperResolucion a /storage/fonts/
2. Activa SSH permanentemente
3. Detecta DAC USB y configura audio
4. Configura core options (overscan OFF en todos los cores)
5. Crea override MAME para 480i (aspect_ratio_index=22)

## Interlazado 480i - Como funciona

El kernel 6.12+ del Pi 5 soporta interlazado DPI via tres mecanismos:

1. **Field switching**: El driver DPI alterna entre lineas pares/impares
   del framebuffer cambiando el puntero base a 60Hz
2. **Timing hack**: Cada segundo campo recibe una linea extra de blanking
   (offset de media linea necesario para interlazado)
3. **PIO sync**: El bloque PIO del RP1 snoopea GPIO1 (DE) y GPIO3 (HSYNC)
   para generar VSYNC correcto en GPIO2

### Verificacion

```bash
# Ver si PIO se activo para interlazado
dmesg | grep "Using PIO"
# Debe mostrar: Using PIO to generate VSync on GPIO2

# Ver modos DPI activos
dmesg | grep "drm-rp1-dpi" | grep mode
# 240p: mode=2048x240 total=2730x262
# 480i: mode=2048x480 total=2662x525i

# Verificar GPIO 0-3 en modo DPI
pinctrl get 0-3
# GPIO0=DPI_PCLK, GPIO1=DPI_DE, GPIO2=DPI_VSYNC, GPIO3=DPI_HSYNC
```

## Credenciales

| Usuario | Password |
|---|---|
| root (SSH) | root |

## Archivos

```
lakka nightly 6.1-20260322 retrotink pi5/
├── README.md
├── config.txt              <- DPI 2048x240@42.95MHz
├── retroarch-overrides.txt <- super=2048, viewport 1280x240, audio hw:2,0
├── wifi-config.txt
└── retrotink/
    ├── setup.sh            <- SSH + audio + fuente + core options + MAME override
    ├── core-options.cfg    <- overscan OFF todos los cores
    └── SuperResolucion.ttf
```

## Notas tecnicas

- **No usar dtparam=interlaced en config.txt**: SwitchRes cambia
  dinamicamente a 480i cuando un juego lo necesita. Bootear en interlazado
  rompe los juegos de 240p (se ven estirados y tiemblan).

- **PIO "Could not open PIO" al boot**: Es normal. PIO no esta listo
  durante el primer mode set. Se activa correctamente despues.

- **Super resolution vs Native**: Native (super=0) cambia el pixel clock
  por juego (6MHz a 42MHz). Con DPI GPIO esto causa ruido e inestabilidad.
  Super=2048 mantiene clock estable (~42MHz) y escala horizontalmente.

- **Aspect ratio bug con 480i**: El CRT switch code fuerza aspect ratio
  2048/240=8.53 para todos los modos. El override MAME con
  aspect_ratio_index=22 permite calculo dinamico correcto.
