#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/ai

PROMPT_FILE="prompts/gemini/implement.md"
REPORT_FILE="docs/ai/50_worker_gemini_report.md"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

echo "== Gemini CLI: implementation worker =="

gemini -p "$(cat "$PROMPT_FILE")" | tee "$REPORT_FILE"
