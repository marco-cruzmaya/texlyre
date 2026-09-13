# Scripts del frontend

## Supuestos de ubicacion

- Raiz de PaperTeX: `PaperTeX/`
- Aplicacion: `PaperTeX/frontend/`
- Entorno: `PaperTeX/.env` (de ahi sale `VITE_API_BASE_URL`)

## 1) Desarrollo

Script: `dev.sh`

Levanta Vite en el puerto `5174`. El `5173` pertenece al servidor de desarrollo
de TeXlyre upstream; ambos pueden correr al mismo tiempo, lo cual es util para
comparar comportamiento contra upstream.

## 2) Build

Script: `build.sh`

Ejecuta la verificacion de tipos y luego el build de produccion.

## Estado

Ambos son plantillas: fallan con codigo 1 y un mensaje explicito hasta que
exista la aplicacion Vite.
