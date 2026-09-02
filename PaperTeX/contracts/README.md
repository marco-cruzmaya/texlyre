# Contratos de API

Frontera versionada entre `frontend/` y `backend/`. El backend es la fuente de
verdad: DRF genera el esquema OpenAPI con `drf-spectacular` y de ahi sale el
cliente TypeScript que consume el frontend.

```text
Serializadores y vistas de DRF
        |
        v
Esquema OpenAPI            contracts/openapi.yaml   (versionado)
        |
        v
Cliente TypeScript         contracts/generated/     (ignorado por Git)
        |
        v
TanStack Query en frontend/src/api/
```

El cliente generado no se versiona: es un artefacto de build. El esquema si,
para que un cambio incompatible sea visible en el diff.

## Reparto de transporte

```text
HTTP/JSON                      WebSocket
├── espacios de trabajo        ├── salida del compilador
├── sesiones                   ├── eventos del sistema de archivos
├── configuracion              ├── estado de Git
├── comandos de filesystem     ├── trafico LSP
├── comandos de Git            ├── progreso de procesamiento de PDF
└── creacion y resultado       └── streaming de tokens de AI
    de trabajos
```

## Reutilizacion de contratos de TeXlyre

TeXlyre ya define un contrato de compilacion sobre transporte conectable en
`src/services/GenericTypesetterService.ts` (`TypesetterCompileRequest` y
`TypesetterCompileResult`). Conviene adoptar esas formas en lugar de inventar
unas nuevas para el proveedor de MiKTeX. Lo mismo aplica a los tipos de
`src/types/`: `compilation.ts`, `files.ts`, `lsp.ts`, `sourceMap.ts` y
`bibliography.ts`.

## Estado

Vacio por ahora. El esquema aparece cuando exista el primer endpoint.
