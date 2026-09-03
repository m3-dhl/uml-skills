# Heuristicas de descubrimiento de casos de uso

Material de apoyo para filtrar candidatos durante la entrevista. Consultar cuando
haya duda sobre si algo es un caso de uso, un actor o un paso.

## 1. Que es y que no es un actor

Un actor es un **rol** externo a la frontera del sistema que interactua con el.

| Es actor | No es actor |
| --- | --- |
| Cliente, Gestor de cobros, Administrador | "Maria Lopez, del departamento de ventas" (persona, no rol) |
| Pasarela de pago, ERP, servicio de correo | Un modulo interno del propio sistema |
| Reloj / Planificador (dispara procesos programados) | La base de datos del propio sistema |
| Un departamento cuando actua como bloque unico frente al sistema | Un dispositivo que solo es el canal (el movil no es actor; el usuario si) |

Reglas practicas:

- Una misma persona puede ser dos actores distintos si tiene dos roles.
- Dos roles con exactamente los mismos casos de uso son **el mismo actor** con
  dos nombres; unificar o justificar por que se separan.
- Si un rol solo aparece en un caso de uso y ese caso de uso es de otro rol,
  probablemente sea un **stakeholder**, no un actor. Los stakeholders van en la
  ficha de especificacion, no en el diagrama.
- Distinguir **actor principal** (quien inicia y recibe el valor) de **actor
  secundario** (a quien el sistema consulta para completar el objetivo).

## 2. Los tres niveles de Cockburn

| Nivel | Simbolo | Ejemplo | Uso en el modelo |
| --- | --- | --- | --- |
| Resumen | + | "Gestionar el ciclo de vida del pedido" | Contexto, diagrama de nivel 0 |
| Objetivo de usuario | ! | "Registrar pedido" | **El nivel por defecto.** Un actor, una sentada, un resultado util |
| Subfuncion | - | "Validar stock disponible" | Solo si se reutiliza desde 2+ casos de uso |

El test de la sentada: un caso de uso de objetivo de usuario es lo que alguien
completa de una vez, sin levantarse, y despues puede irse satisfecho.

Si el modelo tiene mas subfunciones que objetivos de usuario, esta sobre-
descompuesto: es diseno disfrazado de analisis.

## 3. Descartes tipicos

**Pasos disfrazados de casos de uso**

- "Introducir datos del cliente", "Confirmar", "Mostrar listado", "Guardar" ->
  son pasos del flujo basico de un caso de uso mayor.

**Pantallas disfrazadas de casos de uso**

- "Acceder al panel de control", "Abrir la pestana de informes" -> navegacion.
  El caso de uso es lo que el actor consigue una vez alli.

**CRUD explotado**

- "Alta de cliente / Baja de cliente / Modificacion de cliente / Consulta de
  cliente" -> normalmente **"Gestionar cliente"**, un unico caso de uso con
  cuatro flujos. Se separan solo si:
  - los inicia un actor distinto (el cliente se da de alta, el gestor lo da de baja), o
  - tienen reglas de negocio o autorizaciones sustancialmente distintas, o
  - QA necesita trazar pruebas independientes por normativa.

**Requisitos no funcionales**

- "El sistema debe responder en menos de 2 segundos", "Debe cumplir RGPD" ->
  no son casos de uso. Van al apartado de requisitos especiales de la ficha.

**Reglas de negocio**

- "Un pedido de mas de 1.000 EUR requiere aprobacion" -> es una regla `RN-nn`
  referenciada desde el flujo, no un caso de uso.

## 4. Preguntas que suelen destapar casos de uso olvidados

- Que pasa cuando algo falla a mitad? Quien lo arregla y como?
- Quien configura o parametriza el sistema antes de que los usuarios lo usen?
- Que hace el sistema solo, sin que nadie lo pida (procesos nocturnos, avisos,
  caducidades, reintentos)?
- Que informacion tiene que salir del sistema hacia fuera y quien la pide?
- Quien da de alta a los usuarios y gestiona sus permisos?
- Que se hace con los datos cuando un cliente ejerce su derecho de supresion?
- Que ocurre en el cierre de mes / fin de ejercicio / migracion inicial?

## 5. Cuantos casos de uso son razonables

Ordenes de magnitud utiles para detectar desviaciones:

- Un modulo funcional: 5-15 casos de uso de objetivo de usuario.
- Una aplicacion de gestion completa: 20-60.
- Mas de 80 en un solo diagrama significa que falta agrupar por paquetes o
  subsistemas: hacer un diagrama de contexto y varios de detalle.

Si salen 3, probablemente esten a nivel de resumen. Si salen 200, estan a nivel
de subfuncion.
