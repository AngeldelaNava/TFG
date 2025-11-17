#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

BASE_DIR="./trainings"
MODELS_DIR="./models"
RESULTS_DIR="./results"
CLASSES_FILE="./classes"
DICT_FILE="./dict"

for STATES in 3 4 5; do
  MODELS_ROOT="${MODELS_DIR}/models_${STATES}_states"
  RESULTS_ROOT="${RESULTS_DIR}/results_${STATES}_states"
  echo "============================================"
  echo " Ejecutando HVite y HResults para ${STATES} estados"
  echo "============================================"
  for OUTER in {01..10}; do
    for INNER in {01..10}; do
      MACROS_FILE="${MODELS_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm6/macros"
      HMMDEFS_FILE="${MODELS_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm6/hmmdefs"
      TEST_SCP="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/test${OUTER}_state${INNER}.scp"
      TEST_MLF="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/test${OUTER}_state${INNER}.mlf"
      HVITE_OUT_DIR="${RESULTS_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/HVite"
      HRESULTS_OUT_DIR="${RESULTS_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/HResults"
      mkdir -p "$HVITE_OUT_DIR"
      mkdir -p "$HRESULTS_OUT_DIR"
      RECOUT_FILE="${HVITE_OUT_DIR}/recout${OUTER}_state${INNER}.mlf"
      RESULTS_FILE="${HRESULTS_OUT_DIR}/results${OUTER}_state${INNER}.txt"
      echo ">>> HVite: Fold=${OUTER}_${INNER} (${STATES} estados)"
      HVite -H "$MACROS_FILE" \
            -H "$HMMDEFS_FILE" \
            -S "$TEST_SCP" \
            -i "$RECOUT_FILE" \
            "$DICT_FILE" \
            "$CLASSES_FILE"
      echo ">>> HResults: Fold=${OUTER}_${INNER} (${STATES} estados)"
      HResults -I "$TEST_MLF" "$CLASSES_FILE" "$RECOUT_FILE" > "$RESULTS_FILE"
    done
  done
done

echo "HVite y HResults completado para todos los grupos y estados"