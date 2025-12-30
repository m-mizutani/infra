FROM ghcr.io/secmon-lab/hecatoncheires:f3481705c360eb9b6d9903a32f44027b678cd8fd

COPY config.toml /app/config.toml

ENV HECATONCHEIRES_ADDR="0.0.0.0:8080"

EXPOSE 8080

ENTRYPOINT ["/hecatoncheires", "serve"]
