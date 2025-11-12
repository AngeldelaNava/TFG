@echo off
REM === Crear estructura de resultados HTK (sin carpetas hmm) ===
for %%S in (3 4 5) do (
  mkdir models_%%S_states
  for /L %%G in (1,1,10) do (
    setlocal enabledelayedexpansion
    set "G00=0%%G"
    set "G=!G00:~-2!"
    mkdir models_%%S_states\Group_!G!
    for /L %%F in (1,1,10) do (
      set "F00=0%%F"
      set "F=!F00:~-2!"
      mkdir models_%%S_states\Group_!G!\Group!G!_!F!
    )
    endlocal
  )
)
echo Estructura creada correctamente.
pause
