# Servicios auxiliares en contenedor

PaperTeX es local-first y **no necesita Docker para funcionar**. La base es
SQLite, que es un archivo, y MiKTeX corre en Windows a traves de la
interoperabilidad de WSL, asi que no se contenedoriza.

Este directorio es solo para servicios auxiliares opcionales:

- TexLab, si prefieres aislarlo en lugar de instalarlo en WSL;
- Ollama, para modelos locales;
- GROBID, para analisis avanzado de PDFs.

Convencion de nombres: un archivo Compose por servicio, no un
`docker-compose.yml` monolitico.

```text
docker/
├── texlab_container.yaml
├── ollama_container.yaml
└── grobid_container.yaml
```

Si alguna vez arrancar PaperTeX requiere levantar un contenedor, se perdio la
propiedad local-first. Manten estos servicios opcionales.

## Estado

Vacio por ahora.
