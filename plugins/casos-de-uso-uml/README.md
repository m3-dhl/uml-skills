# Casos de Uso UML

Pack de skills para convertir descripciones de funcionalidad en modelos de casos
de uso UML completos: diagramas, fichas de especificacion, revision de calidad y
dossier entregable. Pensado para que **consultoria, desarrollo y calidad trabajen
sobre el mismo modelo** sin que ninguno tenga que escribir PlantUML a mano.

## Que resuelve

Le pasas un prompt con la descripcion de la funcionalidad. El pack **esboza
primero un modelo preliminar**, mide cuanto de el es dato tuyo y cuanto es
suposicion suya, y **entrevista solo sobre los huecos** que ha detectado, con la
prediccion adjunta en cada pregunta. Cuando el encuadre esta confirmado, encadena
solo: diagrama, fichas y auditoria.

## Uso normal

Si no sabes por donde empezar, el menu pregunta y deriva solo:

```
/casos-de-uso-uml:uml
```

Y si ya sabes lo que quieres, directo:

```
/casos-de-uso-uml:analizar-funcionalidad Estamos haciendo un portal donde los
clientes suben facturas, un gestor las valida y se envian al ERP. Hay que
documentar los casos de uso para consultoria y para QA.
```

A partir de ahi solo hay que ir corrigiendo suposiciones. Los adjuntos (documento
funcional, historias de usuario, correos) cuentan como parte del prompt base.

## Skills

| Skill | Que hace | Salida |
| --- | --- | --- |
| `uml` | **Menu.** Pregunta que quieres hacer y deriva al skill adecuado | — |
| `analizar-funcionalidad` | **Punto de entrada.** Borrador → cobertura → entrevista sobre huecos → encadena el resto | Modelo completo auditado |
| `descubrir-casos-uso` | Entrevista por tandas para identificar frontera, actores y objetivos | `catalogo-actores.md`, `catalogo-casos-uso.md` |
| `diagramar-casos-uso` | Genera el diagrama y lo renderiza en local | `.puml` + `.svg` + `.png` |
| `especificar-casos-uso` | Redacta las fichas formato Cockburn | `UC-nn-*.md`, `matriz-trazabilidad.md` |
| `revisar-modelo-uc` | Audita el modelo contra 20 antipatrones | Informe priorizado |
| `publicar-dossier-uc` | Monta el entregable final | `.docx` / `.pdf` / Markdown / HTML |

Los skills se invocan solos cuando el contexto encaja, o a mano con
`/casos-de-uso-uml:<nombre>`.

## Agente

`analista-casos-uso` audita el modelo con criterio independiente. Lo usa
`revisar-modelo-uc` para modelos de mas de 10 casos de uso.

## Flujo

```
Prompt base + adjuntos
        v
/casos-de-uso-uml:analizar-funcionalidad
        |
        |-- Fase 1  Borrador v0, con cada elemento marcado
        |            (dato del texto / [INFERIDO] / [SUPUESTO])
        |-- Fase 2  Cobertura y confianza. ¿Va bien encaminado?
        |-- Fase 3  Entrevista SOLO sobre los huecos,
        |            con la prediccion adjunta en cada pregunta
        |-- Fase 4  Parada: "¿puedo predecir tus 3 siguientes respuestas?"
        |            + devolucion del encuadre, incluido el fuera de alcance
        |-- Fase 5  Encadena diagrama -> fichas -> revision
        v
Modelo auditado + cuestiones abiertas
        v
/casos-de-uso-uml:publicar-dossier-uc   (solo si se pide)
```

Los demas skills siguen siendo invocables por separado, para entrar por el medio:
si ya hay catalogos, se entra por `diagramar-casos-uso`; si llega documentacion de
un tercero y solo se quiere la auditoria, por `revisar-modelo-uc`.

### Por que borrador primero y preguntas despues

Corregir una suposicion cuesta al interlocutor mucho menos esfuerzo que responder
desde una pagina en blanco, y destapa desacuerdos que una pregunta abierta no
destapa: nadie corrige lo que no ve. Por eso cada pregunta se formula como
hipotesis ("asumo que la devolucion la autoriza el Gestor, ¿o hay un rol de
Atencion al Cliente?") y no como pregunta abierta.

La cadencia es hibrida: en tanda de 2-3 lo enumerable e independiente (actores,
alcance, prioridades) y de una en una lo que condiciona la siguiente pregunta.

## Por que PlantUML y no Mermaid

Mermaid no soporta diagramas de casos de uso UML: no esta entre sus tipos de
diagrama. PlantUML si, de forma nativa, con actores, frontera del sistema,
`<<include>>`, `<<extend>>` y generalizacion. Ademas el `.puml` es texto plano,
asi que se versiona en Git y se revisa en un pull request como cualquier otro
fuente, en lugar de ser un binario opaco de una herramienta de modelado.

## Renderizado

`scripts/render-uml.sh` renderiza **en local**, sin enviar el modelo a ningun
servicio externo. Importa cuando el diagrama describe el sistema de un cliente.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/render-uml.sh" diagramas/DCU-01.puml -f both
bash "${CLAUDE_PLUGIN_ROOT}/scripts/render-uml.sh" diagramas/ -f svg -o entregables/img
```

El script se autoconfigura:

1. Busca `plantuml.jar` en `PLANTUML_JAR`, en `~/.cache/plantuml/`, en
   `vendor/` del plugin, o como `plantuml` del sistema.
2. Si no lo encuentra, lo descarga una sola vez (GitHub releases, Maven Central,
   o el registro npm como ultimo recurso) y lo cachea.
3. Si no hay Graphviz instalado, usa el motor interno Smetana de PlantUML.

Requisito unico: **Java 8 o superior**. Los entornos de Claude ya lo traen.

### Instalacion sin salida a internet

Descargar `plantuml.jar` de https://plantuml.com/download y:

- colocarlo en `~/.cache/plantuml/plantuml.jar`, o
- exportar `PLANTUML_JAR=/ruta/al/plantuml.jar`, o
- crear `vendor/` en la raiz del plugin y dejarlo ahi antes de empaquetar.

## Personalizacion

**Estilo visual**: editar `assets/estilo.puml` (colores, tipografia, estereotipos).
Cambia todos los diagramas a la vez.

**Convenciones**: los skills usan `ACT-nn`, `UC-nn` y `RN-nn`. Para adaptarlos a
la nomenclatura del cliente, editar los SKILL.md correspondientes.

**Plantilla de ficha**: `skills/especificar-casos-uso/references/plantilla-ficha.md`.

**Version de PlantUML**: variable `PLANTUML_VERSION` del script.

## Estructura

```
casos-de-uso-uml/
├── .claude-plugin/plugin.json
├── agents/analista-casos-uso.md
├── assets/estilo.puml
├── scripts/render-uml.sh
└── skills/
    ├── uml/                      (menu de entrada)
    ├── analizar-funcionalidad/   (+ references/tecnica-entrevista.md)
    ├── descubrir-casos-uso/      (+ references/heuristicas-descubrimiento.md)
    ├── diagramar-casos-uso/      (+ references/plantuml-casos-uso.md)
    ├── especificar-casos-uso/    (+ references/plantilla-ficha.md)
    ├── revisar-modelo-uc/        (+ references/antipatrones.md)
    └── publicar-dossier-uc/
```

## Base metodologica

- **UML 2.5** para la semantica de actores, frontera, `<<include>>`, `<<extend>>`
  y generalizacion.
- **Alistair Cockburn**, *Writing Effective Use Cases*, para los niveles de
  objetivo (resumen / objetivo de usuario / subfuncion) y la plantilla "fully
  dressed" de las fichas.
- **PlantUML** como notacion textual.
- Tecnica de entrevista inspirada en el patron *interview-me* de Addy Osmani:
  hipotesis con confianza declarada, prediccion adjunta a cada pregunta, y
  criterio de parada verificable ("¿puedo predecir las tres siguientes
  respuestas?") en lugar de una sensacion de haber preguntado bastante.

Version 0.3.0
