FROM ghcr.io/secmon-lab/warren:a3a34a0f2daf4fc6dcb9a50d51458d194517c038

COPY policy /policy

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
