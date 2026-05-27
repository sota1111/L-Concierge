#!/usr/bin/env bash
# バックグラウンドスケジューラー
# run_auto.sh を INTERVAL 秒ごとに繰り返し実行する

set -euo pipefail

cd "$(dirname "$0")/../.."

INTERVAL=${INTERVAL:-3600}
LOG_DIR="docs/ai/auto_logs"
SCHEDULER_LOG="${LOG_DIR}/scheduler.log"
PID_FILE="/tmp/l-concierge-scheduler.pid"

mkdir -p "$LOG_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$SCHEDULER_LOG"
}

# --- stop ---
if [[ "${1:-}" == "stop" ]]; then
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID"
      rm -f "$PID_FILE"
      echo "Scheduler stopped (PID: ${PID})"
    else
      echo "Scheduler not running (stale PID file removed)"
      rm -f "$PID_FILE"
    fi
  else
    echo "Scheduler is not running"
  fi
  exit 0
fi

# --- status ---
if [[ "${1:-}" == "status" ]]; then
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      echo "Scheduler is running (PID: ${PID})"
      echo "Log: ${SCHEDULER_LOG}"
    else
      echo "Scheduler not running (stale PID file)"
    fi
  else
    echo "Scheduler is not running"
  fi
  exit 0
fi

# --- watch モード（バックグラウンド起動 + tail -f でリアルタイム表示）---
if [[ "${1:-}" == "--watch" ]]; then
  SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

  # すでに動いていれば止める
  if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
      echo "Stopping existing scheduler (PID: ${OLD_PID})..."
      kill "$OLD_PID"
      sleep 1
    fi
    rm -f "$PID_FILE"
  fi

  # バックグラウンドで起動し $! で確実にPIDを捕捉
  bash "$SCRIPT_PATH" --foreground >> "$SCHEDULER_LOG" 2>&1 &
  SCHED_PID=$!
  sleep 1

  if ! kill -0 "$SCHED_PID" 2>/dev/null; then
    echo "Failed to start scheduler" >&2
    exit 1
  fi

  echo "Scheduler running (PID: ${SCHED_PID}). Watching log."
  echo "Ctrl+C to stop scheduler."
  echo ""

  # Ctrl+C / SIGTERM でスケジューラーごと停止する
  # ※ exec tail -f は使わない → このシェルが生き続け trap が有効になる
  _stop_watch() {
    echo ""
    echo "Stopping scheduler (PID: ${SCHED_PID})..."
    kill "$SCHED_PID" 2>/dev/null || true
    kill "$TAIL_PID"  2>/dev/null || true
    exit 0
  }
  trap _stop_watch INT TERM

  # tail -f でログをリアルタイム表示（バックグラウンドで起動して PID を保持）
  tail -f "$SCHEDULER_LOG" &
  TAIL_PID=$!

  # スケジューラーが自然終了するまで待つ（stop コマンドで kill された場合など）
  wait "$SCHED_PID" 2>/dev/null || true
  kill "$TAIL_PID" 2>/dev/null || true
  exit 0
fi

# --- foreground loop (PIDファイルはここで書く) ---
if [[ "${1:-}" == "--foreground" ]]; then
  echo $$ > "$PID_FILE"

  # SIGTERM: sleep を即座に中断して終了する
  # SIGINT は無視（Ctrl+C は --watch の trap が受け取り SIGTERM に変換する）
  _SLEEP_PID=""
  _fg_cleanup() {
    kill "$_SLEEP_PID" 2>/dev/null || true
    rm -f "$PID_FILE"
    log "Scheduler stopped"
    exit 0
  }
  trap '_fg_cleanup' SIGTERM
  trap '' SIGINT

  log "Scheduler started (PID: $$, interval: ${INTERVAL}s)"

  while true; do
    log "--- Run start ---"
    if bash scripts/ai/run_auto.sh >> "$SCHEDULER_LOG" 2>&1; then
      log "--- Run completed successfully ---"
    else
      log "--- Run failed (exit: $?) ---"
    fi
    log "Next run in ${INTERVAL}s"
    # sleep をバックグラウンドで起動し wait する → SIGTERM で即座に中断可能
    sleep "$INTERVAL" &
    _SLEEP_PID=$!
    wait "$_SLEEP_PID" 2>/dev/null || true
  done
  exit 0
fi

# --- バックグラウンド起動 (PIDファイルチェックはここだけ) ---
if [ -f "$PID_FILE" ]; then
  EXISTING_PID=$(cat "$PID_FILE")
  if kill -0 "$EXISTING_PID" 2>/dev/null; then
    echo "Scheduler is already running (PID: ${EXISTING_PID})" >&2
    exit 1
  fi
  rm -f "$PID_FILE"
fi

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
nohup bash "$SCRIPT_PATH" --foreground >> "$SCHEDULER_LOG" 2>&1 &

# フォアグラウンド側がPIDを書くまで少し待つ
sleep 1
if [ -f "$PID_FILE" ]; then
  echo "Scheduler started (PID: $(cat "$PID_FILE"), interval: ${INTERVAL}s)"
else
  echo "Scheduler launched (log: ${SCHEDULER_LOG})"
fi
echo "Log: ${SCHEDULER_LOG}"
