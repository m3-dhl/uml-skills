---
name: diagramar-casos-uso
description: >
  Este skill debe usarse cuando hay que producir el diagrama UML de casos de uso
  propiamente dicho: "hazme el diagrama de casos de uso", "dibuja los casos de
  uso", "genera el UML de esta funcionalidad", "quiero el diagrama en PlantUML",
  "actualiza el diagrama con este caso nuevo". Genera el fichero .puml
  versionable y lo renderiza a SVG y PNG en local, sin enviar el modelo a
  ningun servicio externo.
metadata:
  version: "0.1.0"
---

# Generacion del diagrama de casos de uso

Producir el diagrama a partir del catalogo de actores y casos de uso. La fuente
de verdad es el fichero `.puml` (texto, versionable en Git, revisable en un pull
request); el SVG y el PNG son artefactos derivados que se regeneran siempre.

## Por que PlantUML

Mermaid **no soporta diagramas de casos de uso UML** (no esta entre sus tipos de
diagrama). PlantUML si los soporta de forma nativa, con actores, frontera del
sistema, `<<include>>`, `<<extend>>` y generalizacion. Es la notacion por defecto
de este pack. No proponer Mermaid para casos de uso; para diagramas de secuencia
o de actividad que acompanen al modelo, PlantUML tambien sirve y mantiene una
sola herramienta.

## Flujo de trabajo

### 1. Reunir la entrada

Partir de `catalogo-actores.md` y `catalogo-casos-uso.md` si existen. Si no
existen y el usuario solo ha descrito la funcionalidad en prosa, ejecutar antes
el skill `descubrir-casos-uso`: **nunca dibujar sobre supuestos sin validar**.

### 2. Decidir la particion en diagramas

- Hasta ~15 casos de uso: un unico diagrama.
- Mas de 15: un **diagrama de contexto** (actores + paquetes funcionales) mas un
  diagrama por paquete o subsistema. Numerarlos `DCU-00-contexto`,
  `DCU-01-<paquete>`, etc.
- Un diagrama que no se lee entero en una pantalla ya es demasiado grande.

### 3. Escribir el .puml

Guardar en `diagramas/<nombre>.puml`. Esqueleto obligatorio:

```plantuml
@startuml DCU-01-pedidos
!include ../assets/estilo.puml
left to right direction
title Casos de uso - Gestion de pedidos (v0.1)

actor "Cliente" as ACT01
actor "Gestor de pedidos" as ACT02
actor "Pasarela de pago" as ACT03 <<sistema>>

rectangle "Tienda online" {
  usecase "UC-01\nRegistrar pedido"    as UC01
  usecase "UC-02\nValidar stock"       as UC02
  usecase "UC-03\nPagar pedido"        as UC03
  usecase "UC-04\nAplicar descuento"   as UC04
  usecase "UC-05\nCancelar pedido"     as UC05
}

ACT01 --> UC01
ACT01 --> UC03
ACT02 --> UC05
UC03 --> ACT03

UC01 ..> UC02 : <<include>>
UC04 ..> UC01 : <<extend>>
@enduml
```

Reglas de escritura no negociables:

- `left to right direction` casi siempre: los diagramas de casos de uso se leen
  mejor en horizontal.
- Un `rectangle "<nombre del sistema>"` que marca la **frontera**. Los actores
  van **fuera**, los casos de uso **dentro**. Sin frontera el diagrama no dice
  cual es el sistema.
- Etiquetar cada caso de uso con su ID: `usecase "UC-01\nRegistrar pedido"`. Es
  lo que permite trazar diagrama -> ficha -> caso de prueba.
- Alias sin guiones (`UC01`, no `UC-01`) para evitar problemas de parseo.
- Asociacion actor-caso de uso con `-->` y **sin flecha semantica**: la direccion
  indica quien inicia, no un flujo de datos.
- `..>` con estereotipo para dependencias. **La direccion importa** (ver abajo).
- Nada de colores por caso de uso: el estilo vive en `assets/estilo.puml`.

### 4. Include, extend y generalizacion

El error mas frecuente en modelos reales es invertir la flecha. Memorizar:

| Relacion | Sintaxis | Direccion | Significado |
| --- | --- | --- | --- |
| Include | `UC_BASE ..> UC_INCLUIDO : <<include>>` | Del **base** al **incluido** | El base **siempre** ejecuta el incluido. Obligatorio |
| Extend | `UC_EXTENSION ..> UC_BASE : <<extend>>` | De la **extension** al **base** | El comportamiento opcional apunta al caso al que se anade |
| Generalizacion | `UC_HIJO --|> UC_PADRE` | Del hijo al padre | Variante especializada de un caso general |
| Generalizacion de actor | `ACT_HIJO --|> ACT_PADRE` | Del hijo al padre | Un rol hereda los casos de uso de otro |

Guia de uso, no solo de sintaxis:

- Usar `<<include>>` solo cuando el comportamiento se reutiliza desde **dos o
  mas** casos de uso. Un include con un solo llamante es descomposicion
  funcional: mejor dejarlo como paso del flujo basico.
- Usar `<<extend>>` con moderacion. Confunde a los interlocutores de negocio y
  casi siempre se modela mejor como un flujo alternativo dentro de la ficha. Si
  se usa, indicar el punto de extension en la ficha del caso base.
- Si un diagrama tiene mas relaciones entre casos de uso que asociaciones con
  actores, esta modelando diseno interno, no objetivos. Simplificar.

Detalle completo de sintaxis en `references/plantuml-casos-uso.md`.

### 5. Renderizar

Ejecutar el script del plugin, que resuelve por si solo la instalacion de
PlantUML y funciona sin Graphviz:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/render-uml.sh" diagramas/DCU-01-pedidos.puml -f both
```

Genera `DCU-01-pedidos.svg` y `DCU-01-pedidos.png` junto al fuente. Todo el
renderizado ocurre en local: **el modelo funcional no sale del entorno**, lo que
importa cuando el diagrama describe un sistema de un cliente.

Si el script falla, leer el mensaje: distingue entre falta de Java, falta del jar
y error de sintaxis del `.puml`. No caer en servidores publicos de PlantUML ni
en `kroki.io` como alternativa sin autorizacion expresa del usuario, porque eso
implica enviar el modelo a un tercero.

### 6. Verificar antes de entregar

Abrir el SVG generado y comprobar de verdad:

- Renderiza sin errores (un `.puml` invalido produce una imagen con el texto del
  error en rojo, no un fallo del script).
- Todo caso de uso tiene al menos un actor asociado, directamente o via
  `<<include>>` desde otro que si lo tiene.
- Todo actor tiene al menos una asociacion.
- No hay asociaciones actor-actor (solo se permite generalizacion entre actores).
- Los IDs del diagrama coinciden con los del catalogo.

Entregar el `.puml`, el `.svg` y el `.png`, y decir en una linea que hay que
regenerar las imagenes cada vez que cambie el fuente.

### 7. Siguiente paso

Ofrecer `especificar-casos-uso` para las fichas textuales y `revisar-modelo-uc`
para la revision de calidad antes de pasarlo a consultoria o a QA.
