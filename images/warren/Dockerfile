FROM ghcr.io/secmon-lab/warren:757dd2ddb16701f9951f2daef3ecd81f2b2b0b7c

COPY policy /policy

ENV WARREN_POLICY=/policy
ENV LOG_LEVEL=debug

ENTRYPOINT ["/warren", "serve"]
