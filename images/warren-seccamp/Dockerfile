FROM ghcr.io/secmon-lab/warren:d4502f45939a0163309ebe2d887988687a427f5b

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV WARREN_LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
