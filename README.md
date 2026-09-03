# uml-skills

Marketplace de skills de **M3 Informatica** para analisis funcional y modelado de
casos de uso UML en Claude (Cowork y Claude Code).

## Instalacion

Cualquiera del equipo, una sola vez:

```
/plugin marketplace add m3-dhl/uml-skills
/plugin install casos-de-uso-uml@m3-uml
```

Si el repositorio es privado, Claude usa las credenciales de git que ya tenga
configuradas la persona (GitHub CLI o clave SSH). No hay que pasar ficheros a
mano ni reinstalar nada cuando se publique una version nueva: basta con
`/plugin update`.

## Que contiene

| Plugin | Version | Que hace |
| --- | --- | --- |
| [`casos-de-uso-uml`](plugins/casos-de-uso-uml/) | 0.3.0 | De una descripcion de funcionalidad a un modelo de casos de uso completo: actores, diagrama PlantUML, fichas de especificacion, auditoria de calidad y dossier entregable |

Documentacion detallada del plugin en
[`plugins/casos-de-uso-uml/README.md`](plugins/casos-de-uso-uml/README.md).

## Uso rapido

```
/casos-de-uso-uml:uml
```

Menu que pregunta que se quiere hacer y deriva al skill adecuado. O directamente:

```
/casos-de-uso-uml:analizar-funcionalidad Estamos haciendo un portal donde los
clientes suben facturas, un gestor las valida y se envian al ERP. Hay que
documentar los casos de uso para consultoria y para QA.
```

## Estructura del repositorio

```
uml-skills/
├── .claude-plugin/
│   └── marketplace.json          <- catalogo del marketplace
└── plugins/
    └── casos-de-uso-uml/         <- el plugin
        ├── .claude-plugin/plugin.json
        ├── agents/
        ├── assets/
        ├── scripts/
        └── skills/
```

## Publicar una version nueva

1. Editar los ficheros del plugin en `plugins/casos-de-uso-uml/`.
2. Subir `version` en **los dos** sitios: `plugins/casos-de-uso-uml/.claude-plugin/plugin.json`
   y la entrada correspondiente de `.claude-plugin/marketplace.json`. Si no se
   sube la version, los usuarios no reciben la actualizacion.
3. Commit y push a `master`.
4. El equipo ejecuta `/plugin update casos-de-uso-uml@m3-uml`.

Para probar cambios sin publicarlos, `claude --plugin-dir ./plugins/casos-de-uso-uml`.

## Requisitos

Java 8 o superior en el entorno donde se renderizan los diagramas. El script
`scripts/render-uml.sh` se encarga del resto: descarga y cachea `plantuml.jar` la
primera vez, y si no hay Graphviz usa el motor interno Smetana. El renderizado es
siempre local: **los modelos no salen a ningun servicio externo**.
