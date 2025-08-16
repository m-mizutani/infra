FROM ghcr.io/m-mizutani/backstream:v0.0.4

# Open port 8080
ENV BACKSTREAM_ADDR="0.0.0.0:8080"

# Use JSON log format
ENV BACKSTREAM_LOG_FORMAT="json"

ENV $BACKSTREAM_NO_CLIENT_CODE="200"

# Expose port 8080
EXPOSE 8080

# Run
ENTRYPOINT ["/backstream", "serve"]
