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
    MACROS_FILE="${MODELS_ROOT}/Group_${OUTER}/hmm6/macros"
    HMMDEFS_FILE="${MODELS_ROOT}/Group_${OUTER}/hmm6/hmmdefs"
    HVITE_OUT_DIR="${RESULTS_ROOT}/Group_${OUTER}/HVite"
    HRESULTS_OUT_DIR="${RESULTS_ROOT}/Group_${OUTER}/HResults"
    TEST_SCP="${BASE_DIR}/Train${OUTER}/test${OUTER}.scp"
    TEST_MLF="${BASE_DIR}/Train${OUTER}/test${OUTER}.mlf"
    mkdir -p "$HVITE_OUT_DIR"
    mkdir -p "$HRESULTS_OUT_DIR"
    RECOUT_FILE="${HVITE_OUT_DIR}/recout${OUTER}.mlf"
    RESULTS_FILE="${HRESULTS_OUT_DIR}/results${OUTER}.txt"
    echo ">>> HVite: Fold=${OUTER} (${STATES} estados)"
    HVite -H "$MACROS_FILE" \
          -H "$HMMDEFS_FILE" \
          -S "$TEST_SCP" \
          -i "$RECOUT_FILE" \
          "$DICT_FILE" \
          "$CLASSES_FILE"
    echo ">>> HResults: Fold=${OUTER} (${STATES} estados)"
    HResults -I "$TEST_MLF" "$CLASSES_FILE" "$RECOUT_FILE" > "$RESULTS_FILE"
  done
done

echo "HVite y HResults completado para todos los estados"