FROM rockylinux:8

# Install development tools including git
RUN dnf install -y wget make gcc git

# Install Go
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz && \
    rm go1.21.5.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# Set up directories
RUN mkdir -p /src /output /opt/mqm

# Copy scripts
COPY scripts/setup-mq-client.sh /usr/local/bin/setup-mq-client
COPY scripts/clone-mq-repo.sh /usr/local/bin/clone-mq-repo
COPY scripts/build-mq-collector.sh /usr/local/bin/build-mq-collector
COPY scripts/build-all.sh /usr/local/bin/build-all
COPY scripts/help.sh /usr/local/bin/help.sh

# Make scripts executable
RUN chmod +x /usr/local/bin/setup-mq-client && \
    chmod +x /usr/local/bin/clone-mq-repo && \
    chmod +x /usr/local/bin/build-mq-collector && \
    chmod +x /usr/local/bin/build-all && \
    chmod +x /usr/local/bin/help.sh

WORKDIR /src

# Default command shows help information
ENTRYPOINT ["/bin/bash"]
CMD ["/usr/local/bin/help.sh"]
