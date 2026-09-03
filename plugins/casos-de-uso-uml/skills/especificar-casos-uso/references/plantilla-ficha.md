# Plantilla canonica de ficha de caso de uso

Copiar tal cual y rellenar. Los campos marcados `(opcional)` se omiten en el
formato intermedio. Basada en la plantilla "fully dressed" de Alistair Cockburn,
adaptada a castellano y a proyectos de gestion.

---

## UC-nn <Verbo en infinitivo + objeto>

| Campo | Valor |
| --- | --- |
| **Identificador** | UC-nn |
| **Nombre** | |
| **Version / Fecha** | 0.1 / AAAA-MM-DD |
| **Autor** | |
| **Estado** | Borrador / En revision / Aprobado |
| **Alcance** | Sistema o modulo al que pertenece |
| **Nivel** | Resumen / Objetivo de usuario / Subfuncion |
| **Actor principal** | ACT-nn |
| **Actores secundarios** | ACT-nn, ACT-nn |
| **Stakeholders e intereses** *(opcional)* | Quien mas se ve afectado y que espera |
| **Disparador** | Evento que inicia el caso de uso |
| **Prioridad** | Alta / Media / Baja |
| **Frecuencia de uso** *(opcional)* | Estimacion de volumen |
| **Requisitos asociados** | RF-nnn, RNF-nnn |

### Precondiciones

Estados que el sistema **garantiza** antes de empezar. No son validaciones.

- P1.
- P2.

### Postcondiciones de exito

Estado observable del sistema si el caso de uso termina bien.

- E1.
- E2.

### Postcondiciones minimas

Lo que se garantiza **aunque el caso de uso falle**. Aqui es donde se documenta
que no quedan estados inconsistentes.

- M1.

### Flujo basico (camino de exito)

Sin condicionales. Voz activa. Un actor por paso. Entre 3 y 9 pasos.

1. El <actor> ...
2. El sistema ...
3. El sistema ... [RN-nn]
4. El sistema ... [incluye UC-nn]
5. El sistema ...

### Flujos alternativos

Variantes que **tambien terminan en exito**. Numerar por el paso del que salen.

**na. <Condicion que dispara la variante>**

1. na1. ...
2. na2. Continua en el paso <n+1> del flujo basico.

### Excepciones

Situaciones de error. Numerar con `e` por el paso del que salen. Indicar siempre
como termina el caso de uso: vuelve al flujo, reintenta, o termina sin exito.

**ne. <Condicion de error>**

1. ne1. ...
2. ne2. El caso de uso termina sin ...

### Reglas de negocio aplicables

Solo referencias. El enunciado vive en `reglas-negocio.md`.

- RN-nn
- RN-nn

### Requisitos especiales *(opcional)*

Rendimiento, seguridad, accesibilidad, normativa, disponibilidad, idioma,
volumetria. Todo lo no funcional que afecte especificamente a este caso de uso.

### Datos relevantes *(opcional)*

Entidades y campos que se crean, leen o modifican. Util para el modelo de datos
y para preparar juegos de pruebas.

### Puntos de extension *(opcional)*

Solo si hay relaciones `<<extend>>` en el diagrama. Nombrar el punto e indicar
en que paso del flujo basico se inserta.

- PE-1 <nombre>: tras el paso n.

### Cuestiones abiertas

Lo que falta por decidir, con responsable si se conoce. **Nunca dejar un hueco
sin registrar aqui.**

- Q1. <pregunta concreta> - Pendiente de <quien>.

### Historial de cambios

| Version | Fecha | Autor | Cambio |
| --- | --- | --- | --- |
| 0.1 | AAAA-MM-DD | | Version inicial |

---

## Formato breve

Para casos de baja prioridad o exploracion inicial:

> **UC-nn <Nombre>** - Actor principal: ACT-nn. El <actor> <hace X> para
> <conseguir Y>. El sistema <valida Z> y <produce W>. Si <condicion de error>,
> <consecuencia>. Reglas: RN-nn.

Un parrafo, sin tabla. Suficiente para validar el alcance con negocio antes de
invertir en la ficha completa.
