#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

BASE_DIR="./trainings"
MODELS_DIR="./models"
RESULTS_DIR="./results"
CLASSES_FILE="./classes"
DICT_FILE="./dict"
GRADES="./grades"


declare -A group03=(
  [group]="03"
  [gaussians]="15"
  [states]="5 6 7"
)

declare -A group04=(
  [group]="04"
  [gaussians]="15"
  [states]="3"
)

declare -A group05=(
  [group]="05"
  [gaussians]="15"
  [states]="5 6 7"
)

declare -A group06=(
  [group]="06"
  [gaussians]="5"
  [states]="6 7"
)

declare -A group08=(
  [group]="08"
  [gaussians]="15"
  [states]="4"
)

declare -A group09=(
  [group]="09"
  [gaussians]="15"
  [states]="5 6 7"
)

group_list=(group03 group04 group05 group06 group08 group09)


for GROUP in "${group_list[@]}"; do
  declare -n ref=$GROUP
  read -ra states_array <<< "${ref[states]}"
  for STATES in ${states_array[@]}; do
    MODELS_ROOT="${MODELS_DIR}/models_${STATES}_states"
    RESULTS_ROOT="${RESULTS_DIR}/results_${STATES}_states"
    OUTER=${ref[group]}
    for INNER in {01..10}; do
      TEST_SCP="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/test${OUTER}_state${INNER}.scp"
      TEST_MLF="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/test${OUTER}_state${INNER}.mlf"
      if [ "$STATES" -le 5 ]; then
        START=11
      else
        START=1
      fi
      for (( g=${START}; g<=${ref[gaussians]}; g++)); do
        MACROS_FILE="${MODELS_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm6_${g}/macros"
        HMMDEFS_FILE="${MODELS_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm6_${g}/hmmdefs"
        HVITE_OUT_DIR="${RESULTS_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/${g}_gaussians/HVite"
        HRESULTS_OUT_DIR="${RESULTS_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/${g}_gaussians/HResults"
        mkdir -p "$HVITE_OUT_DIR"
        mkdir -p "$HRESULTS_OUT_DIR"
        RECOUT_FILE="${HVITE_OUT_DIR}/recout${OUTER}_state${INNER}.mlf"
        RESULTS_FILE="${HRESULTS_OUT_DIR}/results${OUTER}_state${INNER}.txt"

        echo ">>> HVite: Fold=${OUTER}_${INNER} (${STATES} estados, ${g} gaussianas)"
        HVite -H "$MACROS_FILE" \
              -H "$HMMDEFS_FILE" \
              -S "$TEST_SCP" \
              -i "$RECOUT_FILE" \
              -w "$GRADES" \
              "$DICT_FILE" \
              "$CLASSES_FILE"
        echo ">>> HResults: Fold=${OUTER}_${INNER} (${STATES} estados, ${g} gaussianas)"
        HResults -I "$TEST_MLF" "$CLASSES_FILE" "$RECOUT_FILE" > "$RESULTS_FILE"
      done
    done
  done
done


echo "HVite y HResults completado"