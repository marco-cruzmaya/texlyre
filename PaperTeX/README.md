# PaperTeX

Entorno academico local-first construido sobre TeXlyre. Convierte el editor
colaborativo en un espacio personal de investigacion: espacios de trabajo sobre
el sistema de archivos real, compilacion nativa de LaTeX, estado de sesion en
SQLite, Git, PDFs de investigacion con anotaciones, flujos de AI, bibliografia y
procedencia.

El proyecto se compone de:

- `frontend/`: aplicacion React 19 con Vite.
- `backend/`: servicio companion local con Django, DRF y Channels.
- `contracts/`: esquema OpenAPI y cliente TypeScript generado.
- `db/`: estado local en SQLite, respaldos y datos de desarrollo.
- `docker/` y `scripts/docker/`: servicios auxiliares opcionales.
- `scripts/`: comandos de PaperTeX.

## Relacion con TeXlyre upstream

PaperTeX vive dentro del fork de TeXlyre, pero **no modifica el codigo upstream**.
El directorio raiz (`src/`, `package.json`, `vite.config.ts`, `scripts/`,
`index.html`) pertenece a upstream y se actualiza con `git fetch upstream` y un
merge. Todo lo propio vive bajo `PaperTeX/`.

| Area | Responsable | Como se actualiza |
| --- | --- | --- |
| Archivos raiz de TeXlyre | Upstream | `git fetch upstream` + merge |
| `PaperTeX/**` | Este proyecto | Ramas de trabajo normales |
| Adaptadores upstream | Este proyecto | Solo cuando cambia una API de upstream |

La regla arquitectonica principal es que **solo `frontend/src/upstream/` puede
importar codigo de TeXlyre**. El resto de PaperTeX depende de esas interfaces,
nunca de rutas de upstream directamente. Asi se siguen heredando las
correcciones de errores de upstream sin copiar componentes. Ver
[frontend/README.md](frontend/README.md).

## Requisitos

- Git.
- [uv](https://docs.astral.sh/uv/) para gestionar el interprete y las
  dependencias de Python.
- Python 3.13, instalado con `uv python install 3.13`. Django 5.2 LTS no soporta
  Python 3.14, por eso la version queda fijada en `backend/.python-version`.
- Node.js `>=22` y npm.
- MiKTeX en Windows, accesible desde WSL. En este equipo esta verificado en
  `/mnt/c/Users/marco/AppData/Local/Programs/MiKTeX/miktex/bin/x64`.
- Opcional: Docker Engine con Docker Compose v2, solo para servicios auxiliares
  como TexLab u Ollama. PaperTeX no lo necesita para funcionar.

No se requiere una instalacion de TeX Live en WSL: es un proveedor de
compilacion futuro y opcional.

## Inicio rapido

Los comandos se ejecutan desde `PaperTeX/`, salvo que se indique lo contrario.

### 1. Configura el entorno

```bash
cp .env.example .env
```

`.env` no se versiona. Revisa `MIKTEX_BIN_PATH` y genera `PAPERTEX_TOKEN`:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 2. Verifica las herramientas del equipo

```bash
./scripts/backend/preflight_toolchain.sh
```

Comprueba `uv`, Python 3.13, Node, Git y que los ejecutables de MiKTeX
respondan desde WSL. Resuelve lo que reporte como faltante antes de continuar.

### 3. Prepara el backend

```bash
./scripts/backend/init_venv.sh
./scripts/db/reset.sh
./scripts/backend/runserver.sh
```

La API queda disponible en `http://127.0.0.1:8000`.

### 4. Inicia el frontend

En otra terminal:

```bash
./scripts/frontend/dev.sh
```

Vite sirve la aplicacion en `http://localhost:5174`.

## Puertos

El puerto `5173` pertenece al servidor de desarrollo de TeXlyre upstream.
PaperTeX usa `5174` para poder ejecutar ambos al mismo tiempo y comparar
comportamientos.

| Servicio | Direccion | Responsable |
| --- | --- | --- |
| TeXlyre upstream (Vite) | `http://localhost:5173` | upstream, no usar |
| PaperTeX frontend (Vite) | `http://localhost:5174` | PaperTeX |
| Backend Django (ASGI) | `http://127.0.0.1:8000` | PaperTeX |
| TexLab (WebSocket) | `ws://127.0.0.1:7658` | PaperTeX |
| Ollama (opcional) | `http://127.0.0.1:11434` | externo |

El backend se enlaza solo a loopback. PaperTeX es una herramienta personal y no
debe exponerse en la red.

## Autoridad del sistema de archivos

El sistema de archivos real es la fuente de verdad para manuscritos, PDFs,
BibTeX, notas y datasets. SQLite guarda unicamente estado de la instalacion:
sesiones, estado de la interfaz, anotaciones, procedencia, perfiles de
compilacion, configuracion local e historiales.

No coloques el espacio de trabajo de investigacion dentro de `PaperTeX/`. Se
abre desde cualquier carpeta real del sistema.

## Verificacion basica

```bash
./scripts/frontend/build.sh
./scripts/backend/preflight_toolchain.sh
```

## Problemas frecuentes

- **Un puerto ya esta en uso:** libera o cambia `5174`, `8000` o `7658` antes de
  iniciar los servicios. Si `5173` esta ocupado suele ser el TeXlyre upstream
  corriendo en paralelo, lo cual es esperado.
- **No se encuentra MiKTeX:** confirma que `MIKTEX_BIN_PATH` en `.env` apunta a
  la carpeta `miktex/bin/x64` de tu instalacion de Windows y que
  `"$MIKTEX_BIN_PATH/pdflatex.exe" --version` responde desde WSL.
- **Falla la creacion del entorno de Python:** verifica que `uv` este instalado
  y que `uv python install 3.13` haya terminado correctamente. Django 5.2 no
  funciona con Python 3.14.
- **La base local quedo inconsistente:** usa `./scripts/db/backup.sh` antes de
  `./scripts/db/reset.sh`; el reset borra el estado local de la instalacion.

Para mas detalle consulta
[scripts/backend/README.md](scripts/backend/README.md),
[scripts/db/README.md](scripts/db/README.md),
[scripts/frontend/README.md](scripts/frontend/README.md) y
[scripts/docker/README.md](scripts/docker/README.md).
