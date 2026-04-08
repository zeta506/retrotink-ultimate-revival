
[![Ver video](https://img.youtube.com/vi/GCK6InNT9x4/0.jpg)](https://www.youtube.com/watch?v=GCK6InNT9x4)

# RetroTINK Ultimate + Lakka

[Leer en español](README.es.md)

Ready-to-use configurations to bring the **RetroTINK Ultimate** back to life — a discontinued device that converts the DPI output (RGB888) from a Raspberry Pi into component video for CRT displays.

## Why this project

The RetroTINK Ultimate was originally designed for the Raspberry Pi 3 with very old versions of Lakka. At some point there were advances shown with the Pi 4, but development stalled and the device was left behind.

This repository aims to:

- **Revive the RetroTINK Ultimate** with modern versions of Lakka (6.1+)
- **Find the best frequencies and timings** to get the most out of it
- **Support Pi 3, Pi 4 and Pi 5** with optimized configurations for each

## How it works

The RetroTINK Ultimate takes the **DPI RGB888 signal at 15 kHz** from the Raspberry Pi's GPIO and converts it to component video (YPbPr) for direct connection to a CRT.

**Super resolutions** (2048x240, 2560x240) are used to achieve maximum sharpness by scaling horizontally without changing the pixel clock, which keeps the signal stable over GPIO.

### Audio

| Platform | Audio output |
|---|---|
| Pi 3 | Pi's 3.5mm jack (`hw:1,0`) |
| Pi 4 | Pi's 3.5mm jack (`hw:2,0`) |
| Pi 5 | USB DAC (Pi 5 has no 3.5mm jack) |

## Available configurations

| Folder | Lakka | Raspberry Pi | Status |
|---|---|---|---|
| `lakka 6.1 retrotink pi3/` | 6.1 stable | Pi 3 | Working |
| `lakka 6.1 retrotink pi4/` | 6.1 stable | Pi 4 | Working |
| `lakka 6.1 retrotink pi5/` | 6.1 stable | Pi 5 | Experimental |
| `lakka nightly 6.1-20260322 retrotink pi5/` | Nightly (kernel 6.12) | Pi 5 | Working, supports dynamic 480i |

Each folder includes its own `README.md` with detailed instructions.

### Why the Nightly for Pi 5

The stable Lakka 6.1 uses an older kernel that **does not support dynamic resolution switching over DPI**. This means the Pi 5 stays locked to whatever resolution is set in `config.txt` (e.g. 240p) and cannot switch to 480i when a game needs it.

The **Lakka Nightly** ships with **kernel 6.12**, which includes Raspberry Pi patches for DPI interlacing via the RP1 chip's PIO block. This enables:

- **SwitchRes works**: RetroArch can automatically switch between 240p and 480i depending on the game
- **PIO generates correct VSYNC** for interlacing by snooping the DE and HSYNC GPIOs
- Boot in 240p (for menus and retro games) and switch to 480i only when a game requires it (e.g. Tekken 3 in MAME)

In short: for Pi 5 with RetroTINK Ultimate, **the Nightly is the recommended version** because it enables dynamic resolution switching, which is essential for a proper CRT experience.

## Steps to use

### 1. Flash Lakka to the microSD

Download the Lakka image for your Raspberry Pi and flash it with [balenaEtcher](https://etcher.balena.io/) or similar:

| Raspberry Pi | Image | Download |
|---|---|---|
| Pi 3 | Lakka 6.1 RPi3.aarch64 | https://www.lakka.tv/get/linux/rpi/ |
| Pi 4 | Lakka 6.1 RPi4.aarch64 | https://www.lakka.tv/get/linux/rpi/ |
| Pi 5 (stable) | Lakka 6.1 RPi5.aarch64 | https://www.lakka.tv/get/linux/rpi/ |
| Pi 5 (recommended) | Lakka Nightly RPi5.aarch64 | https://nightly.builds.lakka.tv/latest/RPi5.aarch64/ |

### 2. Copy files to the SD

Once flashed, open the boot partition (shows as `LAKKA` on Windows) and copy **all files** from the folder matching your Pi to the root:

- `config.txt` (replace the existing one)
- `retroarch-overrides.txt`
- `wifi-config.txt` (edit SSID and PSK with your credentials before copying)
- `retrotink/` (entire folder with setup.sh and the font)

### 3. First boot

Insert the SD into the Pi and power on. Wait for Lakka to fully boot.

Enable SSH: **Main Menu > Services > SSH > ON**

### 4. Connect via SSH and run setup

From a terminal on your PC:

```bash
ssh root@<YOUR_PI_IP>
# Password: root
```

You can find the IP in Lakka: **Main Menu > Information > Network Information**, or in your router.

### 5. Run the setup script

```bash
sh /flash/retrotink/setup.sh
```

This script automates everything: installs the SuperResolution font, enables SSH permanently, configures audio, and applies RetroArch settings.

### 6. Done

Reboot and it's ready. Load ROMs via network or USB and play.

## Required hardware

- **Raspberry Pi** 3, 4 or 5
- **RetroTINK Ultimate** (connected via GPIO/DPI)
- **CRT with component input** (also tested with s-video and composite)
- **USB DAC** (Pi 5 only, for audio)
- microSD card

## Common files

Each configuration includes:

| File | Purpose |
|---|---|
| `config.txt` | Configures DPI, timings and audio |
| `retroarch-overrides.txt` | RetroArch settings for first boot |
| `wifi-config.txt` | WiFi config (edit SSID and PSK before use) |
| `retrotink/setup.sh` | Script that automates post-flash setup |
| `retrotink/SuperResolucion.ttf` | Custom font designed for super resolutions on CRT |

## Key differences between Pis

| | Pi 3 | Pi 4 | Pi 5 |
|---|---|---|---|
| GPIO DPI | Direct | Requires `gpio=0-27=a2,np` | Direct (RP1 chip) |
| Native 480i | No | No | Yes (via PIO, kernel 6.12+) |
| Audio | 3.5mm jack | 3.5mm jack | USB DAC |
