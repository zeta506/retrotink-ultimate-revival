#!/bin/sh
#############################################
# RetroTINK Ultimate - Setup automatico Pi 5
# Correr despues del primer boot:
#   sh /flash/retrotink/setup.sh
# NO toca configuracion de video/RetroArch
#############################################

echo "=== RetroTINK Ultimate Setup (Pi 5) ==="

# 1. Copiar fuente SuperResolucion
echo "[1/4] Copiando fuente SuperResolucion..."
mkdir -p /storage/fonts
cp /flash/retrotink/SuperResolucion.ttf /storage/fonts/
echo "      OK"

# 2. Activar SSH permanentemente
echo "[2/4] Activando SSH..."
mkdir -p /storage/.cache/services
echo "SSHD_START=true" > /storage/.cache/services/sshd.conf
systemctl start sshd 2>/dev/null
echo "      OK"

# 2. Detectar dispositivo de audio (DAC USB)
echo "[3/4] Detectando audio..."
echo "      Dispositivos encontrados:"
aplay -l 2>/dev/null | grep "^card"

AUDIO_DEV=""
for card in 0 1 2 3; do
    name=$(cat /proc/asound/card${card}/id 2>/dev/null)
    if [ -n "$name" ] && [ "$name" != "vc4hdmi" ] && [ "$name" != "vc4hdmi0" ] && [ "$name" != "vc4hdmi1" ]; then
        AUDIO_DEV="hw:${card},0"
        echo "      DAC detectado: $name en $AUDIO_DEV"
        break
    fi
done

if [ -z "$AUDIO_DEV" ]; then
    AUDIO_DEV="hw:0,0"
    echo "      AVISO: No se detecto DAC USB, usando $AUDIO_DEV"
fi

# 3. Core options - overscan OFF en todos los cores
echo "[4/4] Configurando core options (overscan OFF)..."
CORE_OPTS="/storage/.config/retroarch/retroarch-core-options.cfg"
if [ -f /flash/retrotink/core-options.cfg ]; then
    # Si ya existe el archivo, mergear sin duplicar
    if [ -f "$CORE_OPTS" ]; then
        # Agregar solo las keys que no existan
        while IFS= read -r line; do
            case "$line" in \#*|"") continue ;; esac
            key=$(echo "$line" | cut -d'=' -f1 | tr -d ' ')
            if ! grep -q "^${key} " "$CORE_OPTS" 2>/dev/null; then
                echo "$line" >> "$CORE_OPTS"
            else
                sed -i "s|^${key} = .*|${line}|" "$CORE_OPTS"
            fi
        done < /flash/retrotink/core-options.cfg
    else
        cp /flash/retrotink/core-options.cfg "$CORE_OPTS"
    fi
    echo "      OK"
else
    echo "      AVISO: No se encontro core-options.cfg"
fi

# Aplicar audio sin tocar video
systemctl stop retroarch
sleep 2
CFG="/storage/.config/retroarch/retroarch.cfg"
sed -i "s|audio_device = \".*\"|audio_device = \"${AUDIO_DEV}\"|" "$CFG"
systemctl start retroarch

echo ""
echo "=== Setup completado! ==="
echo "Audio: $AUDIO_DEV"
echo "SSH: Activado"
echo "Core options: Overscan OFF"
