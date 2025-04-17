# IBM MQ Metrics Builder

This repository contains the necessary files to build IBM MQ metrics collectors using Podman or Buildah. The build process is designed to create binaries with the correct glibc version compatibility for RHEL/CentOS systems.

## Prerequisites

- Podman or Buildah installed on your system
- Internet connection to download dependencies

## Repository Structure

```
.
├── Dockerfile                  # Container image definition
├── Makefile                    # Automation for common tasks
├── README.md                   # This readme file
└── scripts/                    # Build scripts
    ├── build-all.sh            # Script to run all build steps
    ├── build-mq-collector.sh   # Script to build the collector
    ├── clone-mq-repo.sh        # Script to clone the repository
    ├── help.sh                 # Help information
    └── setup-mq-client.sh      # Script to set up MQ client
```

## Getting Started

### Build the Container Image

```bash
make build
```

This creates a container image with:
- A compatible build environment (Rocky Linux 8)
- Go compiler
- Build tools
- Scripts to download and install IBM MQ Client
- Scripts to clone and build mq-metric-samples

### Build with Default Versions

```bash
make run
```

This will:
1. Set up IBM MQ Client 9.3.0.2
2. Clone mq-metric-samples version v5.6.2
3. Build the mq_prometheus collector
4. Place the binary in the ./bin directory

### Build with Specific Versions

You can specify different versions using environment variables:

```bash
MQ_VERSION=9.3.0.0 REPO_VERSION=v5.5.0 COLLECTOR=mq_cloudwatch make run
```

### Using Directly with Podman

If you prefer running the container directly with Podman:

```bash
# Create a persistent container
podman create --name mq-builder -v $(pwd)/bin:/output:Z mq-metrics-builder

# Run individual steps
podman start -a mq-builder bash -c "setup-mq-client 9.3.0.2"
podman start -a mq-builder bash -c "clone-mq-repo v5.6.2"
podman start -a mq-builder bash -c "build-mq-collector mq_prometheus"

# Clean up when finished
podman rm mq-builder
```

## Available Collectors

The mq-metric-samples repository includes several collectors:

- `mq_prometheus` - Prometheus collector
- `mq_influx` - InfluxDB collector
- `mq_json` - JSON formatted output collector
- `mq_cloudwatch` - AWS CloudWatch collector
- `mq_otel` - OpenTelemetry collector
- `dspmqrtj` - Route tracer in JSON format

To build any of these, specify the collector name when running the build commands:

```bash
COLLECTOR=mq_cloudwatch make run
```

## Troubleshooting

### Common Issues

1. **Permission Errors on Mounted Volumes**
   - Solution: Add the `:Z` suffix to volume mounts or run with `--privileged`

2. **Network Connectivity Issues**
   - Solution: Check proxy settings and ensure the build environment has internet access

3. **Incompatible Binary**
   - Solution: The build environment is specifically configured for RHEL/CentOS compatibility (glibc 2.28)
   
4. **Wrong glibc Version**
   - Problem: Binary fails with error about missing GLIBC_x.xx
   - Solution: This builder specifically targets compatibility with systems using glibc 2.28

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- IBM for the [mq-metric-samples](https://github.com/ibm-messaging/mq-metric-samples) project
- The Rocky Linux team for providing a compatible build environment
