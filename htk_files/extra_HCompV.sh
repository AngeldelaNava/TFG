#!/bin/bash
set -eu
trap 'echo "Error en línea $LINENO: comando \"$BASH_COMMAND\" falló."; exit 1' ERR

BASE_DIR="./trainings"
MODELS_DIR="./models"
CLASSES_FILE="./classes"

declare -A group03=(
  [group]="03"
  [states]="6 7"
)

declare -A group05=(
  [group]="05"
  [states]="6 7"
)

declare -A group06=(
  [group]="06"
  [states]="6 7"
)

declare -A group09=(
  [group]="09"
  [states]="6 7"
)

group_list=(group03 group05 group06 group09)

for GROUP in "${group_list[@]}"; do
  declare -n ref=$GROUP
  read -ra states_array <<< "${ref[states]}"
  for STATES in ${states_array[@]}; do
    PROTO="proto_${STATES}_states"
    RESULT_ROOT="${MODELS_DIR}/models_${STATES}_states"
    OUTER=${ref[group]}
    for INNER in {01..10}; do
      echo "==============================================="
      echo " Ejecutando HCompV para el grupo ${OUTER} (${STATES} estados)"
      echo "==============================================="
      TRAIN_SCP="${BASE_DIR}/Train${OUTER}/folds/fold${INNER}/Train${OUTER}_state${INNER}.scp"
      OUT_DIR="${RESULT_ROOT}/Group_${OUTER}/Group${OUTER}_${INNER}/hmm0_1"

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
  done
done

echo "HCompV completado para todos los estados."