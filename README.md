# IBM MQ Metrics Builder

A simplified container-based build system for IBM MQ metrics collectors supporting both x86_64 and s390x architectures.

## Overview

This tool builds IBM MQ metrics collectors from the [mq-metric-samples](https://github.com/ibm-messaging/mq-metric-samples) repository with minimal complexity and clear architecture separation.

**Key Features:**
- One-command builds: `make build-x86` or `make build-s390x`
- Pre-bundled MQ clients (no runtime downloads)
- Clear output separation: `bin/x86_64/` and `bin/s390x/`
- Local repository builds only
- Minimal configuration required

## Prerequisites

- Podman or Docker
- Make
- Internet connection (for initial setup only)

## Initial Setup

### 1. Clone this repository

```bash
git clone <this-repo>
cd mq-metrics-builder
```

### 2. Clone the mq-metric-samples repository

```bash
make setup
```

This clones the mq-metric-samples repository to `../mq-metric-samples`. You can also manually clone it to a different location and specify `REPO_PATH` when building.

### 3. Prepare MQ Client Libraries

The MQ client libraries must be downloaded once and placed in the `mq-clients/` directory.

#### For x86_64

```bash
# Create directory
mkdir -p mq-clients/x86_64

# Download IBM MQ Client
wget https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqdev/redist/9.3.0.2-IBM-MQC-Redist-LinuxX64.tar.gz \
  -O mq-clients/x86_64/9.3.0.2-IBM-MQC-Redist-LinuxX64.tar.gz
```

#### For s390x

```bash
# Create directory
mkdir -p mq-clients/s390x

# Place your s390x RPM files here:
# - MQSeriesRuntime-U93028-9.3.0-28.s390x.rpm
# - MQSeriesClient-U93028-9.3.0-28.s390x.rpm
# - MQSeriesSDK-U93028-9.3.0-28.s390x.rpm

# Example (adjust paths as needed):
cp /path/to/your/MQSeries*.s390x.rpm mq-clients/s390x/
```

## Usage

### Build for x86_64

```bash
# Build default collector (mq_otel)
make build-x86

# Build specific collector
make build-x86 COLLECTOR=mq_prometheus

# Output location
ls bin/x86_64/mq_prometheus
```

### Build for s390x

```bash
# Build default collector (mq_otel)
make build-s390x

# Build specific collector
make build-s390x COLLECTOR=mq_prometheus

# Output location
ls bin/s390x/mq_prometheus
```

### Build for All Architectures

```bash
# Build for both x86_64 and s390x
make build-all

# With specific collector
make build-all COLLECTOR=mq_cloudwatch
```

### Clean Build Artifacts

```bash
make clean
```

## Available Collectors

The following collectors can be built from the mq-metric-samples repository:

- `mq_prometheus` - Prometheus metrics collector
- `mq_otel` - OpenTelemetry collector (default)
- `mq_influx` - InfluxDB collector
- `mq_json` - JSON formatted output
- `mq_cloudwatch` - AWS CloudWatch collector
- `mq_aws` - AWS integration collector

## Configuration Options

| Variable | Default | Description |
|----------|---------|-------------|
| `COLLECTOR` | `mq_otel` | The collector to build |
| `REPO_PATH` | `../mq-metric-samples` | Path to mq-metric-samples repository |

Example with custom options:
```bash
make build-x86 COLLECTOR=mq_influx REPO_PATH=/home/user/mq-metric-samples
```

## Project Structure

```
mq-metrics-builder/
├── Makefile                    # Build automation
├── Containerfile.x86_64        # x86_64 builder
├── Containerfile.s390x         # s390x cross-compiler
├── README.md                   # This file
├── LICENSE
├── .gitignore
├── mq-clients/                 # MQ client installers (you provide)
│   ├── x86_64/
│   │   └── *.tar.gz
│   └── s390x/
│       └── *.rpm
└── bin/                        # Output directory (created by make)
    ├── x86_64/
    └── s390x/
```

## Architecture Details

### x86_64 Builds
- Built on RockyLinux 8 for broad compatibility
- Native compilation
- Uses official IBM MQ redistributable package

### s390x Builds
- Cross-compiled on x86_64 hosts
- Uses Ubuntu 20.04 cross-compilation toolchain
- Requires s390x MQ client RPMs

## Troubleshooting

### "Repository not found" Error
Run `make setup` first or ensure the mq-metric-samples repository exists at the expected path.

### "MQ client files not found" Error
Ensure you've downloaded the required MQ client files and placed them in the correct `mq-clients/` subdirectories.

### Build Failures
Check that the specified collector exists in the mq-metric-samples repository under `cmd/COLLECTOR_NAME`.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
