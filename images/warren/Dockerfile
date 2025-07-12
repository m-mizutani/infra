FROM ghcr.io/secmon-lab/warren:68107439f96d70659320073171ed2227e5ed4cf3

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
