#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

BASE_DIR="./trainings"
MODELS_DIR="./models"
CLASSES_FILE="./classes"
ADD_GAUSSIAN="./add_gaussian_files"

if [ ! -f "$CLASSES_FILE" ]; then
  echo "ERROR: no se encuentra $CLASSES_FILE"
  exit 1
fi

# === HERest: Primer reentrenamiento de modelos ===
for GAUSSIAN in {1..10}; do
  for TRAIN_INDEX in 1 2 3 4 5 6; do
    for STATES in 3 4 5; do
      RESULT_ROOT="${MODELS_DIR}/models_${STATES}_states"

      echo "==========================================="
      echo " Ejecutando HERest nº ${TRAIN_INDEX} para ${STATES} estados, Gaussiana ${GAUSSIAN}"
      echo "==========================================="

      for OUTER in {01..10}; do
        for INNER in {01..10}; do
          TRAIN_SCP="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/Train${OUTER}_state${INNER}.scp"
          TRAIN_MLF="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/Train${OUTER}_state${INNER}.mlf"

          PREVIOUS_FOLDER=$((TRAIN_INDEX - 1))
          PREVIOUS_DIR="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm${PREVIOUS_FOLDER}_${GAUSSIAN}"
          NEW_DIR="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm${TRAIN_INDEX}_${GAUSSIAN}"

          mkdir -p "$NEW_DIR"

          echo "[HERest] nº ${TRAIN_INDEX} Fold=${OUTER}_${INNER} (${STATES} estados)"

          HERest -S "$TRAIN_SCP" \
                -I "$TRAIN_MLF" \
                -H "${PREVIOUS_DIR}/macros" -H "${PREVIOUS_DIR}/hmmdefs" \
                -M "$NEW_DIR" \
                "$CLASSES_FILE"
        done
      done
    done
  done
  if [ "$GAUSSIAN" -le 9 ]; then
    echo "==========================================="
    echo "Creando Gaussiana $((GAUSSIAN + 1))"
    echo "==========================================="
    for STATES in 3 4 5; do
      for OUTER in {01..10}; do
        for INNER in {01..10}; do
          RESULT_ROOT="${MODELS_DIR}/models_${STATES}_states"
          HMMDEFS="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm6_${GAUSSIAN}/hmmdefs"
          MACROS="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm6_${GAUSSIAN}/macros"
          NEW_FOLDER="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm0_$((GAUSSIAN + 1))"
          ADD_GAUSSIAN_FILE="${ADD_GAUSSIAN}/mix$((GAUSSIAN + 1))_${STATES}_states.hed"

          mkdir -p "$NEW_FOLDER"
          echo ">>> HHEd: Group ${OUTER}_${INNER} (${STATES} estados)"
          HHEd -H "$HMMDEFS" \
              -H "$MACROS" \
              -M "$NEW_FOLDER" \
              "$ADD_GAUSSIAN_FILE" \
              "$CLASSES_FILE"
        done
      done
    done
  fi
done


echo "HERest completado para todos los grupos, estados y gaussianas."
