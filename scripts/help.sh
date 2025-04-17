#!/bin/bash

cat << EOF
IBM MQ Metrics Builder

Available commands:

  setup-mq-client [MQ_VERSION]
    Setup IBM MQ Client (default: 9.3.0.2)

  clone-mq-repo [REPO_VERSION]
    Clone repository (default: v5.6.2)

  build-mq-collector [COLLECTOR] [USE_LOCAL_REPO]
    Build collector (default: mq_prometheus)
    Optional: Set USE_LOCAL_REPO to any value to use the locally mounted repository at /src/local-repo

  build-all [MQ_VERSION] [REPO_VERSION] [COLLECTOR] [USE_LOCAL_REPO]
    Run all steps with specified versions
    Optional: Set USE_LOCAL_REPO to any value to use the locally mounted repository

Examples:

  # Run complete build with defaults
  podman run --rm -v \$(pwd)/output:/output:Z mq-metrics-builder build-all

  # Run complete build with specific versions
  podman run --rm -v \$(pwd)/output:/output:Z mq-metrics-builder build-all 9.3.0.2 v5.6.2 mq_prometheus

  # Run build using a local repository copy
  podman run --rm -v \$(pwd)/output:/output:Z -v \$(pwd)/local-repo:/src/local-repo:Z mq-metrics-builder build-all 9.3.0.2 v5.6.2 mq_prometheus true

  # Run steps individually in a persistent container
  podman create --name mq-builder -v \$(pwd)/output:/output:Z mq-metrics-builder
  podman start -a mq-builder bash -c "setup-mq-client 9.3.0.2"
  podman start -a mq-builder bash -c "clone-mq-repo v5.6.2"
  podman start -a mq-builder bash -c "build-mq-collector mq_prometheus"
  podman rm mq-builder

  # Build using local repository in persistent container
  podman create --name mq-builder -v \$(pwd)/output:/output:Z -v \$(pwd)/local-repo:/src/local-repo:Z mq-metrics-builder
  podman start -a mq-builder bash -c "setup-mq-client 9.3.0.2"
  podman start -a mq-builder bash -c "build-mq-collector mq_prometheus true"
  podman rm mq-builder

  # Build other collectors
  podman run --rm -v \$(pwd)/output:/output:Z mq-metrics-builder build-all 9.3.0.2 v5.6.2 mq_cloudwatch
EOF
