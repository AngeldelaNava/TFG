#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

BASE_DIR="./trainings"
MODELS_DIR="./models"
RESULTS_DIR="./results"
CLASSES_FILE="./classes"
DICT_FILE="./dict"
GRADES="./grades"


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
  MODELS_ROOT="${MODELS_DIR}/models_${STATES}_states"
  RESULTS_ROOT="${RESULTS_DIR}/results_${STATES}_states"
  OUTER=${ref[group]}
  g=${ref[gaussians]}
  MACROS_FILE="${MODELS_ROOT}/Group_${OUTER}/hmm6_${g}/macros"
  HMMDEFS_FILE="${MODELS_ROOT}/Group_${OUTER}/hmm6_${g}/hmmdefs"
  TEST_SCP="${BASE_DIR}/Train${OUTER}/test${OUTER}.scp"
  TEST_MLF="${BASE_DIR}/Train${OUTER}/test${OUTER}.mlf"
  HVITE_OUT_DIR="${RESULTS_ROOT}/Group_${OUTER}/${g}_gaussians/HVite"
  HRESULTS_OUT_DIR="${RESULTS_ROOT}/Group_${OUTER}/${g}_gaussians/HResults"
  mkdir -p "$HVITE_OUT_DIR"
  mkdir -p "$HRESULTS_OUT_DIR"
  RECOUT_FILE="${HVITE_OUT_DIR}/recout${OUTER}.mlf"
  RESULTS_FILE="${HRESULTS_OUT_DIR}/results${OUTER}.txt"

  echo ">>> HVite: Fold=${OUTER} (${STATES} estados, ${g} gaussianas)"
  HVite -H "$MACROS_FILE" \
        -H "$HMMDEFS_FILE" \
        -S "$TEST_SCP" \
        -i "$RECOUT_FILE" \
        -w "$GRADES" \
        "$DICT_FILE" \
        "$CLASSES_FILE"
  echo ">>> HResults: Fold=${OUTER} (${STATES} estados, ${g} gaussianas)"
  HResults -I "$TEST_MLF" "$CLASSES_FILE" "$RECOUT_FILE" > "$RESULTS_FILE"
done


echo "HVite y HResults completado para todos los estados"