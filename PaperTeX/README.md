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

Obligatorios:

- Git.
- Node.js `>=22` y npm.
- [uv](https://docs.astral.sh/uv/). Si no lo tienes, `scripts/setup.sh` lo
  instala por ti.

Eso es todo. `uv` descarga Python 3.13 y las dependencias; no hace falta
compilar nada ni instalar Python en el sistema.

Opcionales, para compilar mas rapido o con TeX completo:

- Docker Engine con Compose v2, para el contenedor de TeX Live.
- Una instalacion local de TeX: TeX Live en Linux, MacTeX en macOS, MiKTeX o
  TeX Live en Windows. `scripts/setup.sh` la detecta sola.

**No necesitas instalar LaTeX para usar PaperTeX.** El proveedor por omision
compila con los motores WASM de TeXlyre dentro del navegador.

## Inicio rapido

Los comandos se ejecutan desde `PaperTeX/`, salvo que se indique lo contrario.

### 1. Un solo comando

```bash
./scripts/setup.sh
```

Instala `uv` si falta, descarga Python 3.13, sincroniza las dependencias, crea
`.env` a partir de `.env.example`, genera el token de la instalacion y detecta
que proveedores de compilacion ofrece este equipo. Se puede volver a ejecutar
sin riesgo: nunca sobrescribe un valor que ya exista en `.env`.

### 2. Revisa lo detectado

```bash
./scripts/backend/preflight_toolchain.sh
```

### 3. Levanta los servicios

```bash
./scripts/backend/runserver.sh     # API en http://127.0.0.1:8000
./scripts/frontend/dev.sh          # interfaz en http://localhost:5174
```

### 4. Opcional: TeX Live en contenedor

```bash
docker compose -f docker/texlive_container.yaml up -d
```

Da una instalacion de TeX identica en cualquier equipo. Ver
[docker/README.md](docker/README.md).

## Puertos

El puerto `5173` pertenece al servidor de desarrollo de TeXlyre upstream.
PaperTeX usa `5174` para poder ejecutar ambos al mismo tiempo y comparar
comportamientos.

| Servicio | Direccion | Responsable |
| --- | --- | --- |
| TeXlyre upstream (Vite) | `http://localhost:5173` | upstream, no usar |
| PaperTeX frontend (Vite) | `http://localhost:5174` | PaperTeX |
| Backend Django (ASGI) | `http://127.0.0.1:8000` | PaperTeX |
| Puente de tipografiado (TeX Live) | `ws://127.0.0.1:7045` | receta de Chelys |
| TexLab LSP | `ws://127.0.0.1:7031` | receta de Chelys |
| Ollama (opcional) | `http://127.0.0.1:11434` | externo |

El backend se enlaza solo a loopback. PaperTeX es una herramienta personal y no
debe exponerse en la red.

## Proveedores de compilacion

| Proveedor | Requisitos | Igual en todos los equipos | Cuando usarlo |
| --- | --- | --- | --- |
| `browser` | ninguno | si | Por omision. Funciona en un clon recien hecho y sin red. |
| `bridge` | Docker, o un servidor | si | TeX Live completo y reproducible. |
| `native` | TeX instalado | no | Maxima velocidad; MiKTeX instala paquetes bajo demanda. |

`bridge` no distingue entre un contenedor local y un compilador remoto: es el
mismo protocolo sobre WebSocket y solo cambia la URL. Ver
[backend/apps/compilers/providers/README.md](backend/apps/compilers/providers/README.md).

Las rutas absolutas de los ejecutables son configuracion de esta instalacion y
viven en SQLite y en `.env`. Los espacios de trabajo solo guardan el nombre de
la receta, para que sigan siendo portables entre equipos.

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

- **Un puerto ya esta en uso:** libera o cambia `5174`, `8000`, `7045` o `7031`
  antes de iniciar los servicios. Si `5173` esta ocupado suele ser el TeXlyre
  upstream corriendo en paralelo, lo cual es esperado.
- **No se detecta el TeX local:** no es un error. PaperTeX compila igual con el
  proveedor `browser`. Si quieres usar el TeX del equipo, pon la ruta de los
  binarios en `TEX_BIN_PATH` dentro de `.env` y vuelve a ejecutar el preflight.
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
