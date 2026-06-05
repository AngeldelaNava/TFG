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


declare -A group01=(
  [group]="01"
  [gaussians]="9"
  [states]="4"
)

declare -A group02=(
  [group]="02"
  [gaussians]="9"
  [states]="3"
)

declare -A group03=(
  [group]="03"
  [gaussians]="14"
  [states]="12"
)

declare -A group04=(
  [group]="04"
  [gaussians]="10"
  [states]="3"
)

declare -A group05=(
  [group]="05"
  [gaussians]="10"
  [states]="5"
)

declare -A group06=(
  [group]="06"
  [gaussians]="1"
  [states]="6"
)

declare -A group07=(
  [group]="07"
  [gaussians]="7"
  [states]="4"
)

declare -A group08=(
  [group]="08"
  [gaussians]="13"
  [states]="4"
)

declare -A group09=(
  [group]="09"
  [gaussians]="10"
  [states]="5"
)

declare -A group10=(
  [group]="10"
  [gaussians]="8"
  [states]="4"
)

group_list=(group01 group02 group03 group04 group05 group06 group07 group08 group09 group10)

for GROUP in "${group_list[@]}"; do
  declare -n ref=$GROUP
  STATES="${ref[states]}"
  RESULT_ROOT="${MODELS_DIR}/models_${STATES}_states"
  OUTER=${ref[group]}
  TRAIN_SCP="${BASE_DIR}/Train${OUTER}/Train${OUTER}.scp"
  TRAIN_MLF="${BASE_DIR}/Train${OUTER}/Train${OUTER}.mlf"
  for (( g=1; g<=${ref[gaussians]}; g++)); do
    for TRAIN_INDEX in 1 2 3 4 5 6; do
      PREVIOUS_FOLDER=$((TRAIN_INDEX - 1))
      PREVIOUS_DIR="${RESULT_ROOT}/Group_${OUTER}/hmm${PREVIOUS_FOLDER}_${g}"
      NEW_DIR="${RESULT_ROOT}/Group_${OUTER}/hmm${TRAIN_INDEX}_${g}"

      mkdir -p "$NEW_DIR"

      echo "[HERest] nº ${TRAIN_INDEX} Fold=${OUTER} (${STATES} estados, ${g} gaussians)"

      HERest -S "$TRAIN_SCP" \
            -I "$TRAIN_MLF" \
            -H "${PREVIOUS_DIR}/macros" -H "${PREVIOUS_DIR}/hmmdefs" \
            -M "$NEW_DIR" \
            "$CLASSES_FILE"
    done
    if (( g < ref[gaussians] )); then
      echo "===================="
      echo "Creando Gaussiana $((g + 1))"
      echo "===================="
      HMMDEFS="${RESULT_ROOT}/Group_${OUTER}/hmm6_${g}/hmmdefs"
      MACROS="${RESULT_ROOT}/Group_${OUTER}/hmm6_${g}/macros"
      NEW_FOLDER="${RESULT_ROOT}/Group_${OUTER}/hmm0_$((g + 1))"
      ADD_GAUSSIAN_FILE="${ADD_GAUSSIAN}/mix$((g + 1))_${STATES}_states.hed"

      mkdir -p "$NEW_FOLDER"
      echo ">>> HHEd: Group ${OUTER} (${STATES} estados)"
      HHEd -H "$HMMDEFS" \
          -H "$MACROS" \
          -M "$NEW_FOLDER" \
          "$ADD_GAUSSIAN_FILE" \
          "$CLASSES_FILE"
    fi
  done
done

echo "HERest completado."