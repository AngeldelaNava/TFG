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

for STATES in 3 4 5; do
  RESULT_ROOT="${RESULTS_DIR}/results_${STATES}_states"

  echo "==========================================="
  echo " HInit para ${STATES} estados"
  echo "==========================================="

  while IFS= read -r CLASS_NAME || [ -n "$CLASS_NAME" ]; do
    [ -z "$CLASS_NAME" ] && continue

    echo ">> Clase: $CLASS_NAME"

    for OUTER in {01..10}; do
      for INNER in {01..10}; do
        TRAIN_SCP="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/Train${OUTER}_state${INNER}.scp"
        TRAIN_MLF="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/Train${OUTER}_state${INNER}.mlf"

        HMM0_DIR="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm0"
        HMM1_DIR="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm1"

        mkdir -p "$HMM1_DIR"

        echo "[HInit] Clase=${CLASS_NAME} Fold=${OUTER}_${INNER} proto=${PROTO}"

        HInit -S "$TRAIN_SCP" \
              -I "$TRAIN_MLF" \
              -M "$HMM1_DIR" \
              -l "$CLASS_NAME" \
              -o "$CLASS_NAME" \
              "./proto_${STATES}_states"

      done
    done
  done < "$CLASSES_FILE"
done

echo "HInit completado para todas las clases, grupos y estados."

