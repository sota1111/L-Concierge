FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    ripgrep \
    jq \
    && rm -rf /var/lib/apt/lists/*