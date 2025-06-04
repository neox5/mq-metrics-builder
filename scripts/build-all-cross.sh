#!/bin/bash
set -e

# Default values - MQ is already installed in the image
REPO_VERSION="${REPO_VERSION:-v5.5.4}"
COLLECTOR="${COLLECTOR:-mq_otel}"
USE_LOCAL_REPO=""

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)
      USE_LOCAL_REPO="true"
      shift
      ;;
    --help)
      echo "Usage: build-all-cross [options] [REPO_VERSION] [COLLECTOR]"
      echo "Options:"
      echo "  --local      Use local repository at /src/local-repo"
      echo "  --help       Show this help message"
      echo ""
      echo "Note: IBM MQ Client (s390x) is pre-installed in this image"
      exit 1
      ;;
    --*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

# Parse positional arguments
if [[ $# -gt 0 ]]; then REPO_VERSION="$1"; shift; fi
if [[ $# -gt 0 ]]; then COLLECTOR="$1"; shift; fi

echo "=== Running s390x cross-compilation build process ==="
echo "Repository Version: $REPO_VERSION"
echo "Collector: $COLLECTOR"
echo "Target Architecture: s390x"
echo "Build Method: Cross-compilation"
echo "MQ Client: Pre-installed s390x libraries"
echo "=================================================="

# Clone repository if not using local
if [ -z "$USE_LOCAL_REPO" ]; then
    clone-mq-repo $REPO_VERSION
fi

# Build collector (MQ setup not needed - already in image)
if [ -n "$USE_LOCAL_REPO" ]; then
    build-mq-collector --local $COLLECTOR
else
    build-mq-collector $COLLECTOR
fi

echo "=== s390x cross-compilation build completed successfully ==="
