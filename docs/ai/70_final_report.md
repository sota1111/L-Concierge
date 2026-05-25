# 70 Final Report

_This file is written by Claude Code after reviewing all worker reports._
_This is the source for the human-facing reply._

---

## Summary
[One-paragraph summary of what was done]

## Result
- [ ] All acceptance criteria met
- [ ] No critical issues remaining

## Gemini CLI Output Review
[Claude Code's assessment of 50_worker_gemini_report.md]

## Codex CLI Output Review
[Claude Code's assessment of 60_worker_codex_report.md]

## What Changed
[List of files changed and what was done]

## Known Limitations
[Any known issues or deferred items]

## Next Steps
[Recommended next actions for the human]

---

## How to Use This Harness

### Quick Start

1. **Describe your request to Claude Code** in plain language.
2. Claude Code will clarify requirements, then populate:
   - `docs/ai/00_project_context.md` — project context
   - `docs/ai/10_plan.md` — plan
   - `docs/ai/20_design.md` — design
   - `docs/ai/30_tasks.md` — task list
   - `docs/ai/40_acceptance.md` — acceptance criteria
3. Claude Code writes the Gemini instruction to `prompts/gemini/implement.md`
   and runs `scripts/ai/run_gemini.sh`.
4. Gemini CLI implements and writes `docs/ai/50_worker_gemini_report.md`.
5. Claude Code writes the Codex instruction to `prompts/codex/debug.md`
   and runs `scripts/ai/run_codex.sh`.
6. Codex CLI debugs/verifies and writes `docs/ai/60_worker_codex_report.md`.
7. Claude Code reviews both reports, writes this file, and replies to the human.

### Scripts

| Script | Purpose |
|--------|---------|
| `scripts/ai/run_gemini.sh` | Run Gemini CLI with the current implement prompt |
| `scripts/ai/run_codex.sh` | Run Codex CLI with the current debug prompt |
| `scripts/ai/verify.sh` | Run all checks (lint / typecheck / test / e2e) independently |

### Example Human Requests to Claude Code

- "このプロジェクトにログイン機能を追加してください"
- "ユーザー一覧ページを実装してください"
- "テストが落ちているので修正してください"
- "現在の実装状況を確認してください"
