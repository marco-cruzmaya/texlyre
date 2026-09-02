# Servicios en contenedor

Aqui vive el camino de compilacion **reproducible**: un contenedor con TeX Live
completo que se comporta igual en Linux, macOS, Windows y WSL. Es la forma mas
sencilla de tener una instalacion de TeX identica en cualquier equipo sin
instalar nada nativo.

No es obligatorio. Un clon nuevo compila con el proveedor `browser` (motores
WASM de TeXlyre) sin Docker y sin TeX instalado.

## Base: recetas de Chelys

Los contenedores derivan de las
[recetas de Chelys](https://github.com/TeXlyre/chelys-recipes) de upstream, no
de imagenes propias. La receta de TeX Live ya trae:

- esquema completo de TeX Live;
- `latexmk` como orquestador, con pasadas multiples, Biber/BibTeX e indices;
- motores seleccionables por trabajo: pdfLaTeX, LuaLaTeX, XeLaTeX, pLaTeX, upLaTeX;
- SyncTeX activado;
- sincronizacion incremental: mantiene un arbol de trabajo por conexion y
  transfiere solo los archivos que cambiaron despues de la primera compilacion;
- `shell-escape` activado, para `minted` y `svg`;
- utilidades: Pygments, Inkscape, gnuplot, Ghostscript, ImageMagick, JRE y
  fuentes Noto.

Expone el motor a TeXlyre por un puente WebSocket local.

## Puertos

| Servicio | Puerto | Variable de la receta |
| --- | --- | --- |
| Puente de tipografiado (TeX Live) | `7045` | `wsPort` |
| TexLab LSP | `7031` | `wsPort` |

Son los valores por omision de las recetas. Si los cambias, ajusta tambien
`TYPESETTER_BRIDGE_URL` y `TEXLAB_BRIDGE_URL` en `.env`.

## Local y remoto son el mismo proveedor

El proveedor `bridge` no distingue entre un contenedor en esta maquina y un
servidor en otra: lo unico que cambia es la URL del transporte.

```text
frontend  --WebSocket-->  ws://127.0.0.1:7045   (contenedor local)
frontend  --WebSocket-->  wss://servidor/...    (compilador remoto)
```

Por eso no existe un proveedor `docker` y otro `remote`.

## Convencion de nombres

Un archivo Compose por servicio, no un `docker-compose.yml` monolitico.

```text
docker/
├── texlive_container.yaml
├── texlab_container.yaml
└── grobid_container.yaml
```

```bash
docker compose -f docker/texlive_container.yaml up -d
```

## Estado

Vacio por ahora. Los archivos Compose se agregan en una tarea posterior,
tomando como base las recetas de Chelys.
