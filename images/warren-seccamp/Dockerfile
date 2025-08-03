FROM ghcr.io/secmon-lab/warren:dc09b164f9ed7418661b7ce1c8c00617afe832d0

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
