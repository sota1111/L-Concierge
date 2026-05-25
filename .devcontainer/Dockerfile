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

# Node.js 20
# Gemini CLI は Node.js 20 以上を要求するため、Ubuntu apt の nodejs だけに頼らず NodeSource を使う
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# OpenAI Codex CLI
RUN npm install -g @openai/codex

# Google Gemini CLI
RUN npm install -g @google/gemini-cli