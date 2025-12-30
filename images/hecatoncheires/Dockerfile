FROM ghcr.io/m-mizutani/hecatoncheires:d30b6731c62be5f8f228797be534caa6f699b353

COPY config.toml /app/config.toml

ENV HECATONCHEIRES_ADDR="0.0.0.0:8080"

EXPOSE 8080

ENTRYPOINT ["/hecatoncheires", "serve"]
