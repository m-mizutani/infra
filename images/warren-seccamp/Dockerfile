FROM ghcr.io/secmon-lab/warren:1c79734e80a6a92b71b39e905b22707ab77ea047

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
