# Casos de Uso UML

Pack de skills para convertir descripciones de funcionalidad en modelos de
casos de uso UML completos — diagramas, fichas, revision de calidad y dossier
entregable — sin que nadie tenga que escribir PlantUML a mano. Pensado para
que **consultoria, desarrollo y calidad trabajen sobre el mismo modelo**.

## Empieza aqui

```
/uml
```

Es lo unico que hay que recordar. El agente pregunta que quieres hacer y
deriva al skill adecuado — analizar una funcionalidad nueva, generar solo el
diagrama, redactar fichas, auditar un modelo o montar el entregable. Si ya lo
dices en el propio mensaje ("dibuja los casos de uso de este texto"), deriva
directo, sin menu:

```
/uml Estamos haciendo un portal donde los clientes suben facturas, un
gestor las valida y se envian al ERP. Documentalo para consultoria y QA.
```

A partir de ahi solo hay que ir corrigiendo suposiciones. Documentos
funcionales, historias de usuario o correos adjuntos cuentan como parte del
prompt.

## Que hace por debajo

1. **Esboza un modelo preliminar** a partir de lo que ya sabe, marcando cada
   elemento como dato del texto, inferido o supuesto.
2. **Entrevista solo sobre los huecos** que detecta, con la prediccion
   adjunta en cada pregunta — corregir cuesta menos que responder en blanco.
3. **Encadena diagrama → fichas → auditoria** una vez el encuadre esta
   confirmado.

## Skills del pack

| Skill | Que hace |
| --- | --- |
| `uml` | Menu de entrada. Punto de partida recomendado. |
| `analizar-funcionalidad` | De una descripcion en prosa al modelo completo auditado. |
| `descubrir-casos-uso` | Entrevista para identificar frontera, actores y objetivos. |
| `diagramar-casos-uso` | Genera el `.puml` y lo renderiza a SVG/PNG en local. |
| `especificar-casos-uso` | Redacta las fichas en formato Cockburn. |
| `revisar-modelo-uc` | Audita el modelo contra 20 antipatrones conocidos. |
| `publicar-dossier-uc` | Monta el entregable final (Word, PDF, Markdown, HTML). |

Todos son invocables por separado con `/casos-de-uso-uml:<nombre>` si ya sabes
por donde entrar (por ejemplo, hay catalogos y solo falta el diagrama). El
agente `analista-casos-uso` audita con criterio independiente cuando el
modelo supera los 10 casos de uso.

## Por que PlantUML y no Mermaid

Mermaid no soporta diagramas de casos de uso UML. PlantUML si, de forma
nativa: actores, frontera del sistema, `<<include>>`, `<<extend>>` y
generalizacion. El `.puml` es texto plano — se versiona en Git y se revisa en
un pull request como cualquier otro fuente, sin depender de un binario opaco
de una herramienta de modelado.

## Renderizado, en local

`scripts/render-uml.sh` renderiza sin enviar el modelo a ningun servicio
externo — importa cuando el diagrama describe el sistema de un cliente.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/render-uml.sh" diagramas/DCU-01.puml -f both
```

Se autoconfigura solo: busca `plantuml.jar` (variable `PLANTUML_JAR`,
`~/.cache/plantuml/`, `vendor/` del plugin, o `plantuml` del sistema), lo
descarga y cachea si no lo encuentra, y cae al motor interno Smetana si no
hay Graphviz instalado. Unico requisito: Java 8+.

<details>
<summary>Instalacion sin salida a internet</summary>

Descargar `plantuml.jar` de https://plantuml.com/download y:

- colocarlo en `~/.cache/plantuml/plantuml.jar`, o
- exportar `PLANTUML_JAR=/ruta/al/plantuml.jar`, o
- crear `vendor/` en la raiz del plugin y dejarlo ahi antes de empaquetar.

</details>

## Validacion del modelo

`scripts/validar-modelo.sh` comprueba mecanicamente lo que `revisar-modelo-uc`
audita con criterio: IDs `ACT-nn`/`UC-nn` duplicados (riesgo real cuando dev y
consultoria trabajan en paralelo en ramas distintas), IDs de un diagrama sin
dar de alta en los catalogos, e imagenes `.svg` desactualizadas respecto a su
`.puml`. `revisar-modelo-uc` y `publicar-dossier-uc` lo ejecutan solos como
primer paso; tambien se puede lanzar a mano:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/validar-modelo.sh" .
```

No hay hook de Git instalado por defecto: quien edite los `.puml` a mano fuera
de Claude no pasa por esta validacion salvo que la ejecute el mismo.

## Personalizacion

| Que cambiar | Donde |
| --- | --- |
| Estilo visual (colores, tipografia) | `assets/estilo.puml` — afecta a todos los diagramas |
| Convenciones de ID (`ACT-nn`, `UC-nn`, `RN-nn`) | los `SKILL.md` correspondientes |
| Plantilla de ficha | `skills/especificar-casos-uso/references/plantilla-ficha.md` |
| Version de PlantUML | variable `PLANTUML_VERSION` en `render-uml.sh` |

## Estructura

```
casos-de-uso-uml/
├── .claude-plugin/plugin.json
├── agents/analista-casos-uso.md
├── assets/estilo.puml
├── scripts/render-uml.sh
├── scripts/validar-modelo.sh
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

- **UML 2.5** para la semantica de actores, frontera, `<<include>>`,
  `<<extend>>` y generalizacion.
- **Alistair Cockburn**, *Writing Effective Use Cases*, para los niveles de
  objetivo y la plantilla "fully dressed" de las fichas.
- **PlantUML** como notacion textual.
- Tecnica de entrevista inspirada en el patron *interview-me* de Addy Osmani:
  hipotesis con confianza declarada, prediccion adjunta a cada pregunta y
  criterio de parada verificable.

Version 0.3.0
