#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

BASE_DIR="./trainings"
MODELS_DIR="./models"
CLASSES_FILE="./classes"

declare -A group01=(
  [group]="01"
  [states]="4"
)

declare -A group02=(
  [group]="02"
  [states]="3"
)

declare -A group03=(
  [group]="03"
  [states]="12"
)

declare -A group04=(
  [group]="04"
  [states]="3"
)

declare -A group05=(
  [group]="05"
  [states]="5"
)

declare -A group06=(
  [group]="06"
  [states]="6"
)

declare -A group07=(
  [group]="07"
  [states]="4"
)

declare -A group08=(
  [group]="08"
  [states]="4"
)

declare -A group09=(
  [group]="09"
  [states]="5"
)

declare -A group10=(
  [group]="10"
  [states]="4"
)

group_list=(group01 group02 group03 group04 group05 group06 group07 group08 group09 group10)

for GROUP in "${group_list[@]}"; do
  declare -n ref=$GROUP
  STATES="${ref[states]}"
  PROTO="proto_${STATES}_states"
  RESULT_ROOT="${MODELS_DIR}/models_${STATES}_states"
  OUTER=${ref[group]}
  echo "==============================================="
  echo " Ejecutando HCompV para el grupo ${OUTER} (${STATES} estados)"
  echo "==============================================="
  TRAIN_SCP="${BASE_DIR}/Train${OUTER}/Train${OUTER}.scp"
  OUT_DIR="${RESULT_ROOT}/Group_${OUTER}/hmm0_1"

  mkdir -p "$OUT_DIR"
  echo ">>> HCompV: Train${OUTER} (${STATES} estados)"
  HCompV -f 0.01 -m -S "$TRAIN_SCP" -M "$OUT_DIR" "./$PROTO"
  bloque=$(awk '/<BEGINHMM>/{flag=1} flag' "${OUT_DIR}/$PROTO")
  hmmdefs="${OUT_DIR}/hmmdefs"
  macros="${OUT_DIR}/macros"
  while read -r nombre; do
    {
      echo "~h \"$nombre\""
      printf '%s\n' "$bloque"
      echo ""
    } >> "$hmmdefs"
  done < "$CLASSES_FILE"

  echo "~o <VecSize> 6<USER><DIAGC>" > "$macros"
  cat "${OUT_DIR}/vFloors" >> "$macros"
done

echo "HCompV completado para todos los estados."