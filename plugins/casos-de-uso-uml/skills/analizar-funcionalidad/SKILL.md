---
name: analizar-funcionalidad
description: >
  Punto de entrada unico del pack de casos de uso. Este skill debe usarse cuando
  alguien suelta una descripcion de funcionalidad y quiere el modelo completo sin
  ir invocando skills uno a uno: "analiza esta funcionalidad", "sacame los casos
  de uso de esto", "toma este texto y hazme el analisis funcional", "a partir de
  esta descripcion monta el modelo de casos de uso". Genera un borrador del
  modelo, mide su cobertura, entrevista solo sobre los huecos detectados y
  encadena diagrama, fichas y revision.
metadata:
  version: "0.2.0"
---

# Analisis de funcionalidad de extremo a extremo

Convertir un prompt base en un modelo de casos de uso auditado, preguntando lo
minimo imprescindible.

El texto que acompana a la invocacion es `$ARGUMENTS`: la descripcion de
funcionalidad de la que se parte. Si viene vacio, pedirla en una sola frase y
esperar. Si el usuario adjunta ficheros, documentos funcionales, historias de
usuario o correos, leerlos: forman parte del prompt base.

## Principio rector

**Proponer antes de preguntar.** Nunca abrir con una bateria de preguntas sobre
una pagina en blanco. Generar primero un borrador completo y usar las preguntas
solo para cerrar los huecos que ese borrador deja al descubierto.

Reaccionar a una suposicion equivocada cuesta al interlocutor mucho menos
esfuerzo que redactar una respuesta desde cero, y ademas revela desacuerdos que
una pregunta abierta nunca destapa.

## Fase 1 - Borrador v0

A partir de `$ARGUMENTS` y del material adjunto, construir un modelo preliminar
completo aplicando las heuristicas de `descubrir-casos-uso`
(`references/heuristicas-descubrimiento.md` de ese skill):

- Frontera del sistema, en una frase.
- Actores, con su tipo (humano / sistema) y su papel (principal / secundario).
- Casos de uso con ID, nombre en infinitivo, actor principal y nivel.
- Relaciones `<<include>>` / `<<extend>>` evidentes.
- Reglas de negocio `RN-nn` que se deduzcan del texto.

**Marcar la procedencia de cada elemento**, sin excepcion:

| Marca | Significado |
| --- | --- |
| *(sin marca)* | Esta literalmente en el prompt base o en los adjuntos |
| `[INFERIDO]` | Deducido con alta confianza del contexto |
| `[SUPUESTO]` | Puesto por analogia con sistemas parecidos; puede ser falso |

Esta marca es lo que convierte el borrador en algo revisable en lugar de en una
alucinacion bien presentada.

## Fase 2 - Cobertura y confianza

Presentar el borrador con una cabecera de cobertura:

```
Borrador v0 - Modulo de pedidos
Frontera:  Tienda online, sin incluir logistica externa   [INFERIDO]
Actores:   5  (3 del texto, 1 inferido, 1 supuesto)
Casos uso: 12 (7 del texto, 3 inferidos, 2 supuestos)
Confianza global: 55%
Motivo: no se quien autoriza las devoluciones ni si hay pagos aplazados.
```

La confianza es un numero defendible, no un adorno. Si no se puede justificar,
bajarla. Por debajo del 70%, indicar siempre el motivo concreto.

Preguntar de una sola vez si el borrador va bien encaminado antes de invertir
turnos en detalles. Si el encuadre es erroneo, se descarta y se rehace: es mucho
mas barato que descubrirlo tras veinte preguntas.

## Fase 3 - Entrevista sobre los huecos

Preguntar **solo** por lo marcado `[SUPUESTO]`, por los `[INFERIDO]` que cambien
el alcance, y por los huecos estructurales detectados. Nunca preguntar por lo que
ya esta en el texto.

**Cada pregunta lleva adjunta la prediccion.** Nunca una pregunta abierta:

- Mal: "¿Que actores intervienen en las devoluciones?"
- Bien: "Asumo que la devolucion la autoriza el Gestor de pedidos y que el
  Cliente solo la solicita. ¿Es asi, o hay un rol de Atencion al Cliente por
  medio?"

**Cadencia hibrida:**

- **En tanda de 2-3** lo enumerable e independiente entre si: lista de actores,
  alcance, prioridades, volumetrias, formato de salida. Usar `AskUserQuestion`
  con opciones concretas extraidas del borrador.
- **De una en una** lo que condiciona la siguiente pregunta: quien es el actor
  principal de un caso ambiguo, si dos casos son uno o dos, donde cae la frontera
  cuando la respuesta redefine el modulo entero. Formular la siguiente pregunta
  sabiendo ya la respuesta anterior.

Regla para decidir: si la respuesta cambia **que se pregunta despues**, va sola.

**Senales de "lo que creo que deberia querer".** Estar atento a "supongo que lo
normal es...", "como se haga habitualmente", "lo que sea estandar", "lo que tu
veas". No son respuestas: son delegacion. Repreguntar con dos opciones concretas
y sus consecuencias. Un "me parece bien" no cierra un hueco.

## Fase 4 - Criterio de parada

Parar cuando se pueda responder que si a: **"¿puedo predecir la respuesta a las
tres siguientes preguntas que haria?"**. Es un test verificable, no una
sensacion.

Otras condiciones de parada, cualquiera que se cumpla antes:

- La confianza global supera el 90% y no queda ningun `[SUPUESTO]` con impacto
  en el alcance.
- Dos rondas seguidas sin que aparezcan casos de uso, actores ni reglas nuevos.
- **Tres rondas sin que la confianza suba.** Aqui no hay que seguir preguntando:
  significa que falta algo de fondo (no esta la persona que conoce el proceso, o
  el propio negocio no lo tiene decidido). Decirlo abiertamente, cerrar el modelo
  con lo que haya y dejar los huecos registrados como cuestiones abiertas.

Antes de continuar, **devolver el encuadre en 5-8 lineas**: sistema, actores
principales, objetivo del modelo, criterio de exito, restriccion que manda y
**que queda fuera de alcance**. El apartado de fuera de alcance no se omite
nunca: la mitad de los desacuerdos posteriores son sobre lo que nadie dijo en voz
alta que no se iba a hacer.

Aceptar solo un si explicito. "Vale", "tu mismo" o "lo que veas" no es
conformidad: es delegacion, y hay que repreguntar con dos opciones.

## Fase 5 - Encadenado

Con el encuadre confirmado, ejecutar sin volver a preguntar:

1. Escribir `catalogo-actores.md` y `catalogo-casos-uso.md`, ya sin marcas de
   `[SUPUESTO]` resueltas y con las no resueltas listadas al final.
2. Aplicar `diagramar-casos-uso`: generar el `.puml` y renderizar SVG y PNG.
3. Aplicar `especificar-casos-uso`: fichas segun el nivel de detalle acordado.
4. Aplicar `revisar-modelo-uc`: auditoria del propio modelo generado.
5. Corregir los hallazgos criticos y regenerar el diagrama.

Parar ahi. **No montar el dossier**: se ofrece en una linea, y se ejecuta
`publicar-dossier-uc` solo si el usuario lo pide, porque el formato del
entregable depende de a quien va dirigido.

## Entrega

Presentar en este orden: el diagrama, el resumen del modelo (n actores, n casos
de uso, n fichas), el veredicto de la revision, y la lista de cuestiones abiertas
con responsable. La lista de cuestiones abiertas se entrega siempre, aunque este
vacia, porque es lo que protege al equipo cuando el alcance se discuta despues.

El detalle de la tecnica de interrogacion esta en
`references/tecnica-entrevista.md`.
