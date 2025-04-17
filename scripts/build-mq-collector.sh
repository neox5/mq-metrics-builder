#!/bin/bash
set -e

COLLECTOR=${1:-mq_prometheus}
echo "Building $COLLECTOR collector"

# Set environment variables for MQ libraries
export CGO_CFLAGS="-I/opt/mqm/inc"
export CGO_LDFLAGS="-L/opt/mqm/lib64 -lmqm_r -Wl,-rpath,/opt/mqm/lib64"
export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*"

# Check if the repository exists
if [ ! -d "/src/mq-metric-samples" ]; then
    echo "Error: Repository not found. Please run clone-mq-repo first."
    exit 1
fi

cd /src/mq-metric-samples

# Check if the collector directory exists
if [ ! -d "cmd/$COLLECTOR" ]; then
    echo "Error: Collector '$COLLECTOR' not found in repository."
    echo "Available collectors:"
    ls -la cmd/
    exit 1
fi

# Build the collector
echo "Building collector $COLLECTOR..."
go build -mod=vendor -o /output/$COLLECTOR cmd/$COLLECTOR/*.go

echo "Build complete. Binary is in /output/$COLLECTOR"
