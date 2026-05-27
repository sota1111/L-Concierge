#!/usr/bin/env bash
# cron を使ってスケジュール実行をセットアップする
# devcontainer 再起動のたびに実行が必要

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
CRON_SCHEDULE="${CRON_SCHEDULE:-0 * * * *}"   # デフォルト毎時0分
CRON_LOG="${REPO_DIR}/docs/ai/auto_logs/cron.log"

mkdir -p "${REPO_DIR}/docs/ai/auto_logs"

# cron がなければインストール
if ! command -v cron &>/dev/null; then
  echo "Installing cron..."
  sudo apt-get install -y cron
fi

# cron サービス起動
if ! service cron status &>/dev/null; then
  echo "Starting cron service..."
  sudo service cron start
fi

# 既存エントリを削除して追加
CRON_CMD="${CRON_SCHEDULE} cd ${REPO_DIR} && bash scripts/ai/run_auto.sh >> ${CRON_LOG} 2>&1"
(crontab -l 2>/dev/null | grep -v "run_auto.sh"; echo "$CRON_CMD") | crontab -

echo "Cron job registered:"
crontab -l | grep run_auto
echo ""
echo "Log: ${CRON_LOG}"
echo ""
echo "To remove: crontab -l | grep -v run_auto.sh | crontab -"
