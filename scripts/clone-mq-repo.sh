#!/bin/bash
set -e

REPO_VERSION=${1:-v5.5.4}
echo "Cloning MQ metric samples repository version $REPO_VERSION"

cd /src
rm -rf mq-metric-samples || true

echo "Cloning repository with version $REPO_VERSION..."
git -c advice.detachedHead=false clone --depth 1 --branch $REPO_VERSION https://github.com/ibm-messaging/mq-metric-samples.git

echo "Repository cloned successfully."
