#!/bin/bash
set -e

# Default values
COLLECTOR="mq_prometheus"
USE_LOCAL_REPO=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --local)
      USE_LOCAL_REPO="true"
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Usage: build-mq-collector [--local] COLLECTOR_NAME"
      exit 1
      ;;
    *)
      COLLECTOR="$1"
      shift
      ;;
  esac
done

echo "Building $COLLECTOR collector"

# Check which repository to use
REPO_PATH="/src/mq-metric-samples"
if [ -n "$USE_LOCAL_REPO" ]; then
    echo "Using local repository at /src/local-repo"
    REPO_PATH="/src/local-repo"
fi

# Set environment variables for MQ libraries
export CGO_CFLAGS="-I/opt/mqm/inc"
export CGO_LDFLAGS="-L/opt/mqm/lib64 -lmqm_r -Wl,-rpath,/opt/mqm/lib64"
export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*"

# Enable reproducible builds by setting build flags
export GOFLAGS="-trimpath"

# Try to use git commit timestamp for reproducible builds
# If git command fails, fall back to a fixed timestamp
if [ -d "$REPO_PATH/.git" ]; then
    cd $REPO_PATH
    export SOURCE_DATE_EPOCH=$(git show -s --format=%ct)
    echo "Using git commit timestamp for reproducible build"
else
    # Use a fixed timestamp as fallback (Jan 1, 2023)
    export SOURCE_DATE_EPOCH=1672531200
    echo "Using fixed timestamp for reproducible build"
fi

# Check if the repository exists
if [ ! -d "$REPO_PATH" ]; then
    echo "Error: Repository not found at $REPO_PATH"
    if [ -n "$USE_LOCAL_REPO" ]; then
        echo "Please make sure your local repository is mounted at /src/local-repo"
    else
        echo "Please run clone-mq-repo first."
    fi
    exit 1
fi

cd $REPO_PATH

# Check if the collector directory exists
if [ ! -d "cmd/$COLLECTOR" ]; then
    echo "Error: Collector '$COLLECTOR' not found in repository."
    echo "Available collectors:"
    ls -la cmd/
    exit 1
fi

# Build the collector with reproducible build flags
echo "Building collector $COLLECTOR from $REPO_PATH with reproducible build flags..."
go build -mod=vendor -trimpath -o /output/$COLLECTOR cmd/$COLLECTOR/*.go

echo "Build complete. Binary is in /output/$COLLECTOR"
