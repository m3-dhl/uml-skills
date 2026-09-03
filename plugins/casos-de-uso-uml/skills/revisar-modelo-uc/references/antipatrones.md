# Catalogo de antipatrones en modelos de casos de uso

Cada entrada: sintoma, por que es un problema, y correccion.

---

## A1. Include invertido

**Sintoma**: `UC_INCLUIDO ..> UC_BASE : <<include>>`

**Problema**: la semantica UML es que el caso **base** incluye al otro, luego la
dependencia sale del base. Invertida, desarrollo entiende la llamada al reves.

**Correccion**: `UC_BASE ..> UC_INCLUIDO : <<include>>`. Regla mnemotecnica: la
flecha punteada apunta a lo que se necesita, igual que cualquier dependencia.

---

## A2. Extend invertido

**Sintoma**: `UC_BASE ..> UC_EXTENSION : <<extend>>`

**Problema**: `<<extend>>` va al reves que `<<include>>`. El caso opcional apunta
al caso al que se anade, porque el base **no sabe** que lo estan extendiendo.

**Correccion**: `UC_EXTENSION ..> UC_BASE : <<extend>>`.

---

## A3. Include con un solo llamante

**Sintoma**: un caso de uso incluido desde exactamente un caso base.

**Problema**: no es reutilizacion, es descomposicion funcional. Duplica
artefactos (dos fichas, dos entradas de catalogo) sin aportar informacion.

**Correccion**: convertirlo en pasos del flujo basico del caso base, salvo que
se prevea su reutilizacion inminente o que QA necesite probarlo por separado.

---

## A4. Extend usado como flujo alternativo

**Sintoma**: cada variante del flujo aparece como un `<<extend>>` en el diagrama.

**Problema**: el diagrama se vuelve ilegible y negocio no entiende la notacion.
Las variantes son informacion textual, no estructural.

**Correccion**: modelarlas como flujos alternativos en la ficha. Reservar
`<<extend>>` para comportamiento realmente opcional que se activa en un punto de
extension identificado y que interesa ver en el mapa.

---

## A5. Descomposicion funcional

**Sintoma**: arbol de casos de uso con tres o mas niveles de `<<include>>`, o
mas relaciones entre casos de uso que asociaciones con actores.

**Problema**: es un diagrama de diseno con notacion de casos de uso. Los casos de
uso describen **objetivos de actores**, no la arquitectura interna.

**Correccion**: aplanar. Quedarse con el nivel de objetivo de usuario y llevar
todo lo demas a los flujos. Si hace falta describir la mecanica interna, usar un
diagrama de actividad o de secuencia, no de casos de uso.

---

## A6. Caso de uso que es un paso

**Sintoma**: "Introducir datos del cliente", "Validar formulario", "Confirmar",
"Mostrar resultado", "Guardar cambios".

**Problema**: no tienen valor observable por si solos. Inflan el modelo y las
estimaciones.

**Correccion**: absorberlos en el caso de uso cuyo objetivo sirven.

**Test**: si el actor, tras completarlo, todavia no puede irse satisfecho, no es
un caso de uso.

---

## A7. Caso de uso que es una pantalla

**Sintoma**: "Acceder al panel de control", "Abrir la pestana de informes",
"Navegar al listado".

**Problema**: modela la interfaz, no el objetivo. La UI cambiara y el modelo
quedara obsoleto.

**Correccion**: preguntar para que entra el actor ahi. Ese es el caso de uso.

---

## A8. CRUD explotado

**Sintoma**: "Crear cliente", "Consultar cliente", "Modificar cliente",
"Eliminar cliente" como cuatro casos de uso.

**Problema**: cuadruplica la documentacion sin aportar. Las cuatro operaciones
suelen compartir actor, reglas y pantalla.

**Correccion**: un caso de uso "Gestionar cliente" con cuatro flujos. Separar
solo si cada operacion tiene actor distinto, reglas de autorizacion distintas, o
exigencia normativa de trazabilidad independiente.

---

## A9. Actor que es una persona o un departamento

**Sintoma**: "Maria (contabilidad)", "Departamento de compras", "Usuario avanzado
Juan".

**Problema**: el modelo deja de ser valido cuando cambia la plantilla o la
organizacion.

**Correccion**: nombrar el rol frente al sistema: "Contable", "Comprador". Un
departamento solo es actor si interactua como bloque indistinto.

---

## A10. Actor que es interno al sistema

**Sintoma**: "Base de datos", "Modulo de facturacion", "Servicio de validacion"
como actores, estando dentro de la frontera.

**Problema**: los actores son externos por definicion. Un componente interno
como actor indica que la frontera esta mal trazada.

**Correccion**: revisar la frontera. Si es interno, no es actor. Si es un sistema
de terceros, si lo es y se marca `<<sistema>>`.

---

## A11. Falta la frontera del sistema

**Sintoma**: diagrama con actores y casos de uso sueltos, sin `rectangle`.

**Problema**: no se sabe que se esta construyendo. Es la ambiguedad que hace que
el alcance se discuta en fase de pruebas en lugar de en analisis.

**Correccion**: anadir el `rectangle` con el nombre del sistema y colocar dentro
solo lo que se va a construir.

---

## A12. Caso de uso huerfano

**Sintoma**: caso de uso sin ningun actor asociado y sin ser incluido por otro.

**Problema**: nadie lo inicia, luego nunca se ejecuta. O falta un actor, o sobra
el caso de uso.

**Correccion**: identificar quien lo dispara. Si es un proceso automatico, el
actor es el planificador o el reloj, y hay que declararlo.

---

## A13. Requisito no funcional como caso de uso

**Sintoma**: "Garantizar la seguridad", "Cumplir el RGPD", "Ser rapido",
"Escalar a 1.000 usuarios".

**Problema**: no son interacciones con objetivo, no se pueden ejecutar ni probar
como escenario.

**Correccion**: llevarlos al apartado de requisitos especiales de las fichas
afectadas o al documento de requisitos no funcionales.

---

## A14. Flujo basico con condicionales

**Sintoma**: "3. Si el cliente es VIP, el sistema aplica descuento; si no,
continua."

**Problema**: el flujo basico deja de ser un camino unico y se vuelve
inverificable. QA no sabe cual es el escenario nominal.

**Correccion**: el flujo basico recoge el camino de exito mas comun. La
alternativa va a `3a`.

---

## A15. Pasos que describen la interfaz

**Sintoma**: "El usuario pulsa el boton azul 'Enviar' en la esquina superior".

**Problema**: acopla el analisis al diseno. Cada rediseno invalida la ficha.

**Correccion**: "El usuario solicita enviar la solicitud."

---

## A16. Excepcion sin desenlace

**Sintoma**: "5e. La pasarela rechaza el pago." Y ahi acaba.

**Problema**: no dice que hace el sistema ni como termina el caso de uso.
Desarrollo improvisara y QA no sabra que verificar.

**Correccion**: toda excepcion termina indicando el desenlace: vuelve al paso n,
reintenta con limite, o termina sin exito dejando el sistema en el estado M1.

---

## A17. Precondicion que es una validacion

**Sintoma**: "Precondicion: el importe es correcto."

**Problema**: si el sistema tiene que comprobarlo, no esta garantizado de
antemano: es un paso, y su fallo es una excepcion.

**Correccion**: mover al flujo ("2. El sistema valida el importe. [RN-05]") y
anadir la excepcion "2e. El importe no es valido."

---

## A18. Reglas de negocio copiadas en cada ficha

**Sintoma**: el mismo enunciado de regla repetido en cinco fichas.

**Problema**: cuando la regla cambia, se actualiza en una y quedan cuatro
versiones contradictorias circulando.

**Correccion**: `reglas-negocio.md` con IDs `RN-nn` y referencias desde los pasos.

---

## A19. Diagrama y fichas desincronizados

**Sintoma**: el diagrama tiene UC-01 a UC-24; hay fichas de 18, y tres fichas
tienen actores que no aparecen en el diagrama.

**Problema**: nadie sabe cual de los dos artefactos es la verdad. En la practica
se deja de usar el modelo entero.

**Correccion**: reconciliar y, en adelante, regenerar el diagrama desde el `.puml`
en cada cambio. Comprobar la sincronia en cada revision.

---

## A20. Modelo enorme en un solo diagrama

**Sintoma**: 60 casos de uso en una imagen que hay que imprimir en A0.

**Problema**: no se lee, luego no se revisa, luego contiene errores que nadie ve.

**Correccion**: diagrama de contexto por paquetes mas un diagrama por paquete.
Limite practico: 15 casos de uso por diagrama.
