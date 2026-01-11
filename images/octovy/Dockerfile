FROM ghcr.io/aquasecurity/trivy:latest AS trivy

FROM ghcr.io/secmon-lab/octovy:v0.5.0

COPY --from=trivy /usr/local/bin/trivy /usr/local/bin/trivy

ENV OCTOVY_ADDR="0.0.0.0:8080"
ENV OCTOVY_LOG_FORMAT="json"
ENV OCTOVY_TRIVY_PATH="/usr/local/bin/trivy"

EXPOSE 8080

ENTRYPOINT ["/octovy", "serve"]
