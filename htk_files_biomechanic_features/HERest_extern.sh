#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

BASE_DIR="./trainings"
MODELS_DIR="./models"
CLASSES_FILE="./classes"

if [ ! -f "$CLASSES_FILE" ]; then
  echo "ERROR: no se encuentra $CLASSES_FILE"
  exit 1
fi

for TRAIN_INDEX in 1 2 3 4 5 6; do
  for STATES in 3 4 5; do
    RESULT_ROOT="${MODELS_DIR}/models_${STATES}_states"

    echo "==========================================="
    echo " Ejecutando HERest nº ${TRAIN_INDEX} para ${STATES} estados"
    echo "==========================================="

    for OUTER in {01..10}; do
      TRAIN_SCP="${BASE_DIR}/Train${OUTER}/Train${OUTER}.scp"
      TRAIN_MLF="${BASE_DIR}/Train${OUTER}/Train${OUTER}.mlf"
      PREVIOUS_FOLDER=$((TRAIN_INDEX - 1))
      PREVIOUS_DIR="${RESULT_ROOT}/Group_${OUTER}/hmm${PREVIOUS_FOLDER}"
      NEW_DIR="${RESULT_ROOT}/Group_${OUTER}/hmm${TRAIN_INDEX}"

      mkdir -p "$NEW_DIR"

      echo "[HERest] nº ${TRAIN_INDEX} Fold=${OUTER} (${STATES} estados)"

      HERest -S "$TRAIN_SCP" \
            -I "$TRAIN_MLF" \
            -H "${PREVIOUS_DIR}/macros" -H "${PREVIOUS_DIR}/hmmdefs" \
            -M "$NEW_DIR" \
            "$CLASSES_FILE"
    done
  done
done

echo "HERest completado para todos los estados."