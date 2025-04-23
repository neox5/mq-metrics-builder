#!/bin/bash
set -e

MQ_VERSION=${1:-9.3.0.2}
echo "Setting up IBM MQ Client version $MQ_VERSION"

cd /opt
rm -rf /opt/mqm/* || true

echo "Downloading IBM MQ Client version $MQ_VERSION..."
wget --quiet https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqdev/redist/$MQ_VERSION-IBM-MQC-Redist-LinuxX64.tar.gz

echo "Extracting IBM MQ Client..."
tar -xzf $MQ_VERSION-IBM-MQC-Redist-LinuxX64.tar.gz -C /opt/mqm
rm $MQ_VERSION-IBM-MQC-Redist-LinuxX64.tar.gz

echo "MQ Client setup complete."
