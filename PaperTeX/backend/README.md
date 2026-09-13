# PaperTeX backend

Servicio companion local con Django, DRF y Channels sobre ASGI. No renderiza
HTML: expone HTTP/JSON y WebSocket para el frontend de PaperTeX.

Se enlaza solo a loopback (`127.0.0.1:8000`) y se autentica con un token por
instalacion definido en `PAPERTEX_TOKEN`.

## Interprete

Python 3.13, fijado en `.python-version` y gestionado con `uv`. Django 5.2 es
LTS y no soporta Python 3.14, asi que la version se fija de forma explicita en
lugar de depender del interprete del sistema, que cambia entre equipos.

`uv` descarga un interprete propio, identico en Linux, macOS y Windows, junto
con `uv.lock`. Eso hace que un clon nuevo obtenga exactamente las mismas
versiones sin compilar nada.

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
- perfiles de compilacion, descubrimiento e historial de trabajos;
- ejecucion del proveedor `native` cuando hay TeX instalado localmente;
- extraccion y procesamiento de PDFs;
- resolucion de bibliografia;
- ejecucion de Codex CLI y Ollama, con control de permisos;
- procedencia y seguimiento de trabajos.

El trabajo de larga duracion pasa por un supervisor de trabajos local. No se
introduce Celery ni Redis.

## Lo que el backend NO hace

**No supervisa procesos de compiladores ni de servidores de lenguaje.** Esa es
la funcion de las recetas de Chelys y de los contenedores de
`PaperTeX/docker/`, que ya exponen un puente WebSocket. Reimplementar esa
gestion seria duplicar trabajo de upstream.

El backend registra perfiles, descubre lo disponible en el equipo y guarda el
historial de trabajos; el frontend habla el protocolo de tipografiado
directamente con el puente. Ver
[apps/compilers/providers/README.md](apps/compilers/providers/README.md).

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
