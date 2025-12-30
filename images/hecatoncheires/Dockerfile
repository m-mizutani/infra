FROM ghcr.io/secmon-lab/hecatoncheires:20d940d387b010953487c194064d3aaed803111b

COPY config.toml /app/config.toml

ENV HECATONCHEIRES_ADDR="0.0.0.0:8080"

EXPOSE 8080

ENTRYPOINT ["/hecatoncheires", "serve"]
