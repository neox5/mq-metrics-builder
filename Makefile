.PHONY: build-image build build-local help clean

IMAGE_NAME=mq-metrics-builder
OUTPUT_DIR?=./bin
LOCAL_REPO_DIR?=../mq-metric-samples

help:
	@echo "IBM MQ Metrics Builder"
	@echo ""
	@echo "Targets:"
	@echo "  build-image Build the container image"
	@echo "  build       Build the MQ collector (with optional environment variables)"
	@echo "  build-local Build using a local copy of the repository"
	@echo "  clean       Remove built binaries"
	@echo ""
	@echo "Environment variables for build:"
	@echo "  OUTPUT_DIR    Output directory for binaries (default: ./bin)"
	@echo "  MQ_VERSION    IBM MQ Client version (default: 9.3.0.2)"
	@echo "  REPO_VERSION  Repository version (default: v5.6.2)"
	@echo "  COLLECTOR     Collector to build (default: mq_prometheus)"
	@echo ""
	@echo "Environment variables for build-local:"
	@echo "  OUTPUT_DIR    Output directory for binaries (default: ./bin)"
	@echo "  MQ_VERSION    IBM MQ Client version (default: 9.3.0.2)"
	@echo "  COLLECTOR     Collector to build (default: mq_prometheus)"
	@echo "  LOCAL_REPO_DIR Path to local repository (default: ./local-repo)"
	@echo ""
	@echo "Examples:"
	@echo "  make build-image               # Build the container image"
	@echo "  make build                     # Build with default versions"
	@echo "  MQ_VERSION=9.3.0.0 REPO_VERSION=v5.5.0 COLLECTOR=mq_cloudwatch make build  # Build specific version"
	@echo "  LOCAL_REPO_DIR=~/git/mq-metric-samples COLLECTOR=mq_influx make build-local # Build from local repo"

build-image:
	podman build -t $(IMAGE_NAME) .

build: 
	mkdir -p $(OUTPUT_DIR)
	podman run --rm -v $(OUTPUT_DIR):/output:Z $(IMAGE_NAME) build-all $(MQ_VERSION) $(REPO_VERSION) $(COLLECTOR)

build-local:
	mkdir -p $(OUTPUT_DIR)
	@if [ ! -d "$(LOCAL_REPO_DIR)" ]; then \
		echo "Error: Local repository directory $(LOCAL_REPO_DIR) not found"; \
		exit 1; \
	fi
	podman run --rm -v $(OUTPUT_DIR):/output:Z -v $(LOCAL_REPO_DIR):/src/local-repo:Z $(IMAGE_NAME) build-all --local $(MQ_VERSION) $(REPO_VERSION) $(COLLECTOR)

clean:
	@if [ "$(OUTPUT_DIR)" = "/output" ]; then \
		echo "Warning: Cannot remove system directory /output. Please specify OUTPUT_DIR=./path/to/output"; \
		exit 1; \
	else \
		rm -rf $(OUTPUT_DIR); \
	fi
