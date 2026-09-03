---
name: publicar-dossier-uc
description: >
  Este skill debe usarse para empaquetar un modelo de casos de uso en un
  entregable presentable: "monta el documento de casos de uso", "prepara el
  dossier para el cliente", "pasa esto a Word", "genera el entregable de analisis
  funcional", "quiero un PDF con los diagramas y las fichas". Reune diagramas,
  fichas, reglas de negocio y matriz de trazabilidad en un documento unico con
  portada, indice y control de versiones.
metadata:
  version: "0.1.0"
---

# Dossier de analisis de casos de uso

Convertir los artefactos sueltos en un entregable que se pueda enviar a un
cliente, subir a la wiki o adjuntar a una oferta.

## Antes de empaquetar

Ejecutar `revisar-modelo-uc` y resolver al menos los hallazgos criticos. Un
dossier con el `<<include>>` invertido documenta el error con mejor tipografia.

Confirmar con el usuario, en una sola tanda de `AskUserQuestion`:

- **Formato**: Word (.docx) para entregable formal y revisable con control de
  cambios; PDF para envio cerrado; Markdown para wiki o repositorio; pagina HTML
  publicada cuando el equipo va a consultarla de forma recurrente.
- **Audiencia**: negocio/cliente (poco UML, mucha narrativa), desarrollo (fichas
  completas), o QA (enfasis en flujos alternativos y matriz de trazabilidad).
- **Alcance**: todos los casos de uso o solo un modulo.

## Estructura del dossier

1. **Portada** - proyecto, modulo, version, fecha, autor, clasificacion de
   confidencialidad.
2. **Control de versiones** - tabla version / fecha / autor / cambios.
3. **Indice**.
4. **Introduccion** - proposito del documento, alcance del sistema, que queda
   explicitamente fuera, documentos de referencia.
5. **Glosario** - terminologia de negocio. Va al principio, no al final: es lo
   que evita que cliente y equipo usen la misma palabra para cosas distintas.
6. **Catalogo de actores** - tabla con ID, rol, tipo, descripcion, casos de uso.
7. **Diagrama de contexto** - vista de nivel 0 por paquetes.
8. **Diagramas por modulo** - imagen mas una tabla de los casos que contiene.
9. **Fichas de casos de uso** - una por caso, ordenadas por ID, cada una
   empezando en pagina nueva.
10. **Reglas de negocio** - tabla `RN-nn` con enunciado y casos de uso donde
    aplica.
11. **Matriz de trazabilidad** - requisito ↔ caso de uso ↔ flujo ↔ escenario de
    prueba.
12. **Supuestos y cuestiones abiertas** - consolidado de todos los `[PENDIENTE]`
    y `Q-n` de las fichas, con responsable. **Este apartado nunca se omite**: es
    lo que protege al equipo cuando el alcance se discute mas adelante.

Para audiencia de negocio, mover las fichas completas a anexo y dejar en el
cuerpo el formato breve.

## Generacion

1. Regenerar todas las imagenes desde los `.puml` antes de montar nada:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/render-uml.sh" diagramas/ -f both -o entregables/img
```

Usar PNG para Word y PDF, SVG para HTML y wiki.

2. Segun el formato elegido:
   - **.docx**: usar el skill `docx`. Encabezados de nivel 1-3, imagenes
     centradas con pie "Figura n.", tablas con cabecera repetida, numeracion de
     paginas, indice automatico.
   - **.pdf**: usar el skill `pdf`.
   - **Markdown**: un fichero unico con enlaces relativos a las imagenes, o un
     `README.md` indice mas un fichero por caso de uso.
   - **HTML publicado**: pagina autocontenida con los SVG en linea, navegacion
     lateral por casos de uso y buscador. Adecuado cuando el equipo la va a
     consultar a diario.

3. Nombrar el fichero `<Proyecto>-Casos-de-Uso-v<X.Y>-<AAAA-MM-DD>`.

## Comprobaciones finales

Antes de entregar, verificar de verdad, abriendo el documento:

- Todas las imagenes se ven y son legibles al tamano en que quedan.
- El indice esta generado y los numeros de pagina son correctos.
- No queda ningun `[PENDIENTE]` suelto fuera del apartado de cuestiones abiertas.
- Los IDs son coherentes entre diagramas, fichas y matriz.
- La version y la fecha son las reales, no las de la plantilla.
- La clasificacion de confidencialidad es la que corresponde al cliente.

## Entrega

Entregar el fichero al usuario y, si tiene una carpeta conectada, guardarlo en
ella. Indicar en una linea que las imagenes hay que regenerarlas desde los
`.puml` en cada cambio, y que el `.puml` es el artefacto que se versiona en Git,
no el documento montado.
