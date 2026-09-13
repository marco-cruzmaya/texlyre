# Base de datos local de PaperTeX

## Este directorio no es la autoridad del esquema

A diferencia de otros proyectos con la misma estructura, aqui **Django posee las
migraciones**, una por app, bajo `backend/apps/*/migrations/`. Este directorio
no contiene SQL de inicializacion ni migraciones numeradas a mano.

`db/` guarda estado de ejecucion y herramientas locales:

```text
db/
├── backups/    respaldos generados por scripts/db/backup.sh (ignorado por Git)
└── fixtures/   datos de desarrollo para cargar con scripts/db/seed.sh
```

El archivo de base (`papertex.sqlite3` por omision, configurable con
`PAPERTEX_DB_PATH`) tambien esta ignorado: es estado de una instalacion, no del
proyecto.

## Que guarda SQLite

- sesiones y pestanas abiertas;
- espacios de trabajo recientes;
- estado de la interfaz;
- perfiles de compilacion y rutas absolutas de ejecutables;
- configuracion local;
- indices de documentos y de texto extraido de PDFs;
- indices bibliograficos;
- historial de compilaciones y de trabajos de AI;
- relaciones de anotaciones y procedencia en cache.

SQLite **no** guarda manuscritos, PDFs ni datasets como blobs. El sistema de
archivos real sigue siendo la fuente de verdad; SQLite lo indexa.

## Configuracion

- Modo WAL, para que la lectura no bloquee la escritura durante compilaciones.
- FTS5 para busqueda de texto. El interprete que instala `uv` trae su propia
  copia de SQLite con FTS5 incluido, asi que no depende de la version del
  sistema ni cambia entre equipos.

## Respaldos

Los respaldos llevan datos reales de investigacion -- anotaciones, notas y
procedencia -- y por eso `db/backups/` esta ignorado. Haz un respaldo antes de
cualquier reset:

```bash
./scripts/db/backup.sh
./scripts/db/reset.sh
```
