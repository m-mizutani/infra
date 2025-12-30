FROM ghcr.io/m-mizutani/hecatoncheires:latest

COPY config.toml /app/config.toml

ENV HECATONCHEIRES_ADDR="0.0.0.0:8080"

EXPOSE 8080

ENTRYPOINT ["/hecatoncheires", "serve"]
