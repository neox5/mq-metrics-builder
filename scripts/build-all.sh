#!/bin/bash
set -e

MQ_VERSION=${1:-9.3.0.2}
REPO_VERSION=${2:-v5.6.2}
COLLECTOR=${3:-mq_prometheus}

echo "=== Running complete build process ==="
echo "MQ Client Version: $MQ_VERSION"
echo "Repository Version: $REPO_VERSION"
echo "Collector: $COLLECTOR"
echo "================================="

# Run each step
setup-mq-client $MQ_VERSION
clone-mq-repo $REPO_VERSION
build-mq-collector $COLLECTOR

echo "=== Build process completed successfully ==="
echo "The binary is available in /output/$COLLECTOR"
