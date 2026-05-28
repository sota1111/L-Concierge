#!/usr/bin/env bash
# バックグラウンドスケジューラー
#
# 動作モード:
#   LINEAR_API_KEY が設定されている場合:
#     CHECK_INTERVAL 秒ごとに Linear の Todo/Backlog/In Progress/Blocked 状態の
#     Issue が更新されているかを確認し、更新があれば run_auto.sh を実行する。
#
#   LINEAR_API_KEY が未設定の場合:
#     フォールバックとして INTERVAL 秒ごとに無条件で run_auto.sh を実行する。
#
# 環境変数:
#   LINEAR_API_KEY   Linear Personal API Token（Settings > API > Personal API keys）
#   CHECK_INTERVAL   Linear ポーリング間隔（秒, デフォルト: 60）
#   INTERVAL         フォールバック用の実行間隔（秒, デフォルト: 3600）

set -euo pipefail

cd "$(dirname "$0")/../.."

# プロジェクトルートの .env を自動読み込み（既存の環境変数は上書きしない）
if [ -f ".env" ]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line//[[:space:]]/}" ]] && continue
    if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
      _key="${BASH_REMATCH[1]}"
      _val="${BASH_REMATCH[2]}"
      _val="${_val%\"}" ; _val="${_val#\"}"
      _val="${_val%\'}" ; _val="${_val#\'}"
      [[ -z "${!_key+x}" ]] && export "$_key=$_val"
    fi
  done < ".env"
  unset _key _val
fi

INTERVAL=${INTERVAL:-3600}
CHECK_INTERVAL=${CHECK_INTERVAL:-60}
LOG_DIR="docs/ai/auto_logs"
SCHEDULER_LOG="${LOG_DIR}/scheduler.log"
PID_FILE="/tmp/l-concierge-scheduler.pid"
LINEAR_STATE_FILE="${LOG_DIR}/linear_state.txt"
LINEAR_API_URL="https://api.linear.app/graphql"

mkdir -p "$LOG_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$SCHEDULER_LOG"
}

# Linear の actionable Issue の最新 updatedAt を取得し、
# 前回取得値から変化があれば 0（更新あり）、なければ 1（変化なし）を返す。
linear_has_updates() {
  if [ -z "${LINEAR_API_KEY:-}" ]; then
    return 2  # API key not set
  fi

  local query
  query='{"query":"{ issues(filter: { state: { type: { in: [\"triage\",\"backlog\",\"unstarted\",\"started\"] } } }, orderBy: updatedAt, first: 1) { nodes { id updatedAt } } }"}'

  local response
  response=$(curl -sf -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: ${LINEAR_API_KEY}" \
    --data "$query" \
    "$LINEAR_API_URL" 2>/dev/null) || {
    log "Linear API request failed"
    return 1
  }

  local latest
  latest=$(echo "$response" | jq -r '.data.issues.nodes[0].updatedAt // empty' 2>/dev/null)

  if [ -z "$latest" ]; then
    log "Linear API returned no issues or unexpected response"
    return 1
  fi

  local cached=""
  if [ -f "$LINEAR_STATE_FILE" ]; then
    cached=$(cat "$LINEAR_STATE_FILE")
  fi

  if [ "$latest" != "$cached" ]; then
    echo "$latest" > "$LINEAR_STATE_FILE"
    log "Linear update detected (updatedAt: ${latest}, prev: ${cached:-none})"
    return 0
  fi

  return 1  # no change
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
      if [ -f "$LINEAR_STATE_FILE" ]; then
        echo "Last Linear updatedAt: $(cat "$LINEAR_STATE_FILE")"
      else
        echo "Last Linear updatedAt: (not yet checked)"
      fi
      if [ -n "${LINEAR_API_KEY:-}" ]; then
        echo "Mode: Linear polling (CHECK_INTERVAL=${CHECK_INTERVAL}s)"
      else
        echo "Mode: Fixed interval fallback (INTERVAL=${INTERVAL}s) — set LINEAR_API_KEY to enable Linear polling"
      fi
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

  _stop_watch() {
    echo ""
    echo "Stopping scheduler (PID: ${SCHED_PID})..."
    kill "$SCHED_PID" 2>/dev/null || true
    kill "$TAIL_PID"  2>/dev/null || true
    exit 0
  }
  trap _stop_watch INT TERM

  tail -f "$SCHEDULER_LOG" &
  TAIL_PID=$!

  wait "$SCHED_PID" 2>/dev/null || true
  kill "$TAIL_PID" 2>/dev/null || true
  exit 0
fi

# --- foreground loop (PIDファイルはここで書く) ---
if [[ "${1:-}" == "--foreground" ]]; then
  echo $$ > "$PID_FILE"

  _SLEEP_PID=""
  _RUN_PID=""
  _MONITOR_PID=""
  _fg_cleanup() {
    kill "$_SLEEP_PID" 2>/dev/null || true
    kill "$_MONITOR_PID" 2>/dev/null || true
    # 実行中の run_auto.sh がある場合は完了を待つ（途中で kill すると Execution error になるため）
    if [[ -n "$_RUN_PID" ]]; then
      log "Scheduler stopping — waiting for current run to complete (PID: ${_RUN_PID})..."
      wait "$_RUN_PID" 2>/dev/null || true
    fi
    rm -f "$PID_FILE"
    log "Scheduler stopped"
    exit 0
  }
  trap '_fg_cleanup' SIGTERM
  trap '' SIGINT

  if [ -n "${LINEAR_API_KEY:-}" ]; then
    log "Scheduler started (PID: $$, mode: Linear polling, check_interval: ${CHECK_INTERVAL}s)"
  else
    log "Scheduler started (PID: $$, mode: fixed interval fallback, interval: ${INTERVAL}s)"
    log "WARNING: LINEAR_API_KEY is not set. Set it to enable Linear-triggered execution."
  fi

  while true; do
    if [ -n "${LINEAR_API_KEY:-}" ]; then
      # Linear ポーリングモード: CHECK_INTERVAL 待機後にチェック・実行
      # 初回はスケジューラー起動時点から、再実行時はタスク完了後からカウント開始
      log "Next check in ${CHECK_INTERVAL}s"
      sleep "$CHECK_INTERVAL" &
      _SLEEP_PID=$!
      wait "$_SLEEP_PID" 2>/dev/null || true

      update_status=0
      linear_has_updates || update_status=$?

      if [ "$update_status" -eq 0 ]; then
        log "--- Run start (Linear update triggered) ---"
        bash scripts/ai/run_auto.sh >> "$SCHEDULER_LOG" 2>&1 &
        _RUN_PID=$!
        # 30秒ごとに進捗ログを出力（watch でオペレーターが実行中かどうか確認できるように）
        ( _p=$_RUN_PID; _e=0
          while kill -0 "$_p" 2>/dev/null; do
            sleep 30; ((_e+=30))
            kill -0 "$_p" 2>/dev/null && log "... run in progress (${_e}s elapsed)"
          done ) &
        _MONITOR_PID=$!
        wait "$_RUN_PID" && _run_exit=0 || _run_exit=$?
        kill "$_MONITOR_PID" 2>/dev/null || true
        wait "$_MONITOR_PID" 2>/dev/null || true
        _MONITOR_PID=""
        _RUN_PID=""
        if [ "$_run_exit" -eq 0 ]; then
          log "--- Run completed successfully ---"
        else
          log "--- Run failed (exit: ${_run_exit}) ---"
        fi
      elif [ "$update_status" -eq 1 ]; then
        log "No Linear updates detected, skipping run."
      else
        log "Linear API key not set (unexpected), skipping."
      fi
    else
      # フォールバック: INTERVAL 待機後に実行
      # 初回はスケジューラー起動時点から、再実行時はタスク完了後からカウント開始
      log "Next run in ${INTERVAL}s"
      sleep "$INTERVAL" &
      _SLEEP_PID=$!
      wait "$_SLEEP_PID" 2>/dev/null || true

      log "--- Run start (fixed interval) ---"
      bash scripts/ai/run_auto.sh >> "$SCHEDULER_LOG" 2>&1 &
      _RUN_PID=$!
      ( _p=$_RUN_PID; _e=0
        while kill -0 "$_p" 2>/dev/null; do
          sleep 30; ((_e+=30))
          kill -0 "$_p" 2>/dev/null && log "... run in progress (${_e}s elapsed)"
        done ) &
      _MONITOR_PID=$!
      wait "$_RUN_PID" && _run_exit=0 || _run_exit=$?
      kill "$_MONITOR_PID" 2>/dev/null || true
      wait "$_MONITOR_PID" 2>/dev/null || true
      _MONITOR_PID=""
      _RUN_PID=""
      if [ "$_run_exit" -eq 0 ]; then
        log "--- Run completed successfully ---"
      else
        log "--- Run failed (exit: ${_run_exit}) ---"
      fi
    fi
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

sleep 1
if [ -f "$PID_FILE" ]; then
  echo "Scheduler started (PID: $(cat "$PID_FILE"))"
else
  echo "Scheduler launched (log: ${SCHEDULER_LOG})"
fi

if [ -n "${LINEAR_API_KEY:-}" ]; then
  echo "Mode: Linear polling (CHECK_INTERVAL=${CHECK_INTERVAL}s)"
else
  echo "Mode: Fixed interval fallback (INTERVAL=${INTERVAL}s)"
  echo "Note: Set LINEAR_API_KEY to enable Linear update detection"
fi
echo "Log: ${SCHEDULER_LOG}"
