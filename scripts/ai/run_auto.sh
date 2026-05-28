#!/usr/bin/env bash
set -euo pipefail

# Claude Code 自律実行スクリプト
# Linear issue を優先度順に処理する
# 使い方:
#   ./scripts/ai/run_auto.sh              # 通常実行（ログは自動採番）
#   ./scripts/ai/run_auto.sh --dry-run    # プロンプト内容の確認のみ
#
# 多重起動防止:
#   スクリプト経由の起動は同時に1プロセスのみ許可する（flock による排他制御）。
#   ユーザーによる手動起動（VSCode / 直接 terminal）はこのロックを使わないため
#   カウントされない。

cd "$(dirname "$0")/../.."

PROMPT_FILE="prompts/claude/auto_run.md"
LOG_DIR="docs/ai/auto_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/run_${TIMESTAMP}.log"
LOCK_FILE="/tmp/l-concierge-auto-run.lock"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"
mkdir -p docs/ai/linear

if [[ "${1:-}" == "--dry-run" ]]; then
  echo "== Dry run: prompt contents =="
  cat "$PROMPT_FILE"
  exit 0
fi

# ── 多重起動ガード ────────────────────────────────────────────────────────────
# flock -n : ロックが取得できなければ即座に失敗（非ブロッキング）
# ロックはシェルプロセス終了時に OS が自動解放するためクリーンアップ不要
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] run_auto.sh is already running (script-launched). Skipping." >&2
  exit 0
fi
# ─────────────────────────────────────────────────────────────────────────────

echo "== Claude Code Auto Runner =="
echo "Start: ${TIMESTAMP}"
echo "Log: ${LOG_FILE}"
echo ""

# current_debug.log: リアルタイム監視用シンボリックリンク
ln -sf "run_${TIMESTAMP}_debug.log" "${LOG_DIR}/current_debug.log"

claude \
  --dangerously-skip-permissions \
  --debug-file "${LOG_DIR}/run_${TIMESTAMP}_debug.log" \
  -p "$(cat "$PROMPT_FILE")" \
  2>&1 | tee "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "== Finished: $(date +"%Y%m%d_%H%M%S") (exit: ${EXIT_CODE}) =="
exit "$EXIT_CODE"
