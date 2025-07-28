FROM ghcr.io/secmon-lab/warren:b39867041b52491f1edce6e5fb0879c57f1941ec

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
