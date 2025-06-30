FROM ghcr.io/secmon-lab/warren:008e2d844c08ae1ba1e0b124f8a29fe97c481f88

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
