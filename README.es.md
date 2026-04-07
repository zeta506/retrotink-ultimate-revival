# RetroTINK Ultimate + Lakka

[Read in English](README.md)

Configuraciones listas para darle nueva vida al **RetroTINK Ultimate**, un dispositivo descontinuado que convierte la salida DPI (RGB888) de una Raspberry Pi en video por componentes para CRT.

## Por que este proyecto

El RetroTINK Ultimate fue diseñado originalmente para la Raspberry Pi 3 con versiones muy antiguas de Lakka. En algun momento se mostraron avances con la Pi 4, pero el desarrollo se detuvo y el dispositivo quedo en el olvido.

Este repositorio busca:

- **Revivir el RetroTINK Ultimate** con versiones modernas de Lakka (6.1+)
- **Encontrar las mejores frecuencias y timings** para sacarle el maximo provecho
- **Soportar Pi 3, Pi 4 y Pi 5** con configuraciones optimizadas para cada una

## Como funciona

El RetroTINK Ultimate toma la señal **DPI RGB888 a 15 kHz** de los GPIO de la Raspberry Pi y la convierte a video por componentes (YPbPr) para conectar directamente a un CRT.

Se usan **super resoluciones** (2048x240, 2560x240) para lograr la mayor nitidez posible escalando horizontalmente sin cambiar el pixel clock, lo que mantiene la señal estable por GPIO.

### Audio

| Plataforma | Salida de audio |
|---|---|
| Pi 3 | Jack 3.5mm de la Pi (`hw:1,0`) |
| Pi 4 | Jack 3.5mm de la Pi (`hw:2,0`) |
| Pi 5 | DAC USB (la Pi 5 no tiene jack 3.5mm) |

## Configuraciones disponibles

| Carpeta | Lakka | Raspberry Pi | Estado |
|---|---|---|---|
| `lakka 6.1 retrotink pi3/` | 6.1 estable | Pi 3 | Funcional |
| `lakka 6.1 retrotink pi4/` | 6.1 estable | Pi 4 | Funcional |
| `lakka 6.1 retrotink pi5/` | 6.1 estable | Pi 5 | Experimental |
| `lakka nightly 6.1-20260322 retrotink pi5/` | Nightly (kernel 6.12) | Pi 5 | Funcional, soporta 480i dinamico |

Cada carpeta incluye su propio `README.md` con instrucciones detalladas.

### Por que el Nightly para Pi 5

La version estable de Lakka 6.1 usa un kernel mas viejo que **no soporta cambio dinamico de resoluciones por DPI**. Esto significa que la Pi 5 queda fija en la resolucion que se configura en `config.txt` (por ejemplo 240p) y no puede cambiar a 480i cuando un juego lo necesita.

El **Lakka Nightly** trae el **kernel 6.12**, que incluye parches de Raspberry Pi para interlazado DPI via el bloque PIO del chip RP1. Gracias a esto:

- **SwitchRes funciona**: RetroArch puede cambiar entre 240p y 480i automaticamente segun el juego
- **PIO genera el VSYNC correcto** para interlazado, snooping los GPIO de DE y HSYNC
- Se puede bootear en 240p (para el menu y juegos retro) y cambiar a 480i solo cuando un juego lo requiere (por ejemplo Tekken 3 en MAME)

En resumen: para Pi 5 con RetroTINK Ultimate, **el Nightly es la version recomendada** porque permite aprovechar el cambio dinamico de resoluciones que es fundamental para una experiencia CRT correcta.

## Pasos para usar

### 1. Flashear Lakka en la microSD

Descargar la imagen de Lakka para tu Raspberry Pi y flashearla con [balenaEtcher](https://etcher.balena.io/) o similar:

| Raspberry Pi | Imagen | Descarga |
|---|---|---|
| Pi 3 | Lakka 6.1 RPi3.aarch64 | https://www.lakka.tv/get/linux/rpi/ |
| Pi 4 | Lakka 6.1 RPi4.aarch64 | https://www.lakka.tv/get/linux/rpi/ |
| Pi 5 (estable) | Lakka 6.1 RPi5.aarch64 | https://www.lakka.tv/get/linux/rpi/ |
| Pi 5 (recomendado) | Lakka Nightly RPi5.aarch64 | https://nightly.builds.lakka.tv/latest/RPi5.aarch64/ |

### 2. Copiar archivos a la SD

Una vez flasheada, abrir la particion de boot (aparece como `LAKKA` en Windows) y copiar **todos los archivos** de la carpeta correspondiente a tu Pi a la raiz:

- `config.txt` (reemplazar el existente)
- `retroarch-overrides.txt`
- `wifi-config.txt` (editar SSID y PSK con tus datos antes de copiar)
- `retrotink/` (carpeta completa con setup.sh y la fuente)

### 3. Primer boot

Insertar la SD en la Pi y encender. Esperar a que Lakka bootee completamente.

Activar SSH: **Main Menu > Services > SSH > ON**

### 4. Conectarse por SSH y correr el setup

Desde una terminal en tu PC:

```bash
ssh root@<IP_DE_TU_PI>
# Contraseña: root
```

La IP se puede ver en Lakka: **Main Menu > Information > Network Information**, o en tu router.

### 5. Correr el script de configuracion

```bash
sh /flash/retrotink/setup.sh
```

Este script automatiza todo: instala la fuente SuperResolucion, activa SSH permanentemente, configura el audio y aplica las opciones de RetroArch.

### 6. Listo

Reiniciar y ya esta funcionando. Cargar ROMs por red o USB y jugar.

## Hardware necesario

- **Raspberry Pi** 3, 4 o 5
- **RetroTINK Ultimate** (conectado por GPIO/DPI)
- **CRT con entrada por componentes** (probado también con svideo y component)
- **DAC USB** (solo Pi 5, para audio)
- Tarjeta microSD

## Archivos comunes

Cada configuracion incluye:

| Archivo | Funcion |
|---|---|
| `config.txt` | Configura DPI, timings y audio |
| `retroarch-overrides.txt` | Ajustes de RetroArch para el primer boot |
| `wifi-config.txt` | Configuracion WiFi (editar SSID y PSK antes de usar) |
| `retrotink/setup.sh` | Script que automatiza la configuracion post-flasheo |
| `retrotink/SuperResolucion.ttf` | Fuente custom diseñada para super resoluciones en CRT |

## Diferencias clave entre Pis

| | Pi 3 | Pi 4 | Pi 5 |
|---|---|---|---|
| GPIO DPI | Directo | Requiere `gpio=0-27=a2,np` | Directo (chip RP1) |
| 480i nativo | No | No | Si (via PIO, kernel 6.12+) |
| Audio | Jack 3.5mm | Jack 3.5mm | DAC USB |
