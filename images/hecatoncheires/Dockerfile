FROM ghcr.io/secmon-lab/hecatoncheires:2a8b56e4124772cf0cb0ddea7e7d3048404e0024

COPY config.toml /app/config.toml

ENV HECATONCHEIRES_ADDR="0.0.0.0:8080"

EXPOSE 8080

ENTRYPOINT ["/hecatoncheires", "serve"]
