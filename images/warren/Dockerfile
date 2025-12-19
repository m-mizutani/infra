FROM ghcr.io/secmon-lab/warren:78b2179662955f316156c05272d31dc696d220ee

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
