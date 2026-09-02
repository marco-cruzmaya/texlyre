# Scripts de base de datos

## Supuestos de ubicacion

- Raiz de PaperTeX: `PaperTeX/`
- Entorno: `PaperTeX/.env` (de ahi sale `PAPERTEX_DB_PATH`)
- Base local: `PaperTeX/db/papertex.sqlite3` por omision
- Respaldos: `PaperTeX/db/backups/`
- Datos de desarrollo: `PaperTeX/db/fixtures/`

Las migraciones **no** viven aqui: las posee Django, una por app, en
`backend/apps/*/migrations/`. Ver [../../db/README.md](../../db/README.md).

## 1) Respaldar

Script: `backup.sh`

Genera una copia con marca de tiempo en `db/backups/`. Ese directorio esta
ignorado por Git porque los respaldos llevan datos reales de investigacion:
anotaciones, notas y procedencia.

## 2) Restaurar

Script: `restore.sh`

Restaura la base desde un respaldo. Requiere la ruta del archivo de forma
explicita; no adivina cual usar.

## 3) Cargar datos de desarrollo

Script: `seed.sh`

Carga los fixtures de `db/fixtures/` con `manage.py loaddata`.

## 4) Reiniciar

Script: `reset.sh`

Respalda, borra la base y vuelve a migrar. **Destruye el estado local de la
instalacion**: sesiones, anotaciones, procedencia e historiales. No afecta los
archivos de investigacion, que viven en el sistema de archivos real.

## Estado

Los cuatro son plantillas: fallan con codigo 1 y un mensaje explicito hasta que
exista el proyecto Django.
