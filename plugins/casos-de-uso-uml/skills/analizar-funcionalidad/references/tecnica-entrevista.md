# Tecnica de entrevista para cerrar huecos

Detalle operativo de la Fase 3. Consultar cuando la entrevista se atasque o
cuando el interlocutor responda con evasivas.

## 1. La prediccion adjunta

Toda pregunta se formula como **hipotesis + peticion de correccion**. Nunca como
pregunta abierta.

| En vez de | Preguntar |
| --- | --- |
| "¿Que actores hay?" | "Del texto saco Cliente, Gestor y la pasarela de pago como sistema externo. ¿Falta alguien, por ejemplo quien configura el catalogo?" |
| "¿Cual es el flujo de aprobacion?" | "Asumo que el pedido va directo a preparacion sin aprobacion. ¿Hay algun importe o cliente que obligue a validacion previa?" |
| "¿Que pasa si falla el pago?" | "Asumo que se libera el stock y se avisa al cliente, sin reintento automatico. ¿Se reintenta?" |
| "¿Que prioridad tiene esto?" | "Lo pongo como prioridad alta porque bloquea el resto del flujo. ¿Correcto?" |

Tres razones por las que funciona:

- Corregir cuesta menos esfuerzo que redactar. El interlocutor responde antes y
  con mas detalle.
- Obliga a explicitar el supuesto. Un supuesto escrito se puede rebatir; uno
  implicito se convierte en requisito silencioso.
- Destapa desacuerdos que una pregunta abierta no destapa: nadie corrige lo que
  no ve.

Si no hay ninguna prediccion razonable que ofrecer, eso ya es informacion: el
hueco es de fondo, no de detalle, y probablemente no lo cierre esta persona.

## 2. Que preguntar y que no

**Preguntar:**

- Elementos `[SUPUESTO]` que cambian el alcance o el numero de casos de uso.
- Ambiguedades de frontera: esto lo hace nuestro sistema o el de al lado.
- Quien es el actor principal cuando hay dos candidatos.
- Si dos casos de uso parecidos son uno con dos flujos o dos independientes.
- Excepciones: que pasa cuando falla, quien lo arregla.
- Reglas de negocio con umbrales (importes, plazos, limites, permisos).

**No preguntar:**

- Nada que ya este en el prompt base o en los adjuntos. Preguntarlo hace pensar
  al interlocutor que no se ha leido su material, y con razon.
- Detalles de interfaz. No son casos de uso.
- Requisitos no funcionales, salvo que afecten a un caso concreto.
- Preferencias de formato en mitad del analisis. Van al final, de una vez.

## 3. Senales de respuesta no valida

| Senal | Que significa | Que hacer |
| --- | --- | --- |
| "Lo que sea estandar" | No lo ha pensado, o no le corresponde decidirlo | Ofrecer dos opciones concretas con su consecuencia |
| "Lo que tu veas" | Delegacion | No aceptarla como respuesta terminal: proponer una y pedir confirmacion expresa |
| "Supongo que si" | Duda | Repreguntar con un caso concreto: "¿si llega un pedido de 5.000 EUR un domingo, que pasa?" |
| "Eso lo lleva otro equipo" | Frontera mal trazada, o falta un interlocutor | Marcar como fuera de alcance de forma explicita y registrarlo |
| "Bueno, depende" | Hay una regla de negocio sin formular | Perseguir el "de que depende": ahi esta la `RN-nn` |
| Respuesta larga sin decidir nada | Contexto, no decision | Agradecer, resumir en una frase y pedir el si o el no |

## 4. Preguntas de alto rendimiento

Cuando la entrevista se atasca, estas suelen destapar mas modelo que diez
preguntas de detalle:

- "¿Que es lo que mas os duele hoy de este proceso?"
- "¿Que pasa cuando algo sale mal a mitad? ¿Quien lo arregla y como?"
- "¿Que hace el sistema solo, sin que nadie se lo pida?"
- "¿Quien da de alta a los usuarios y gestiona sus permisos?"
- "¿Que informacion tiene que salir de aqui hacia fuera, y quien la pide?"
- "Si esto sale mal, ¿quien se entera y como?"
- "¿Que haceis hoy en Excel o a mano que deberia estar aqui dentro?"

## 5. Calibrar la confianza

El numero de confianza tiene que ser defendible. Referencias:

| Confianza | Situacion |
| --- | --- |
| < 40% | Solo se conoce el titulo del modulo. No merece la pena generar borrador todavia |
| 40-70% | Se entiende el proposito, faltan actores o el alcance esta abierto |
| 70-90% | El modelo es correcto en lo esencial; quedan supuestos de detalle |
| > 90% | Se predicen las respuestas a las siguientes preguntas. Parar |

Si se declara un 85% y el interlocutor corrige tres cosas seguidas, el 85% era
falso. Recalibrar a la baja y decirlo: una confianza inflada hace que se deje de
preguntar demasiado pronto.

## 6. Cuando parar aunque queden huecos

Tres rondas sin que la confianza suba significa que el hueco no se cierra
preguntando a esta persona. Ocurre cuando el negocio todavia no lo ha decidido, o
cuando quien conoce el proceso no esta en la conversacion.

En ese caso: decirlo de forma explicita, cerrar el modelo con lo que hay, marcar
lo pendiente como `Q-n` con responsable propuesto, y seguir. Un modelo con cinco
cuestiones abiertas bien identificadas es util. Un modelo con cinco huecos
rellenados por analogia es peligroso, porque nadie sabra cuales eran los huecos.
