# Scripts de servicios en contenedor

## Supuestos de ubicacion

- Raiz de PaperTeX: `PaperTeX/`
- Archivos Compose: `PaperTeX/docker/<servicio>_container.yaml`
- Entorno: `PaperTeX/.env`

## Alcance

PaperTeX no necesita Docker para funcionar: SQLite es un archivo y MiKTeX corre
en Windows via interoperabilidad de WSL. Estos scripts son solo para servicios
auxiliares opcionales como TexLab, Ollama o GROBID.

Convencion de verbos, un verbo por script:

```text
init_container.sh     delete_container.sh
backup_container.sh   restore_container.sh
```

## Estado

Vacio por ahora. Ver [../../docker/README.md](../../docker/README.md).
