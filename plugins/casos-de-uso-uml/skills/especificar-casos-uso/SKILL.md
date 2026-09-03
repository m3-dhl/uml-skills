---
name: especificar-casos-uso
description: >
  Este skill debe usarse cuando hace falta la descripcion textual de los casos de
  uso, no solo el dibujo: "escribe la especificacion del caso de uso", "necesito
  las fichas de casos de uso", "detalla los flujos", "documenta el flujo basico y
  las excepciones", "el diagrama no es suficiente para QA". Redacta fichas con
  formato Cockburn (precondiciones, flujo basico, flujos alternativos,
  excepciones, postcondiciones, reglas de negocio) listas para desarrollo y para
  diseno de pruebas.
metadata:
  version: "0.1.0"
---

# Especificacion textual de casos de uso

El diagrama muestra el **mapa**; la ficha contiene el **contenido**. Un caso de
uso es fundamentalmente un texto: sin fichas, ni desarrollo puede implementar ni
QA puede disenar pruebas. Este skill produce esas fichas.

## Nivel de detalle

Elegir antes de empezar y decirlo explicitamente al usuario:

| Formato | Cuando | Contenido |
| --- | --- | --- |
| Breve | Exploracion inicial, muchos casos, poco tiempo | ID, nombre, actor, 2-4 frases de narrativa |
| Intermedio | Documentacion de consultoria, validacion con negocio | Ficha completa sin numeracion exhaustiva de extensiones |
| Completo | Casos criticos, base para pruebas, contrato o certificacion | Plantilla entera con extensiones numeradas |

No especificar los 40 casos en formato completo por inercia. Recomendacion:
completo para los casos criticos y los de alto riesgo, intermedio para el resto,
breve para los de baja prioridad. Confirmar el reparto con el usuario.

## Plantilla

La plantilla canonica esta en `references/plantilla-ficha.md`. Estructura:

```
UC-01 Registrar pedido

Identificador       UC-01
Nombre              Registrar pedido
Version / Fecha     0.1 / 2026-09-03
Autor               ...
Actor principal     ACT-01 Cliente
Actores secundarios ACT-03 Pasarela de pago
Stakeholders        Direccion comercial (quiere ...), Almacen (necesita ...)
Alcance             Tienda online
Nivel               Objetivo de usuario
Disparador          El cliente confirma el carrito
Prioridad           Alta
Frecuencia          ~500/dia

Precondiciones
  P1. El cliente esta autenticado.
  P2. El carrito contiene al menos una linea.

Postcondiciones de exito
  E1. Existe un pedido en estado CONFIRMADO.
  E2. El stock reservado se ha decrementado.

Postcondiciones minimas (aunque falle)
  M1. No queda stock reservado sin pedido asociado.

Flujo basico
  1. El cliente solicita confirmar el pedido.
  2. El sistema valida la disponibilidad de stock de cada linea.  [incluye UC-02]
  3. El sistema calcula importes, impuestos y gastos de envio.    [RN-03, RN-04]
  4. El sistema solicita la autorizacion del cobro a la pasarela.
  5. La pasarela autoriza el cobro.
  6. El sistema registra el pedido en estado CONFIRMADO.
  7. El sistema notifica al cliente el numero de pedido.

Flujos alternativos
  3a. El importe supera 1.000 EUR.
      3a1. El sistema marca el pedido como PENDIENTE DE APROBACION.  [RN-07]
      3a2. Continua en el paso 6.

Excepciones
  2e. Una linea no tiene stock suficiente.
      2e1. El sistema informa de las lineas afectadas.
      2e2. El caso de uso termina sin crear pedido.
  5e. La pasarela rechaza el cobro.
      5e1. El sistema libera el stock reservado.
      5e2. El sistema informa del motivo del rechazo.
      5e3. Vuelve al paso 4 (maximo 3 intentos).  [RN-11]

Reglas de negocio      RN-03, RN-04, RN-07, RN-11
Requisitos especiales  Tiempo de respuesta < 3 s en el paso 4
Datos relevantes       Numero de pedido, importe total, referencia de cobro
Cuestiones abiertas    Q1. Se permite pago parcial? Pendiente de negocio.
```

## Reglas de redaccion

**Los pasos describen intencion, no interfaz.**
- Correcto: "El cliente solicita confirmar el pedido."
- Incorrecto: "El cliente pulsa el boton verde 'Confirmar' del modal."

La UI cambia cada trimestre; la intencion, no. Una ficha llena de nombres de
botones queda obsoleta en la primera iteracion de diseno.

**Un actor por paso, voz activa, presente.** Cada paso empieza por quien actua:
"El sistema...", "El cliente...", "La pasarela...". Nada de pasiva refleja ("se
valida el stock") porque oculta quien es responsable.

**Sin condicionales dentro del flujo basico.** El flujo basico es el camino de
exito, de principio a fin, sin un solo "si". Toda bifurcacion va a flujos
alternativos o a excepciones.

**Numeracion trazable.** Un flujo alternativo del paso 3 se numera `3a`, y sus
pasos `3a1`, `3a2`. Una excepcion del paso 5 se numera `5e`. Asi QA referencia
"prueba de 5e2" sin ambiguedad.

**Entre 3 y 9 pasos en el flujo basico.** Menos de 3 sugiere que el caso es en
realidad una subfuncion; mas de 9, que agrupa varios objetivos y hay que
partirlo o extraer un `<<include>>`.

**Las reglas de negocio se referencian, no se copian.** Mantener un fichero
`reglas-negocio.md` con `RN-nn` y citarlas desde los pasos. Una regla escrita en
cinco fichas se actualiza mal en cuatro de ellas.

**Las precondiciones son estados garantizados, no comprobaciones.** Si el sistema
tiene que verificarlo, es un paso del flujo, no una precondicion.

## Flujo de trabajo

1. Leer `catalogo-casos-uso.md` y el `.puml` si existen, para reutilizar IDs y
   nombres exactos. Los IDs de la ficha, del diagrama y del catalogo deben ser
   los mismos: es la unica trazabilidad que sobrevive al proyecto.
2. Elegir el nivel de detalle por caso y confirmarlo.
3. Redactar. Ante cualquier hueco, escribir `[PENDIENTE: pregunta concreta]` en
   el sitio exacto y acumularlo en "Cuestiones abiertas". **No rellenar huecos
   con supuestos plausibles**: un flujo inventado que parece razonable es mas
   danino que un hueco visible, porque nadie lo cuestiona.
4. Guardar una ficha por fichero en `casos-de-uso/UC-01-registrar-pedido.md`, o
   todas en un unico documento si el usuario prefiere un entregable unico.
5. Actualizar el diagrama si al especificar aparecen casos de uso, actores o
   relaciones nuevos. Es lo normal: la especificacion siempre descubre cosas que
   el diagrama no vio.

## Salida derivada para QA

Al terminar, ofrecer generar `matriz-trazabilidad.md`, que es lo que hace util el
modelo para calidad:

| UC | Requisito | Flujo | Escenario de prueba | Tipo |
| --- | --- | --- | --- | --- |
| UC-01 | RF-012 | Basico | Pedido con stock y pago autorizado | Positivo |
| UC-01 | RF-012 | 2e | Pedido con una linea sin stock | Negativo |
| UC-01 | RF-014 | 3a | Pedido de 1.200 EUR queda pendiente de aprobacion | Limite |
| UC-01 | RF-012 | 5e | Pasarela rechaza y se reintenta 3 veces | Negativo |

Regla practica: **cada flujo alternativo y cada excepcion es como minimo un caso
de prueba**. Esa correspondencia uno a uno es el argumento con el que se justifica
ante QA el esfuerzo de escribir las fichas.
