#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

BASE_DIR="./trainings"
MODELS_DIR="./models"
RESULTS_DIR="./results"
CLASSES_FILE="./classes"
DICT_FILE="./dict"
GRADES="./grades"

if [ ! -f "$GRADES" ]; then
    HParse grades.gram "$GRADES"
fi

for STATES in 8 9 10 11 12; do
  MODELS_ROOT="${MODELS_DIR}/models_${STATES}_states"
  RESULTS_ROOT="${RESULTS_DIR}/results_${STATES}_states"
  echo "============================================"
  echo " Ejecutando HVite y HResults para ${STATES} estados"
  echo "============================================"
  
  for INNER in {01..10}; do
    for GAUSSIAN in {1..15}; do
      MACROS_FILE="${MODELS_ROOT}/Group_03/Group03_${INNER}/hmm6_${GAUSSIAN}/macros"
      HMMDEFS_FILE="${MODELS_ROOT}/Group_03/Group03_${INNER}/hmm6_${GAUSSIAN}/hmmdefs"
      TEST_SCP="${BASE_DIR}/Train03/folds/fold${INNER}/test03_state${INNER}.scp"
      TEST_MLF="${BASE_DIR}/Train03/folds/fold${INNER}/test03_state${INNER}.mlf"
      HVITE_OUT_DIR="${RESULTS_ROOT}/Group_03/Group03_${INNER}/${GAUSSIAN}_gaussians/HVite"
      HRESULTS_OUT_DIR="${RESULTS_ROOT}/Group_03/Group03_${INNER}/${GAUSSIAN}_gaussians/HResults"
      mkdir -p "$HVITE_OUT_DIR"
      mkdir -p "$HRESULTS_OUT_DIR"
      RECOUT_FILE="${HVITE_OUT_DIR}/recout03_state${INNER}.mlf"
      RESULTS_FILE="${HRESULTS_OUT_DIR}/results03_state${INNER}.txt"
      echo ">>> HVite: Fold=03_${INNER} (${STATES} estados, ${GAUSSIAN} gaussianas)"
      HVite -H "$MACROS_FILE" \
            -H "$HMMDEFS_FILE" \
            -S "$TEST_SCP" \
            -i "$RECOUT_FILE" \
            -w "$GRADES" \
            "$DICT_FILE" \
            "$CLASSES_FILE"
      echo ">>> HResults: Fold=03_${INNER} (${STATES} estados, ${GAUSSIAN} gaussianas)"
      HResults -I "$TEST_MLF" "$CLASSES_FILE" "$RECOUT_FILE" > "$RESULTS_FILE"
    done
  done
done

echo "HVite y HResults completado para todos los grupos y estados"
