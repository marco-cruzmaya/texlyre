# PaperTeX frontend

Aplicacion React 19 con Vite. Sirve la experiencia de espacio de trabajo
academico personal: explorador de proyectos, editor, lector de PDFs de
investigacion, anotaciones, Git, seleccion de compilador y configuracion.

Puerto de desarrollo: `5174`. El `5173` pertenece a TeXlyre upstream.

## La regla del limite upstream

**Solo `src/upstream/` puede importar codigo de TeXlyre.** El resto de PaperTeX
depende de las interfaces que expone `src/upstream/`, nunca de rutas de upstream
directamente.

```text
src/routes, src/hooks, src/components, src/api
        |
        v
src/upstream/          <-- unica frontera permitida
        |
        v
../../../src/          <-- TeXlyre upstream (services, extensions, plugins)
```

Los componentes de TeXlyre se importan o se componen, **nunca se copian**. Esa
es la unica forma de seguir recibiendo sus correcciones de errores al hacer
merge de upstream. Un componente copiado se congela en el momento de la copia.

Modulos previstos en `src/upstream/`:

| Modulo | Que expone de TeXlyre |
| --- | --- |
| `editor.ts` | componentes de editor compuestos, no copiados |
| `codemirror.ts` | extensiones de CodeMirror (LaTeX, Typst, BibTeX, LSP, MathLive) |
| `browser-latex.ts` | motores de compilacion en navegador (SwiftLaTeX, BusyTeX) |
| `pdf.ts` | renderizado de PDF y SyncTeX |
| `plugins.ts` | registro de plugins y sus visores |
| `bibliography.ts` | importadores de Zotero, OpenAlex y JabRef |
| `types.ts` | tipos compartidos de `src/types/` |

Conviene una prueba de compatibilidad por adaptador, para que un cambio de API
en upstream falle de forma clara al ejecutar las pruebas y no en tiempo de
ejecucion.

## Estructura

```text
src/
├── routes/       vistas de TanStack Router
├── hooks/        hooks de React propios
├── api/          cliente generado desde contracts/ y hooks de TanStack Query
├── components/   componentes propios de PaperTeX
├── types/        tipos propios
├── utils/        utilidades
├── test/         pruebas
└── upstream/     unica frontera hacia TeXlyre
```

Las pruebas se colocan junto al modulo que prueban (`modulo.ts` y
`modulo.spec.ts` en el mismo directorio).

## Estado

Este directorio contiene por ahora solo la estructura. La aplicacion Vite, el
`package.json` y las dependencias se crean en una tarea posterior.
