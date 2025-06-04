#!/bin/bash

cat << EOF
IBM MQ Metrics Builder - s390x Cross-Compilation

This container cross-compiles IBM MQ collectors for s390x architecture.

Available commands:

  clone-mq-repo [REPO_VERSION]
    Clone mq-metric-samples repository (default: v5.5.4)

  build-mq-collector [--local] [COLLECTOR]
    Cross-compile collector for s390x (default: mq_otel)
    --local: Use locally mounted repository at /src/local-repo

  build-all-cross [--local] [REPO_VERSION] [COLLECTOR]
    Run complete cross-compilation process

Pre-installed in this image:
  • IBM MQ Client 9.3.0.28 (s390x libraries and headers)
  • Go 1.22.11 with s390x cross-compilation support
  • s390x-linux-gnu-gcc cross-compiler toolchain

Examples:

  # Run complete build with defaults
  podman run --rm -v \$(pwd)/bin:/output:Z mq-metrics-builder:s390x-cross

  # Build specific collector
  podman run --rm -v \$(pwd)/bin:/output:Z mq-metrics-builder:s390x-cross build-all-cross v5.5.4 mq_prometheus

  # Use local repository
  podman run --rm -v \$(pwd)/bin:/output:Z -v \$(pwd)/local-repo:/src/local-repo:Z \\
    mq-metrics-builder:s390x-cross build-all-cross --local

  # Build other collectors
  podman run --rm -v \$(pwd)/bin:/output:Z \\
    -e COLLECTOR=mq_cloudwatch mq-metrics-builder:s390x-cross

Available collectors:
  • mq_prometheus  - Prometheus metrics collector
  • mq_otel        - OpenTelemetry collector  
  • mq_influx      - InfluxDB collector
  • mq_json        - JSON formatted output
  • mq_cloudwatch  - AWS CloudWatch collector

Output: s390x binaries ready for deployment on IBM Z/LinuxONE systems
EOF
