FROM ghcr.io/secmon-lab/warren:529e5c5e9f5f91f6a9118c313c5ebbefcb94a2c1

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
