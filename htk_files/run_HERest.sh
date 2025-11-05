#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

BASE_DIR="./trainings"
RESULTS_DIR="./results"
CLASSES_FILE="./classes"

if [ ! -f "$CLASSES_FILE" ]; then
  echo "ERROR: no se encuentra $CLASSES_FILE"
  exit 1
fi

# === HERest: Primer reentrenamiento de modelos ===
for STATES in 3 4 5; do
  RESULT_ROOT="${RESULTS_DIR}/results_${STATES}_states"

  echo "==========================================="
  echo " Ejecutando HERest para ${STATES} estados"
  echo "==========================================="

  for OUTER in {01..10}; do
    for INNER in {01..10}; do
      TRAIN_SCP="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/Train${OUTER}_state${INNER}.scp"
      TRAIN_MLF="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/Train${OUTER}_state${INNER}.mlf"

      HMM1_DIR="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm1"
      HMM2_DIR="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm2"

      mkdir -p "$HMM2_DIR"

      echo "[HERest] Fold=${OUTER}_${INNER} (${STATES} estados)"

      HERest -S "$TRAIN_SCP" \
             -I "$TRAIN_MLF" \
             -H "${HMM1_DIR}/macros" -H "${HMM1_DIR}/hmmdefs" \
             -M "$HMM2_DIR" \
             "$CLASSES_FILE"

    done
  done
done

echo "HERest completado para todos los grupos y estados."
