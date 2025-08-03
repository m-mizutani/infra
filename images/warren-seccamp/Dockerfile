FROM ghcr.io/secmon-lab/warren:6e65a18607a9915e4e98f70dce5f915c84eba1f1

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
