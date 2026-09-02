# PaperTeX backend

Servicio companion local con Django, DRF y Channels sobre ASGI. No renderiza
HTML: expone HTTP/JSON y WebSocket para el frontend de PaperTeX.

Se enlaza solo a loopback (`127.0.0.1:8000`) y se autentica con un token por
instalacion definido en `PAPERTEX_TOKEN`.

## Interprete

Python 3.13, fijado en `.python-version` y gestionado con `uv`. Django 5.2 es
LTS pero no soporta Python 3.14, que es la version del sistema en este equipo:
por eso la version se fija de forma explicita.

```bash
uv python install 3.13
./scripts/backend/init_venv.sh
```

Las dependencias se declaran en `pyproject.toml`. `uv.lock` se genera al crear
el entorno y **si** se versiona.

## Responsabilidades

- acceso al sistema de archivos real;
- registro de espacios de trabajo;
- sesiones persistentes de la aplicacion;
- persistencia en SQLite;
- operaciones de Git mediante el CLI real;
- compilacion nativa de LaTeX y descubrimiento de perfiles de compilador;
- gestion de procesos LSP (TexLab);
- extraccion y procesamiento de PDFs;
- resolucion de bibliografia;
- ejecucion de Codex CLI y Ollama, con control de permisos;
- procedencia y seguimiento de trabajos.

El trabajo de larga duracion pasa por un supervisor de trabajos local. No se
introduce Celery ni Redis.

## Estructura

```text
config/          configuracion del proyecto Django
apps/
├── workspaces/           registro de espacios de trabajo
├── sessions/             sesiones, pestanas abiertas y estado de interfaz
├── filesystem/           acceso y eventos del sistema de archivos real
├── compilers/            perfiles de compilacion y trabajos
│   └── providers/
│       ├── browser/      motores WASM de TeXlyre
│       ├── miktex/       MiKTeX de Windows via interoperabilidad de WSL
│       └── texlive/      TeX Live en WSL (futuro)
├── git/                  operaciones de Git expuestas de forma controlada
├── lsp/                  supervision de TexLab
├── research_documents/   PDFs de investigacion e indices de texto
├── annotations/          anotaciones y resaltados
├── provenance/           procedencia; proyeccion de solo lectura
├── bibliography/         indices y resolucion bibliografica
└── ai/                   flujos de AI y permisos
    └── providers/
        ├── codex/        Codex CLI
        └── ollama/       modelos locales
```

Cada app repite la misma forma interna (`models.py`, `serializers.py`,
`services.py`, `views.py`, `urls.py`, y `consumers.py` donde haya WebSocket),
aunque algun archivo quede casi vacio. La consistencia es lo que hace navegable
cualquier app despues de leer una.

Los subdominios se anidan dentro de su app padre (`compilers/providers/`,
`ai/providers/`) en lugar de convertirse en apps de primer nivel.

`provenance/` es en su mayor parte una proyeccion de solo lectura sobre datos de
otras apps; no necesita poseer tablas propias mas alla de lo indispensable.

## Estado

Este directorio contiene por ahora solo la estructura y las dependencias
declaradas. El proyecto Django se crea en una tarea posterior.
