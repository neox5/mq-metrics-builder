.PHONY: help clean build-image build build-local
.PHONY: build-image-s390x-cross build-s390x-cross build-local-s390x-cross

IMAGE_NAME=mq-metrics-builder
OUTPUT_DIR?=./bin
LOCAL_REPO_DIR?=../mq-metric-samples
MQ_VERSION?=9.3.0.2
REPO_VERSION?=v5.5.4
COLLECTOR?=mq_otel

help:
	@echo "IBM MQ Metrics Builder"
	@echo ""
	@echo "x86_64 Targets:"
	@echo "  build-image       Build the x86_64 container image"
	@echo "  build             Build MQ collector (x86_64)"
	@echo "  build-local       Build using local repository (x86_64)"
	@echo "  clean             Remove built binaries"
	@echo ""
	@echo "s390x Cross-Compilation Targets:"
	@echo "  build-image-s390x-cross  Build cross-compilation image"
	@echo "  build-s390x-cross        Cross-compile for s390x"
	@echo "  build-local-s390x-cross  Cross-compile using local repo"
	@echo ""
	@echo "Environment variables:"
	@echo "  OUTPUT_DIR        Output directory (default: ./bin)"
	@echo "  LOCAL_REPO_DIR    Local repository path (default: ../mq-metric-samples)"
	@echo "  MQ_VERSION        IBM MQ version for x86_64 (default: 9.3.0.2)"
	@echo "  REPO_VERSION      Repository version (default: v5.5.4)"
	@echo "  COLLECTOR         Collector to build (default: mq_otel)"
	@echo ""
	@echo "Setup for s390x:"
	@echo "  1. Create mq-rpms/ directory with your s390x RPM files:"
	@echo "     • MQSeriesRuntime-U93028-9.3.0-28.s390x.rpm"
	@echo "     • MQSeriesClient-U93028-9.3.0-28.s390x.rpm"
	@echo "     • MQSeriesSDK-U93028-9.3.0-28.s390x.rpm"
	@echo "  2. make build-image-s390x-cross"
	@echo "  3. make build-s390x-cross"

# Original x86_64 targets
build-image:
	podman build -t $(IMAGE_NAME) .

build: 
	mkdir -p $(OUTPUT_DIR)
	podman run --rm -v $(OUTPUT_DIR):/output:Z \
		-e MQ_VERSION='$(MQ_VERSION)' \
		-e REPO_VERSION='$(REPO_VERSION)' \
		-e COLLECTOR='$(COLLECTOR)' \
		$(IMAGE_NAME) build-all

build-local:
	mkdir -p $(OUTPUT_DIR)
	@if [ ! -d "$(LOCAL_REPO_DIR)" ]; then \
		echo "Error: Local repository directory $(LOCAL_REPO_DIR) not found"; \
		exit 1; \
	fi
	podman run --rm -v $(OUTPUT_DIR):/output:Z -v $(LOCAL_REPO_DIR):/src/local-repo:Z \
		-e MQ_VERSION='$(MQ_VERSION)' \
		-e COLLECTOR='$(COLLECTOR)' \
		$(IMAGE_NAME) build-all --local

# s390x cross-compilation targets
build-image-s390x-cross:
	@if [ ! -d "mq-rpms" ]; then \
		echo "Error: mq-rpms directory not found"; \
		echo "Please create mq-rpms/ and copy your s390x RPM files there:"; \
		echo "  • MQSeriesRuntime-U93028-9.3.0-28.s390x.rpm"; \
		echo "  • MQSeriesClient-U93028-9.3.0-28.s390x.rpm"; \
		echo "  • MQSeriesSDK-U93028-9.3.0-28.s390x.rpm"; \
		exit 1; \
	fi
	@echo "Building s390x cross-compilation image..."
	podman build --platform linux/amd64 -f Containerfile.s390x-cross -t $(IMAGE_NAME):s390x-cross .
	@echo "✓ s390x cross-compilation image built successfully"

build-s390x-cross:
	mkdir -p $(OUTPUT_DIR)
	@echo "Cross-compiling $(COLLECTOR) for s390x..."
	podman run --rm -v $(OUTPUT_DIR):/output:Z \
		-e REPO_VERSION='$(REPO_VERSION)' \
		-e COLLECTOR='$(COLLECTOR)' \
		$(IMAGE_NAME):s390x-cross build-all-cross
	@echo "✓ Cross-compilation complete. Check $(OUTPUT_DIR)/ for s390x binary"

build-local-s390x-cross:
	mkdir -p $(OUTPUT_DIR)
	@if [ ! -d "$(LOCAL_REPO_DIR)" ]; then \
		echo "Error: Local repository directory $(LOCAL_REPO_DIR) not found"; \
		exit 1; \
	fi
	@echo "Cross-compiling $(COLLECTOR) for s390x using local repository..."
	podman run --rm -v $(OUTPUT_DIR):/output:Z -v $(LOCAL_REPO_DIR):/src/local-repo:Z \
		-e COLLECTOR='$(COLLECTOR)' \
		$(IMAGE_NAME):s390x-cross build-all-cross --local
	@echo "✓ Cross-compilation complete. Check $(OUTPUT_DIR)/ for s390x binary"

clean:
	@if [ "$(OUTPUT_DIR)" = "/bin" ]; then \
		echo "Warning: Cannot remove system directory /bin. Please specify OUTPUT_DIR=./path/to/output"; \
		exit 1; \
	else \
		rm -rf $(OUTPUT_DIR); \
		echo "✓ Cleaned $(OUTPUT_DIR)"; \
	fi
