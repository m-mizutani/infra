FROM ghcr.io/secmon-lab/warren:529656d14960fa6dc8e3f466e3113d53723f1be7

COPY policy /policy
# COPY config /config

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
