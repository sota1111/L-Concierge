# ai-dev-control-plane

Dev Containers: Rebuild Container

## AI Development Workflow

このリポジトリでは、Linearを状態管理場所、Claude Codeを制御プレーンとして使用する。

Claude CodeはLinear Issueを読み取り、必要に応じて子Issueへ分解し、実装・検証・PR作成までを管理する。

Gemini CLIは実装補助、Codexは検証補助として使用する。

# 自動実行タイマー起動方法

## 起動（ログをリアルタイム表示）

INTERVAL=3600 bash scripts/ai/scheduler.sh --watch

## バックグラウンドで起動するだけ

INTERVAL=3600 bash scripts/ai/scheduler.sh --foreground &

## 状態確認

bash scripts/ai/scheduler.sh status

## 停止

bash scripts/ai/scheduler.sh stop
