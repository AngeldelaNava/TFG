#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

echo "==========================================="
echo "        ENTRENAMIENTO COMPLETO HTK"
echo "==========================================="

# --- FASE 1: HCompV ---
echo ">>> [1/2] Ejecutando HCompV..."
bash ./run_HCompV.sh
echo ">>> HCompV completado correctamente."
echo

# --- FASE 2: HERest ---
echo ">>> [2/2] Ejecutando HERest..."
bash ./run_HERest.sh
echo ">>> HERest completado correctamente."
echo

echo "==========================================="
echo "TODO EL ENTRENAMIENTO HA FINALIZADO CORRECTAMENTE"
echo "==========================================="
