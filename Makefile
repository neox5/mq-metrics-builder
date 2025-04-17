.PHONY: build run help clean

IMAGE_NAME=mq-metrics-builder
OUTPUT_DIR=./bin

help:
	@echo "IBM MQ Metrics Builder"
	@echo ""
	@echo "Targets:"
	@echo "  build      Build the container image"
	@echo "  run        Build the MQ collector (with optional environment variables)"
	@echo "  clean      Remove built binaries"
	@echo ""
	@echo "Environment variables for run:"
	@echo "  MQ_VERSION    IBM MQ Client version (default: 9.3.0.2)"
	@echo "  REPO_VERSION  Repository version (default: v5.6.2)"
	@echo "  COLLECTOR     Collector to build (default: mq_prometheus)"
	@echo ""
	@echo "Examples:"
	@echo "  make build                   # Build the container image"
	@echo "  make run                     # Build with default versions"
	@echo "  MQ_VERSION=9.3.0.0 REPO_VERSION=v5.5.0 COLLECTOR=mq_cloudwatch make run  # Build specific version"

build:
	podman build -t $(IMAGE_NAME) .

run: build
	mkdir -p $(OUTPUT_DIR)
	podman run --rm -v $(OUTPUT_DIR):/output:Z $(IMAGE_NAME) build-all $(MQ_VERSION) $(REPO_VERSION) $(COLLECTOR)

clean:
	rm -rf $(OUTPUT_DIR)
