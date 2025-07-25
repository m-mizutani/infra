FROM ghcr.io/secmon-lab/warren:de65151e102e7e536dbda52b8af9df2277ecb86c

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
