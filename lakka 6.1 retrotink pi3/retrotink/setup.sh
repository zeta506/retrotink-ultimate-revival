#!/bin/sh
#############################################
# RetroTINK Ultimate - Setup automatico
# Correr despues del primer boot:
#   sh /flash/retrotink/setup.sh
#############################################

echo "=== RetroTINK Ultimate Setup ==="

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

# 3. Parar RetroArch para editar config
echo "[3/4] Configurando RetroArch..."
systemctl stop retroarch
sleep 2

CFG="/storage/.config/retroarch/retroarch.cfg"

# Desactivar widgets graficos
sed -i 's/menu_enable_widgets = "true"/menu_enable_widgets = "false"/' "$CFG"

# Forzar fuente SuperResolucion
sed -i 's|video_font_path = ".*"|video_font_path = "/storage/fonts/SuperResolucion.ttf"|' "$CFG"

# Forzar tamaño de fuente
sed -i 's|video_font_size = ".*"|video_font_size = "14.000000"|' "$CFG"

# Audio por jack 3.5mm
sed -i 's|audio_device = ".*"|audio_device = "hw:1,0"|' "$CFG"

echo "      OK"

# 4. Reiniciar RetroArch
echo "[4/4] Reiniciando RetroArch..."
systemctl start retroarch

echo ""
echo "=== Setup completado! ==="
echo "Video: DPI 2048x240p via RetroTINK Ultimate"
echo "Audio: Jack 3.5mm (hw:1,0)"
echo "Fuente: SuperResolucion 14px"
echo "SSH: Activado"
