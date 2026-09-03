#!/usr/bin/env bash
# validar-modelo.sh - Valida integridad y coherencia de un modelo de casos de uso.
#
# Uso:
#   validar-modelo.sh [directorio]        (por defecto: directorio actual)
#
# Comprueba:
#   1. IDs duplicados (ACT-nn, UC-nn) en catalogos y fichas.
#   2. IDs usados en diagramas .puml que no estan dados de alta en los catalogos.
#   3. Imagenes .svg mas antiguas que su .puml de origen (desactualizadas o
#      inexistentes).
#
# Pensado para que revisar-modelo-uc y publicar-dossier-uc lo ejecuten como
# primer paso, no como recordatorio textual: el exit code decide si se sigue.
#
# Exit 0: todo correcto (puede haber avisos, no bloquean).
# Exit 1: hay errores que deben resolverse antes de mergear o publicar.
# Exit 2: uso incorrecto (directorio inexistente).

set -uo pipefail

ROOT="${1:-.}"
ERRORS=0
WARNINGS=0

err()  { echo "ERROR: $*" >&2; ERRORS=$((ERRORS + 1)); }
warn() { echo "AVISO: $*" >&2; WARNINGS=$((WARNINGS + 1)); }

if [[ ! -d "$ROOT" ]]; then
  echo "ERROR: no existe el directorio '$ROOT'." >&2
  exit 2
fi

cd "$ROOT" || exit 2

MD_FILES=$(find . -name '*.md' -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null)
PUML_FILES=$(find . -name '*.puml' -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null)

echo "=== 1. IDs duplicados ==="

if [[ -f catalogo-actores.md ]]; then
  dups=$(grep -oE '^\| *ACT-[0-9]+' catalogo-actores.md 2>/dev/null | tr -d ' |' | sort | uniq -d)
  if [[ -n "$dups" ]]; then
    while read -r id; do err "ID '$id' aparece dos veces en catalogo-actores.md"; done <<< "$dups"
  fi
else
  warn "no se encuentra catalogo-actores.md: no se puede validar duplicados de actores"
fi

if [[ -f catalogo-casos-uso.md ]]; then
  dups=$(grep -oE '^\| *UC-[0-9]+' catalogo-casos-uso.md 2>/dev/null | tr -d ' |' | sort | uniq -d)
  if [[ -n "$dups" ]]; then
    while read -r id; do err "ID '$id' aparece dos veces en catalogo-casos-uso.md"; done <<< "$dups"
  fi
else
  warn "no se encuentra catalogo-casos-uso.md: no se puede validar duplicados de casos de uso"
fi

# Fichas: un "## UC-nn" solo debe definirse una vez en todo el arbol de ficheros.
if [[ -n "$MD_FILES" ]]; then
  dups_fichas=$(echo "$MD_FILES" | xargs grep -hoE '^## UC-[0-9]+' 2>/dev/null | tr -d ' #' | sort | uniq -d)
  if [[ -n "$dups_fichas" ]]; then
    while read -r id; do err "hay mas de una ficha con encabezado '## $id'"; done <<< "$dups_fichas"
  fi
fi

echo "=== 2. IDs referenciados sin definir ==="

known_act=$(grep -oE '^\| *ACT-[0-9]+' catalogo-actores.md 2>/dev/null | tr -d ' |' | sort -u)
known_uc=$(grep -oE '^\| *UC-[0-9]+' catalogo-casos-uso.md 2>/dev/null | tr -d ' |' | sort -u)

if [[ -n "$PUML_FILES" ]]; then
  used_ids=$(echo "$PUML_FILES" | xargs grep -hoE '(ACT|UC)-[0-9]+' 2>/dev/null | sort -u)
  while read -r id; do
    [[ -z "$id" ]] && continue
    case "$id" in
      ACT-*) echo "$known_act" | grep -qx "$id" || warn "'$id' aparece en un diagrama pero no en catalogo-actores.md" ;;
      UC-*)  echo "$known_uc"  | grep -qx "$id" || warn "'$id' aparece en un diagrama pero no en catalogo-casos-uso.md" ;;
    esac
  done <<< "$used_ids"
fi

echo "=== 3. Imagenes desactualizadas ==="

if [[ -n "$PUML_FILES" ]]; then
  while read -r puml; do
    [[ -z "$puml" ]] && continue
    base="${puml%.puml}"
    svg="${base}.svg"
    if [[ ! -f "$svg" ]]; then
      warn "no existe '$svg' para '$puml' (falta renderizar)"
    elif [[ "$puml" -nt "$svg" ]]; then
      err "'$svg' esta desactualizado respecto a '$puml' (regenerar con render-uml.sh)"
    fi
  done <<< "$PUML_FILES"
fi

echo
echo "=== Resumen ==="
echo "Errores: $ERRORS   Avisos: $WARNINGS"

if [[ "$ERRORS" -gt 0 ]]; then
  exit 1
fi
exit 0
