---
name: uml
description: >
  Menu de entrada del pack de casos de uso UML. Este skill debe usarse cuando
  alguien quiere trabajar con casos de uso pero no sabe por que skill empezar, o
  simplemente escribe "uml", "casos de uso", "quiero hacer algo con UML",
  "ayudame con los casos de uso". Pregunta que se quiere hacer ofreciendo
  opciones concretas y deriva al skill adecuado del pack.
metadata:
  version: "0.1.0"
---

# Menu del pack de casos de uso

Enrutar al skill correcto. Este skill **no hace el trabajo**: identifica la
intencion y delega. No duplicar aqui la logica de los demas skills.

## 1. Atajo: intencion ya evidente

Si la invocacion trae texto (`$ARGUMENTS`) o el contexto de la conversacion ya
deja clara la intencion, **no preguntar nada**: derivar directamente y decir en
una linea a que skill se ha derivado y por que.

| El texto indica | Derivar a |
| --- | --- |
| Describe una funcionalidad, un modulo o un proceso | `analizar-funcionalidad` |
| Pide dibujar, generar o actualizar un diagrama | `diagramar-casos-uso` |
| Pide detallar flujos, fichas, excepciones o pruebas | `especificar-casos-uso` |
| Pide revisar, validar o auditar algo existente | `revisar-modelo-uc` |
| Pide un documento, entregable, Word o PDF | `publicar-dossier-uc` |
| Pide solo identificar actores y objetivos | `descubrir-casos-uso` |

Ejemplo: `/uml revisa el diagrama de facturacion que hay en la carpeta` -> ir
directo a `revisar-modelo-uc`, sin menu.

Antes de derivar, mirar la carpeta de trabajo: la presencia de `*.puml`,
`catalogo-*.md` o fichas `UC-*.md` indica en que punto esta el proyecto y suele
resolver la ambiguedad sin preguntar.

## 2. Menu

Si la intencion no esta clara, usar `AskUserQuestion` con esta primera pregunta.
Las opciones se ofrecen tal cual; el campo de texto libre lo anade la propia
herramienta.

**"¿Que quieres hacer con los casos de uso?"**

| Opcion | Descripcion que mostrar | Deriva a |
| --- | --- | --- |
| Analizar una funcionalidad desde cero | Describes la funcionalidad y te devuelvo el modelo completo: actores, diagrama, fichas y auditoria. Te preguntare solo lo que no pueda deducir | `analizar-funcionalidad` |
| Trabajar sobre un modelo que ya existe | Ya hay catalogos, un diagrama o fichas a medias y quieres generar o completar una parte concreta | Segunda pregunta |
| Revisar y auditar un modelo | Informe de calidad contra 20 antipatrones, con la correccion de cada hallazgo. Sirve tambien para documentacion recibida de terceros | `revisar-modelo-uc` |
| Montar el documento entregable | Reune diagramas, fichas y trazabilidad en un Word, PDF o pagina web con portada e indice | `publicar-dossier-uc` |

**Segunda pregunta**, solo si se ha elegido "Trabajar sobre un modelo que ya
existe": *"¿Que parte quieres generar?"*

| Opcion | Descripcion que mostrar | Deriva a |
| --- | --- | --- |
| El diagrama | Genero el `.puml` y lo renderizo a SVG y PNG en local | `diagramar-casos-uso` |
| Las fichas de especificacion | Flujo basico, alternativos, excepciones y matriz de trazabilidad para QA | `especificar-casos-uso` |
| Los catalogos de actores y casos de uso | Entrevista para identificar frontera, actores y objetivos | `descubrir-casos-uso` |

## 3. Respuesta en texto libre

Si el usuario escribe en el campo libre en lugar de elegir opcion, interpretar la
intencion y derivar. Casos que no encajan en ninguna opcion:

- **"No se por donde empezar" / "explicame que hace esto"**: explicar el flujo del
  pack en cuatro lineas y volver a ofrecer el menu. No derivar a ciegas.
- **Pide un tipo de diagrama que no es de casos de uso** (secuencia, actividad,
  clases, estados): decir que el pack esta especializado en casos de uso, y que
  ese diagrama se puede hacer igualmente en PlantUML y renderizar con el mismo
  script (`scripts/render-uml.sh`), pero sin las plantillas ni la auditoria del
  pack.
- **Pide algo ajeno al modelado** (estimar, implementar, hacer pruebas): decirlo y
  ofrecer lo mas cercano que si cubre el pack.
- **Ambiguo entre dos opciones**: preguntar una sola vez mas, con las dos
  candidatas y la diferencia entre ellas. No adivinar.

## 4. Al derivar

Invocar el skill destino y **continuar el trabajo en la misma conversacion**. No
devolver el control al usuario con un "ahora ejecuta /casos-de-uso-uml:...": el
sentido de este menu es evitarle tener que conocer los nombres de los skills.

Pasar al skill destino todo el contexto ya recogido: el texto de `$ARGUMENTS`, la
respuesta del menu y los ficheros del modelo que se hayan localizado en la
carpeta de trabajo.
