#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

BASE_DIR="./trainings"
RESULTS_DIR="./results"

# === HCompV: Inicialización global ===
for STATES in 3 4 5; do
  PROTO="./proto_${STATES}_states"
  RESULT_ROOT="${RESULTS_DIR}/results_${STATES}_states"

  echo "==========================================="
  echo " Ejecutando HCompV para ${STATES} estados"
  echo "==========================================="

  for OUTER in {01..10}; do
    for INNER in {01..10}; do
      TRAIN_SCP="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/Train${OUTER}_state${INNER}.scp"
      OUT_DIR="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm0"

      mkdir -p "$OUT_DIR"
      echo ">>> HCompV: Train${OUTER}_state${INNER} (${STATES} estados)"
      HCompV -f 0.01 -m -S "$TRAIN_SCP" -M "$OUT_DIR" "$PROTO"
    done
  done
done

echo "HCompV completado para todos los grupos y estados."
