# Proveedores de compilacion

Tres caminos, no uno por distribucion de TeX:

| Proveedor | Donde corre | Requisitos | Reproducible entre equipos |
| --- | --- | --- | --- |
| `browser/` | navegador (WASM) | ninguno | si |
| `bridge/` | WebSocket a una receta de Chelys | Docker, o un servidor | si, identico en todos lados |
| `native/` | ejecutables de este equipo | TeX instalado | no |

## browser

Motores WASM de TeXlyre upstream (`src/extensions/swiftlatex`,
`src/extensions/texlyre-busytex`). No requiere instalar nada, funciona sin red
y es el proveedor por omision de un clon nuevo.

## bridge

Habla el protocolo de tipografiado de TeXlyre sobre WebSocket. **Un contenedor
local y un servidor remoto son el mismo proveedor**: solo cambia la URL del
transporte. Por eso no hay un proveedor `docker` y otro `remote`.

Las recetas de Chelys ya definen la imagen y el puente. La de TeX Live trae el
esquema completo, `latexmk`, SyncTeX, sincronizacion incremental y utilidades
(Pygments, Inkscape, gnuplot, Ghostscript, ImageMagick, Noto). Puerto por
omision `7045`.

Ver `PaperTeX/docker/README.md`.

## native

Ejecuta los binarios de TeX instalados en el equipo. Es el camino mas rapido y
el unico que aprovecha la instalacion de paquetes bajo demanda de MiKTeX, pero
no es reproducible: la distribucion, la version y las rutas cambian por equipo.

MiKTeX y TeX Live no son proveedores distintos, sino **perfiles** dentro de
`native`. La ruta absoluta de los binarios es configuracion de la instalacion y
vive en SQLite; los espacios de trabajo solo guardan el nombre de la receta.
