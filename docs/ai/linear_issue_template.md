# Linear Issue Template

## Title

```text
[IMPLEMENT] <短いタスク名>
```

## Description

```markdown
## Goal

何を達成したいかを書く。

## Background

なぜ必要かを書く。

## Scope

- 対応すること
- 対応すること

## Out of Scope

- 今回は対応しないこと

## Acceptance Criteria

- [ ] ...
- [ ] ...
- [ ] ...

## Verification

- [ ] lint
- [ ] typecheck
- [ ] test
- [ ] browser check, if needed

## Notes

- ...
```

## Example

```markdown
## Goal

宅配ボックス一覧画面を作成する。

## Background

MVP では、宅配ボックスの状態を管理者が一覧で確認できる必要がある。

## Scope

- 宅配ボックス一覧画面
- 空き / 使用中 / 異常 の表示
- 最終更新時刻の表示

## Out of Scope

- 実センサー連携
- 通知機能
- 管理者認証

## Acceptance Criteria

- [ ] 一覧画面が表示される
- [ ] 各ボックスの状態が表示される
- [ ] 最終更新時刻が表示される
- [ ] 画面表示確認が完了している

## Verification

- [ ] npm run lint
- [ ] npm run typecheck
- [ ] npm test
- [ ] npm run e2e
```
