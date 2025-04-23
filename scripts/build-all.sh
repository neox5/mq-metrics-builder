#!/bin/bash
set -e

# Default values
MQ_VERSION="9.3.0.2"
REPO_VERSION="v5.6.2"
COLLECTOR="mq_prometheus"
USE_LOCAL_REPO=""

# Show usage
function show_usage {
  echo "Usage: build-all [options] [MQ_VERSION] [REPO_VERSION] [COLLECTOR]"
  echo "Options:"
  echo "  --local      Use local repository at /src/local-repo"
  echo "  --help       Show this help message"
  echo ""
  echo "Arguments:"
  echo "  MQ_VERSION   IBM MQ Client version (default: 9.3.0.2)"
  echo "  REPO_VERSION Git tag/branch to use (default: v5.6.2, ignored with --local)"
  echo "  COLLECTOR    Collector to build (default: mq_prometheus)"
  exit 1
}

# Parse options first
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)
      USE_LOCAL_REPO="true"
      shift
      ;;
    --help)
      show_usage
      ;;
    --*)
      echo "Unknown option: $1"
      show_usage
      ;;
    *)
      # Stop at the first non-option argument
      break
      ;;
  esac
done

# Parse positional arguments
if [[ $# -gt 0 ]]; then MQ_VERSION="$1"; shift; fi
if [[ $# -gt 0 ]]; then REPO_VERSION="$1"; shift; fi
if [[ $# -gt 0 ]]; then COLLECTOR="$1"; shift; fi

# Check for extra arguments
if [[ $# -gt 0 ]]; then
  echo "Warning: Extra arguments ignored: $*"
fi

echo "=== Running complete build process ==="
echo "MQ Client Version: $MQ_VERSION"

if [ -n "$USE_LOCAL_REPO" ]; then
    echo "Using local repository mounted at /src/local-repo"
else
    echo "Repository Version: $REPO_VERSION"
    echo "Using repository from GitHub"
fi

echo "Collector: $COLLECTOR"
echo "================================="

# Download MQ Client binaries and header files
setup-mq-client $MQ_VERSION

# Only clone the repository if we're not using a local repo
if [ -z "$USE_LOCAL_REPO" ]; then
    clone-mq-repo $REPO_VERSION
fi

# Build with --local flag if USE_LOCAL_REPO is set
if [ -n "$USE_LOCAL_REPO" ]; then
    build-mq-collector --local $COLLECTOR
else
    build-mq-collector $COLLECTOR
fi

echo "=== Build process completed successfully ==="
