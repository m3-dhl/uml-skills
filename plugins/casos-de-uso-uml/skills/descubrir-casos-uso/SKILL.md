---
name: descubrir-casos-uso
description: >
  Este skill debe usarse cuando alguien describe una funcionalidad, un modulo o
  una aplicacion y necesita convertirla en un modelo de casos de uso: "tengo que
  documentar los casos de uso de...", "quiero sacar los casos de uso de este
  modulo", "ayudame a identificar actores y casos de uso", "vamos a analizar esta
  funcionalidad". Conduce una entrevista guiada por tandas de preguntas y produce
  el catalogo de actores y el catalogo de casos de uso, que son la entrada de los
  skills diagramar-casos-uso y especificar-casos-uso.
metadata:
  version: "0.1.0"
---

# Descubrimiento de casos de uso

Convertir una descripcion informal de funcionalidad en un catalogo de actores y
casos de uso correctamente delimitado. Este skill **no dibuja nada**: produce el
material estructurado que los demas skills del pack consumen.

## Regla de oro

No inventar. Todo actor, caso de uso o regla que no venga del interlocutor se
marca explicitamente como `[SUPUESTO]` y se le pregunta en la siguiente tanda.
Un modelo de casos de uso con supuestos silenciosos es peor que uno incompleto.

## Como preguntar

**Cada pregunta lleva adjunta la prediccion.** Nunca una pregunta abierta:
en vez de "¿que actores hay?", decir "del texto saco Cliente, Gestor y la
pasarela de pago; ¿falta alguien?". Corregir una suposicion cuesta al
interlocutor mucho menos que responder desde cero, y destapa desacuerdos que una
pregunta abierta no destapa.

La tecnica completa - senales de respuesta no valida, preguntas de alto
rendimiento, calibrado de la confianza y cuando dejar de preguntar - esta en
`${CLAUDE_PLUGIN_ROOT}/skills/analizar-funcionalidad/references/tecnica-entrevista.md`.
Leerla antes de empezar la entrevista.

Si lo que hay es un prompt base amplio del que se espera el modelo entero, usar
el skill `analizar-funcionalidad`: genera primero un borrador y entrevista solo
sobre los huecos, que sale mas barato en turnos.

## Flujo de trabajo

### 1. Encuadre (antes de preguntar nada)

Leer todo el material que ya exista: mensajes previos, ficheros adjuntos,
documentos funcionales, historias de usuario, capturas, correos. Extraer de ahi
todo lo que se pueda para **no preguntar lo que ya esta escrito**.

Fijar el **alcance del sistema** en una frase: que queda dentro de la frontera y
que queda fuera. Sin frontera clara no hay diagrama de casos de uso valido.

### 2. Entrevista por tandas

Usar `AskUserQuestion` en tandas de 2-4 preguntas, nunca una lista larga de golpe.
Cada tanda ofrece opciones concretas basadas en lo ya sabido, no preguntas
abiertas genericas. Orden recomendado:

**Tanda 1 - Frontera y proposito**
- Que sistema estamos modelando y donde termina (una app, un modulo, un
  subsistema, un proceso end-to-end que cruza varios sistemas).
- Nivel de detalle esperado: mapa general para consultoria, o modelo detallado
  para desarrollo y QA.

**Tanda 2 - Actores**
- Quien usa el sistema: roles, no personas ni puestos concretos.
- Sistemas externos que interactuan (pasarelas, ERP, colas, servicios de
  terceros, tareas programadas). El tiempo tambien es un actor cuando dispara
  procesos automaticos.
- Cual es el **actor principal** de cada interaccion y cuales son secundarios.

**Tanda 3 - Objetivos**
- Que quiere conseguir cada actor con el sistema. Un caso de uso es un
  **objetivo con valor observable**, no un paso ni una pantalla.
- Que casos son variantes de otro y cuales son realmente independientes.

**Tanda 4 - Reglas y excepciones**
- Restricciones de negocio, permisos por rol, limites, validaciones.
- Que puede salir mal en cada objetivo (base para los flujos alternativos).

**Tanda 5 - Trazabilidad y contexto** (solo si el proyecto lo requiere)
- Requisitos, epicas o historias con las que hay que enlazar.
- Version, autor, sistema de gestion documental de destino.

Parar de preguntar cuando dos tandas seguidas no aporten casos de uso nuevos.

### 3. Filtrado de candidatos

Antes de dar nada por bueno, aplicar estos filtros a cada candidato a caso de uso:

| Filtro | Descarta |
| --- | --- |
| Test del jefe | "Ayer hice 20 veces X" no suena a logro -> X es un paso, no un caso de uso |
| Valor observable | Si al terminar nada ha cambiado para el actor, no es caso de uso |
| Independencia de UI | "Pulsar el boton Guardar", "Abrir el modal" -> son interaccion, no objetivo |
| CRUD desglosado | "Alta/Baja/Modificacion/Consulta de cliente" suele ser **un** caso de uso "Gestionar cliente", salvo que cada operacion tenga actores, reglas o flujos claramente distintos |
| Descomposicion funcional | Si el candidato solo existe porque otro lo llama, evaluarlo como `<<include>>` o como paso del flujo, no como caso de uso de primer nivel |

Ver `references/heuristicas-descubrimiento.md` para el detalle y ejemplos.

### 4. Entregables

Escribir dos ficheros en la carpeta de trabajo del proyecto:

**`catalogo-actores.md`**

| ID | Actor | Tipo | Descripcion | Casos de uso |
| --- | --- | --- | --- | --- |
| ACT-01 | Cliente | Humano / principal | Persona que compra en la tienda | UC-01, UC-03 |
| ACT-02 | Pasarela de pago | Sistema / secundario | Servicio externo que autoriza cobros | UC-03 |

**`catalogo-casos-uso.md`**

| ID | Caso de uso | Actor principal | Nivel | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| UC-01 | Registrar pedido | ACT-01 Cliente | Objetivo de usuario | Alta | Borrador |

Convenciones fijas para todo el pack:
- Identificadores `ACT-nn` y `UC-nn`, estables: nunca se reutiliza un ID liberado.
- Nombre del caso de uso: **verbo en infinitivo + objeto** ("Registrar pedido",
  no "Registro de pedidos" ni "Gestion de pedidos").
- Nivel segun Cockburn: `Resumen` (proceso que agrupa varios), `Objetivo de
  usuario` (el nivel util por defecto) o `Subfuncion` (paso reutilizable, tipico
  destino de un `<<include>>`).

Cerrar siempre con una lista explicita de **supuestos pendientes de validar** y
de **preguntas abiertas** al final de `catalogo-casos-uso.md`.

### 5. Siguiente paso

Ofrecer al usuario, en una linea, continuar con `diagramar-casos-uso` para
generar el diagrama, o con `especificar-casos-uso` para redactar las fichas.
