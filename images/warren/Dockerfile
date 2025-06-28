FROM ghcr.io/secmon-lab/warren:11c29547a99917e8d5edb0d8d968eef07b9b8b25

COPY policy /policy
COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
