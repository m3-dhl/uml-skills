---
name: revisar-modelo-uc
description: >
  Este skill debe usarse para auditar la calidad de un modelo de casos de uso
  antes de darlo por bueno: "revisa estos casos de uso", "esta bien este
  diagrama UML?", "valida el modelo antes de enviarlo al cliente", "que falta en
  esta documentacion de casos de uso", "hay errores en las relaciones include y
  extend". Detecta antipatrones, incoherencias entre diagrama y fichas, y huecos
  de cobertura, y devuelve hallazgos priorizados con la correccion concreta.
metadata:
  version: "0.1.0"
---

# Revision de calidad del modelo de casos de uso

Auditar un modelo antes de que llegue a desarrollo, a QA o al cliente. Es el paso
que evita que un error de modelado se propague a estimaciones y a pruebas.

## Paso 0: validacion automatica (obligatorio, antes de leer nada)

Ejecutar primero:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/validar-modelo.sh" <directorio-del-proyecto>
```

Comprueba mecanicamente lo que un LLM puede pasar por alto al leer deprisa: IDs
`ACT-nn`/`UC-nn` duplicados (tipico cuando dos personas trabajan en paralelo en
ramas distintas), IDs usados en el diagrama sin dar de alta en los catalogos, y
`.svg` desactualizados respecto a su `.puml`.

Si termina con exit code 1, **no continuar con las seis dimensiones**: resolver
primero los errores que reporta (son objetivos, no de criterio) y volver a
ejecutarlo. Los avisos (exit 0) se pueden arrastrar a la revision cualitativa
como hallazgos menores.

## Como ejecutar la revision cualitativa

Para modelos de mas de ~10 casos de uso o cuando el usuario pide una revision
formal, delegar el analisis en el agente `analista-casos-uso` mediante la
herramienta Agent. El agente revisa con criterio independiente, sin el sesgo de
haber escrito el modelo. Para modelos pequenos, aplicar las comprobaciones
directamente.

## Material de entrada

Reunir todo lo que exista: `.puml`, imagenes renderizadas, `catalogo-actores.md`,
`catalogo-casos-uso.md`, fichas `UC-*.md`, `reglas-negocio.md` y, si esta
disponible, el documento de requisitos original. **Revisar solo el diagrama es
una revision incompleta**: la mayoria de los defectos graves viven en las fichas.

## Las seis dimensiones

### 1. Correccion notacional

- `<<include>>` va del caso base al incluido; `<<extend>>` va de la extension al
  base. La flecha invertida es el defecto mas frecuente en modelos reales.
- No existen asociaciones actor-actor: entre actores solo cabe generalizacion.
- Todo caso de uso esta dentro de la frontera; todo actor, fuera.
- Toda relacion entre casos de uso lleva estereotipo (`..>` a secas es ambiguo).
- Todo caso de uso alcanzable desde algun actor, directamente o via `<<include>>`.
- Ningun actor sin asociaciones.

### 2. Granularidad y nivel

- Casos de uso que en realidad son pasos ("Introducir datos", "Confirmar").
- Casos de uso que en realidad son pantallas ("Acceder al panel").
- CRUD explotado en cuatro casos de uso sin justificacion de actor o de regla.
- Mezcla de niveles en un mismo diagrama: casos de resumen junto a subfunciones.
- Mas relaciones entre casos de uso que asociaciones con actores: sintoma de que
  el modelo describe diseno interno en lugar de objetivos de negocio.

### 3. Nomenclatura

- Verbo en infinitivo + objeto. "Gestion de pedidos" y "Pedidos" no son nombres
  de caso de uso.
- Actores como rol, no como persona ni como departamento concreto.
- IDs unicos, estables y coherentes entre diagrama, catalogo y fichas.
- Terminologia consistente: si negocio dice "expediente", el modelo entero dice
  "expediente" y no alterna con "caso" o "solicitud".

### 4. Completitud de las fichas

- Flujo basico sin condicionales y con final explicito.
- Toda excepcion indica como termina el caso de uso.
- Precondiciones que son estados, no comprobaciones.
- Postcondiciones observables y verificables.
- Pasos libres de referencias a la interfaz.
- Reglas de negocio referenciadas, no copiadas.
- Requisitos no funcionales que se han colado como casos de uso.

### 5. Coherencia entre artefactos

- Todo caso de uso del diagrama tiene ficha y viceversa.
- Todo `<<include>>` del diagrama aparece en el flujo de la ficha del caso base.
- Los actores de la ficha coinciden con los del diagrama.
- Los IDs coinciden en los tres artefactos.

### 6. Cobertura funcional

Contrastar contra el documento de requisitos, si existe. Y buscar los olvidos
tipicos: administracion y alta de usuarios, gestion de permisos, procesos
programados, tratamiento de errores e incidencias, informes y extracciones,
configuracion inicial, migracion de datos, y ejercicio de derechos RGPD.

El catalogo completo de antipatrones, con ejemplo y correccion de cada uno, esta
en `references/antipatrones.md`.

## Informe de salida

Devolver los hallazgos priorizados, nunca una lista plana. Formato:

```
## Resumen
Modelo: <nombre>   Casos de uso: 24   Actores: 6   Fichas: 18/24
Veredicto: apto con correcciones / requiere rehacer <parte>

## Criticos (impiden implementar o probar correctamente)
1. [UC-07] La relacion <<include>> hacia UC-02 esta invertida.
   Ahora: UC02 ..> UC07 : <<include>>
   Debe ser: UC07 ..> UC02 : <<include>>
   Impacto: desarrollo entendera que UC-02 siempre invoca UC-07, que es al reves.

## Mayores (comprometen la calidad del entregable)
...

## Menores (consistencia y forma)
...

## Huecos de cobertura
- No hay ningun caso de uso de administracion de usuarios. Confirmar si esta
  fuera de alcance o falta.

## Preguntas para negocio
- Q1. ...
```

Reglas del informe:

- Cada hallazgo lleva **la correccion concreta**, no solo el diagnostico.
- Cada hallazgo lleva su **impacto**, en terminos de lo que le pasara a
  desarrollo o a QA si no se corrige. Es lo que consigue que se corrija.
- Distinguir un defecto real de una preferencia de estilo, y decirlo.
- Si el modelo esta bien, decirlo sin inventar hallazgos de relleno. Un informe
  con quince observaciones menores y ninguna critica hace que nadie lea el
  siguiente.

## Cierre

Ofrecer aplicar las correcciones criticas y mayores directamente sobre los
ficheros y regenerar el diagrama con `diagramar-casos-uso`.
