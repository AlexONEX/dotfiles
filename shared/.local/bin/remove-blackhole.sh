#!/bin/bash
# remove-blackhole.sh
# Desinstala BlackHole 2ch completamente

echo "🗑️ Removiendo BlackHole 2ch..."

# 1. Mover el driver a la papelera
sudo mv /Library/Audio/Plug-Ins/HAL/BlackHole2ch.driver ~/.Trash/

# 2. Reiniciar CoreAudio para que libere el driver
sudo killall coreaudiod

sleep 2

# 3. Verificar
echo ""
echo "🔊 BlackHole en devices de audio:"
SwitchAudioSource -a -t output 2>/dev/null | grep -i blackhole && echo "⚠️  Todavía presente" || echo "✅ Eliminado"

echo ""
echo "📋 Outputs disponibles:"
SwitchAudioSource -a -t output 2>/dev/null
