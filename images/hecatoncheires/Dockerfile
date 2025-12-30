FROM ghcr.io/secmon-lab/hecatoncheires:fcb1a668ac253dc3c32001798ba873c97ef9ae20

COPY config.toml /app/config.toml

ENV HECATONCHEIRES_ADDR="0.0.0.0:8080"

EXPOSE 8080

ENTRYPOINT ["/hecatoncheires", "serve"]
