FROM ghcr.io/secmon-lab/warren:50d87a2c8e917bf7e0e50ad7e82226cba5e1e0fa

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
