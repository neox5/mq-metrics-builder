# mq-metrics-builder - Simple IBM MQ metrics collector builder

# Configuration
COLLECTOR ?= mq_otel
REPO_PATH ?= ../mq-metric-samples
REPO_VERSION ?= v5.5.4

# MQ versions
MQ_VERSION_X86 := 9.3.0.28
MQ_VERSION_S390X := 9.3.0

# Output directories
BIN_X86 := bin/x86_64
BIN_S390X := bin/s390x

# Container image names
IMAGE_X86 := mq-builder:x86_64
IMAGE_S390X := mq-builder:s390x

.PHONY: all build-x86 build-s390x setup clean help

# Default target shows help
all: help

# Setup - Clone mq-metric-samples if not present
setup:
	@if [ ! -d "$(REPO_PATH)" ]; then \
		echo "Cloning mq-metric-samples to $(REPO_PATH)..."; \
		git clone --depth 1 --branch $(REPO_VERSION) https://github.com/ibm-messaging/mq-metric-samples.git $(REPO_PATH); \
	else \
		echo "Repository already exists at $(REPO_PATH)"; \
	fi

# Check if repo exists
check-repo:
	@if [ ! -d "$(REPO_PATH)" ]; then \
		echo "Error: Repository not found at $(REPO_PATH)"; \
		echo "Run 'make setup' first to clone the repository"; \
		exit 1; \
	fi

# Check if x86_64 MQ package exists
check-x86-mq:
	@if [ ! -f "mq-clients/x86_64/$(MQ_VERSION_X86)-IBM-MQC-Redist-LinuxX64.tar.gz" ]; then \
		echo "Error: x86_64 MQ package not found"; \
		echo "Expected: mq-clients/x86_64/$(MQ_VERSION_X86)-IBM-MQC-Redist-LinuxX64.tar.gz"; \
		echo "Download from: https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqdev/redist/"; \
		exit 1; \
	fi

# Check if s390x MQ package exists
check-s390x-mq:
	@if [ ! -f "mq-clients/s390x/$(MQ_VERSION_S390X)-IBM-MQ-LinuxS390X-FP0028.tar.gz" ]; then \
		echo "Error: s390x MQ package not found"; \
		echo "Expected: mq-clients/s390x/$(MQ_VERSION_S390X)-IBM-MQ-LinuxS390X-FP0028.tar.gz"; \
		exit 1; \
	fi

# Build for x86_64
build-x86: check-repo check-x86-mq
	@mkdir -p $(BIN_X86)
	@echo "Building $(COLLECTOR) for x86_64..."
	@podman build -f Containerfile.x86_64 -t $(IMAGE_X86) .
	@podman run --rm \
		-v $(PWD)/$(BIN_X86):/output:Z \
		-v $(abspath $(REPO_PATH)):/src:Z,ro \
		-e COLLECTOR=$(COLLECTOR) \
		$(IMAGE_X86)

# Build for s390x (cross-compilation)
build-s390x: check-repo check-s390x-mq
	@mkdir -p $(BIN_S390X)
	@echo "Cross-compiling $(COLLECTOR) for s390x..."
	@podman build -f Containerfile.s390x -t $(IMAGE_S390X) .
	@podman run --rm \
		-v $(PWD)/$(BIN_S390X):/output:Z \
		-v $(abspath $(REPO_PATH)):/src:Z,ro \
		-e COLLECTOR=$(COLLECTOR) \
		$(IMAGE_S390X)

# Build all architectures
build-all: build-x86 build-s390x

# Clean build artifacts
clean:
	rm -rf bin/

# Help target
help:
	@echo "IBM MQ Metrics Builder - Simplified Edition"
	@echo ""
	@echo "Current Configuration:"
	@echo "  MQ Version x86_64: $(MQ_VERSION_X86)"
	@echo "  MQ Version s390x:  $(MQ_VERSION_S390X)"
	@echo "  Repository:        $(REPO_VERSION)"
	@echo ""
	@echo "Usage:"
	@echo "  make setup          Clone mq-metric-samples repository"
	@echo "  make build-x86      Build collector for x86_64"
	@echo "  make build-s390x    Build collector for s390x"
	@echo "  make build-all      Build for all architectures"
	@echo "  make clean          Remove all build artifacts"
	@echo ""
	@echo "Options:"
	@echo "  COLLECTOR=name      Collector to build (default: mq_otel)"
	@echo "  REPO_PATH=path      Path to mq-metric-samples (default: ../mq-metric-samples)"
	@echo ""
	@echo "Examples:"
	@echo "  make setup"
	@echo "  make build-x86"
	@echo "  make build-x86 COLLECTOR=mq_prometheus"
	@echo "  make build-all"
