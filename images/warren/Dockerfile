FROM ghcr.io/secmon-lab/warren:3d0c89d7b3d365670816064fcd221d663e088ba1

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
