# Scripts del backend

## Supuestos de ubicacion

Todos los scripts asumen la estructura de este repositorio:

- Raiz de PaperTeX: `PaperTeX/`
- Entorno: `PaperTeX/.env`
- Proyecto Python: `PaperTeX/backend/pyproject.toml`
- Interprete fijado: `PaperTeX/backend/.python-version`

Los scripts resuelven la raiz por si mismos, asi que pueden ejecutarse desde
cualquier directorio.

## 1) Verificar herramientas

Script: `preflight_toolchain.sh`

Comprueba `git`, `node`, `npm`, `uv`, Python 3.13, los ejecutables de MiKTeX
accesibles desde WSL y, de forma opcional, `texlab` y TeX Live. Devuelve codigo
distinto de cero si falta algo obligatorio.

```bash
./scripts/backend/preflight_toolchain.sh
./scripts/backend/preflight_toolchain.sh -e /ruta/a/otro/.env
```

Es el unico script implementado en esta etapa. Ejecutalo antes de cualquier
otra cosa.

## 2) Crear el entorno

Script: `init_venv.sh`

Crea el entorno con `uv sync` usando `backend/.python-version` y
`backend/pyproject.toml`, y genera `backend/uv.lock`.

## 3) Migrar

Script: `migrate.sh`

Aplica las migraciones de Django sobre la base local y habilita el modo WAL.

## 4) Ejecutar el servidor

Script: `runserver.sh`

Levanta el servidor ASGI enlazado a `PAPERTEX_HOST:PAPERTEX_PORT`, que por
omision es `127.0.0.1:8000`.

## Estado

`init_venv.sh`, `migrate.sh` y `runserver.sh` son plantillas: fallan con
codigo 1 y un mensaje explicito hasta que exista el proyecto Django.
