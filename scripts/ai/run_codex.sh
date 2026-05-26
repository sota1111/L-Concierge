#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/ai

PROMPT_FILE="prompts/codex/debug.md"
REPORT_FILE="docs/ai/60_worker_codex_report.md"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

echo "== Codex CLI: debugging worker =="

codex --sandbox danger-full-access exec "$(cat "$PROMPT_FILE")" | tee "$REPORT_FILE"
