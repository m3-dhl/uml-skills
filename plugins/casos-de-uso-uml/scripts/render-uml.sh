#!/usr/bin/env bash
# render-uml.sh - Renderiza ficheros .puml a SVG y/o PNG sin depender de servicios externos.
#
# Uso:
#   render-uml.sh <fichero.puml | directorio> [-f svg|png|both] [-o directorio_salida]
#
# El diagrama NUNCA sale del entorno: se renderiza con plantuml.jar en local.
# Si no encuentra el jar lo descarga una sola vez y lo cachea en ~/.cache/plantuml/.
# Si no hay Graphviz (dot) instalado, cae automaticamente al motor interno Smetana.

set -uo pipefail

FORMAT="both"
OUTDIR=""
INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--format) FORMAT="$2"; shift 2 ;;
    -o|--out)    OUTDIR="$2";  shift 2 ;;
    -h|--help)   sed -n '2,12p' "$0"; exit 0 ;;
    *)           INPUT="$1";   shift ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "ERROR: falta el fichero o directorio .puml de entrada." >&2
  exit 1
fi

CACHE_DIR="${HOME}/.cache/plantuml"
JAR="${PLANTUML_JAR:-}"
PLANTUML_VERSION="${PLANTUML_VERSION:-1.2025.4}"

find_jar() {
  # 1. Variable de entorno explicita
  [[ -n "$JAR" && -f "$JAR" ]] && return 0
  # 2. Jar cacheado de una ejecucion anterior
  if [[ -f "${CACHE_DIR}/plantuml.jar" ]]; then JAR="${CACHE_DIR}/plantuml.jar"; return 0; fi
  # 3. Jar vendorizado dentro del propio plugin (instalaciones sin red)
  local vendored="$(dirname "$0")/../vendor/plantuml.jar"
  if [[ -f "$vendored" ]]; then JAR="$vendored"; return 0; fi
  # 4. Instalacion del sistema (apt/brew/choco)
  if command -v plantuml >/dev/null 2>&1; then JAR="__SYSTEM__"; return 0; fi
  return 1
}

bootstrap_jar() {
  mkdir -p "$CACHE_DIR"
  echo "[render-uml] Descargando PlantUML ${PLANTUML_VERSION} (solo la primera vez)..." >&2

  local urls=(
    "https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar"
    "https://repo1.maven.org/maven2/net/sourceforge/plantuml/plantuml/${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar"
  )
  for url in "${urls[@]}"; do
    if curl -sSL --max-time 120 -o "${CACHE_DIR}/plantuml.jar.tmp" "$url" 2>/dev/null \
       && [[ -s "${CACHE_DIR}/plantuml.jar.tmp" ]] \
       && unzip -l "${CACHE_DIR}/plantuml.jar.tmp" >/dev/null 2>&1; then
      mv "${CACHE_DIR}/plantuml.jar.tmp" "${CACHE_DIR}/plantuml.jar"
      JAR="${CACHE_DIR}/plantuml.jar"
      return 0
    fi
  done
  rm -f "${CACHE_DIR}/plantuml.jar.tmp"

  # Ultimo recurso: el registro npm suele estar permitido donde github/maven no lo estan.
  if command -v npm >/dev/null 2>&1; then
    echo "[render-uml] Descarga directa no disponible, probando via npm..." >&2
    local tmp; tmp="$(mktemp -d)"
    if (cd "$tmp" && npm install node-plantuml --no-audit --no-fund --silent >/dev/null 2>&1) \
       && [[ -f "$tmp/node_modules/node-plantuml/vendor/plantuml.jar" ]]; then
      cp "$tmp/node_modules/node-plantuml/vendor/plantuml.jar" "${CACHE_DIR}/plantuml.jar"
      rm -rf "$tmp"
      JAR="${CACHE_DIR}/plantuml.jar"
      return 0
    fi
    rm -rf "$tmp"
  fi
  return 1
}

if ! command -v java >/dev/null 2>&1; then
  cat >&2 <<'EOF'
ERROR: no hay Java disponible en este entorno y PlantUML lo necesita.
Alternativas:
  - Instalar OpenJDK 17 o superior (apt install default-jre / brew install openjdk).
  - Definir PLANTUML_JAR apuntando a un jar accesible.
EOF
  exit 2
fi

if ! find_jar; then
  bootstrap_jar || {
    cat >&2 <<'EOF'
ERROR: no se ha podido obtener plantuml.jar.
En un entorno sin salida a internet, descarga el jar manualmente desde
https://plantuml.com/download y colocalo en ~/.cache/plantuml/plantuml.jar
o exporta PLANTUML_JAR=/ruta/al/plantuml.jar
EOF
    exit 3
  }
fi

if [[ "$JAR" == "__SYSTEM__" ]]; then
  RUN=(plantuml)
else
  RUN=(java -Djava.awt.headless=true -jar "$JAR")
fi

# Sin Graphviz, PlantUML no dibuja diagramas de casos de uso: usar el motor Smetana.
LAYOUT_ARGS=()
if ! command -v dot >/dev/null 2>&1; then
  LAYOUT_ARGS=(-Playout=smetana)
  echo "[render-uml] Graphviz no encontrado: usando el motor interno Smetana." >&2
fi

OUT_ARGS=()
if [[ -n "$OUTDIR" ]]; then
  mkdir -p "$OUTDIR"
  OUT_ARGS=(-o "$(cd "$OUTDIR" && pwd)")
fi

render() {
  local fmt="$1"
  "${RUN[@]}" "-t${fmt}" -charset UTF-8 "${LAYOUT_ARGS[@]}" "${OUT_ARGS[@]}" "$INPUT" 2>&1 \
    | grep -viE 'picked up java_tool_options|^$' >&2
  return "${PIPESTATUS[0]}"
}

RC=0
case "$FORMAT" in
  svg)  render svg || RC=$? ;;
  png)  render png || RC=$? ;;
  both) render svg || RC=$?; render png || RC=$? ;;
  *)    echo "ERROR: formato '$FORMAT' no soportado (usa svg, png o both)." >&2; exit 1 ;;
esac

if [[ $RC -ne 0 ]]; then
  echo "[render-uml] PlantUML termino con errores. Revisa la sintaxis del .puml." >&2
  exit $RC
fi

echo "[render-uml] Listo. Salida en: ${OUTDIR:-$(dirname "$INPUT")}" >&2
