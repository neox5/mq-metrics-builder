#!/bin/bash
set -e

MQ_VERSION=${1:-9.3.0.2}
REPO_VERSION=${2:-v5.6.2}
COLLECTOR=${3:-mq_prometheus}
USE_LOCAL_REPO=${4:-""}

echo "=== Running complete build process ==="
echo "MQ Client Version: $MQ_VERSION"

if [ -z "$USE_LOCAL_REPO" ]; then
    echo "Repository Version: $REPO_VERSION"
    echo "Using repository from GitHub"
else
    echo "Using local repository mounted at /src/local-repo"
fi

echo "Collector: $COLLECTOR"
echo "================================="

# Run each step
setup-mq-client $MQ_VERSION

# Only clone the repository if we're not using a local repo
if [ -z "$USE_LOCAL_REPO" ]; then
    clone-mq-repo $REPO_VERSION
fi

build-mq-collector $COLLECTOR $USE_LOCAL_REPO

echo "=== Build process completed successfully ==="
echo "The binary is available in /output/$COLLECTOR"
