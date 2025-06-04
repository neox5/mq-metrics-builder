#!/bin/bash
set -e

# Default values
COLLECTOR="mq_otel"
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

echo "Cross-compiling $COLLECTOR for s390x architecture"

# Determine repository path
REPO_PATH="/src/mq-metric-samples"
if [ -n "$USE_LOCAL_REPO" ]; then
    echo "Using local repository at /src/local-repo"
    REPO_PATH="/src/local-repo"
fi

# Set cross-compilation environment variables
export GOOS=linux
export GOARCH=s390x
export CGO_ENABLED=1
export CC=s390x-linux-gnu-gcc
export CXX=s390x-linux-gnu-g++

# Set environment variables for MQ libraries (find actual locations)
echo "Locating MQ installation..."
MQ_INC_DIR=$(find /opt/mqm -name "cmqc.h" -exec dirname {} \; | head -1)
MQ_LIB_DIR=$(find /opt/mqm -name "libmqm_r*" -exec dirname {} \; | head -1)

if [ -z "$MQ_INC_DIR" ] || [ -z "$MQ_LIB_DIR" ]; then
    echo "Error: Could not locate MQ installation"
    echo "Searching for header files:"
    find /opt/mqm -name "*.h" | head -5
    echo "Searching for library files:"
    find /opt/mqm -name "lib*" | head -5
    exit 1
fi

echo "Found MQ installation:"
echo "  Headers: $MQ_INC_DIR"
echo "  Libraries: $MQ_LIB_DIR"

export CGO_CFLAGS="-I$MQ_INC_DIR"
export CGO_LDFLAGS="-L$MQ_LIB_DIR -lmqm_r -Wl,-rpath,$MQ_LIB_DIR"
export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*"

# Enable reproducible builds
export GOFLAGS="-trimpath"

# Try to use git commit timestamp for reproducible builds
if [ -d "$REPO_PATH/.git" ]; then
    cd $REPO_PATH
    export SOURCE_DATE_EPOCH=$(git show -s --format=%ct)
    echo "Using git commit timestamp for reproducible build"
else
    # Use a fixed timestamp as fallback
    export SOURCE_DATE_EPOCH=1672531200
    echo "Using fixed timestamp for reproducible build"
fi

# Verify repository exists
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

# Verify collector exists
if [ ! -d "cmd/$COLLECTOR" ]; then
    echo "Error: Collector '$COLLECTOR' not found in repository."
    echo "Available collectors:"
    ls -la cmd/ 2>/dev/null || echo "No cmd directory found"
    exit 1
fi

# Verify MQ headers are accessible
if [ ! -f "$MQ_INC_DIR/cmqc.h" ]; then
    echo "Error: MQ headers not found at expected location: $MQ_INC_DIR/cmqc.h"
    echo "Available include files:"
    find /opt/mqm -name "*.h" | head -10
    exit 1
fi

echo "Building collector $COLLECTOR with cross-compilation settings:"
echo "  Source: $REPO_PATH"
echo "  Target OS: $GOOS"
echo "  Target Arch: $GOARCH"
echo "  Cross Compiler: $CC"
echo "  CGO_CFLAGS: $CGO_CFLAGS"
echo "  CGO_LDFLAGS: $CGO_LDFLAGS"
echo "  Output: /output/$COLLECTOR"

# Verify Go can see the cross-compiler
if ! command -v $CC &> /dev/null; then
    echo "Error: Cross-compiler $CC not found"
    echo "Available compilers:"
    ls -la /usr/bin/*gcc* 2>/dev/null || echo "No GCC variants found"
    exit 1
fi

# Build the collector with cross-compilation
echo "Starting cross-compilation..."
go build -mod=vendor -trimpath -o /output/$COLLECTOR cmd/$COLLECTOR/*.go

echo "Cross-compilation completed!"

# Verify the binary architecture
echo "Verifying binary architecture:"
file /output/$COLLECTOR

# Check if it's actually s390x
if file /output/$COLLECTOR | grep -q "s390x\|IBM S/390"; then
    echo "✓ Successfully built s390x binary"
else
    echo "⚠ Warning: Binary may not be s390x architecture"
    echo "Full file output:"
    file /output/$COLLECTOR
fi

# Show binary size
echo "Binary size: $(ls -lh /output/$COLLECTOR | awk '{print $5}')"

echo "Build complete. Binary is ready at /output/$COLLECTOR"
