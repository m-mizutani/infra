FROM ghcr.io/secmon-lab/warren:v0.2.0

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV WARREN_LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
