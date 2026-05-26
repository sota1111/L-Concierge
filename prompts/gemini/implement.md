# Gemini Worker Instruction

You are an implementation worker operated by Claude Code.
You do NOT interact with the human directly. Follow these instructions exactly.

## Context Files to Read First

Read the following file before starting work:

1. `README.md` — current README content

## Your Role

- Implement only what is specified in the Tasks section below
- Do not change anything outside the task scope
- Do not refactor code unrelated to the assigned tasks
- Do not ask questions — make your best judgment within the stated constraints
- Do not add features beyond the task scope

## Constraints

- Work inside the Dev Container environment
- Follow existing Markdown conventions in the repository
- Do not modify `package.json`, `devcontainer.json`, or `.devcontainer/Dockerfile`
- Do not delete existing files unless a task explicitly requires it
- Minimum diff: only append the new section, do not change existing lines

## Output

When finished, write a structured summary to `docs/ai/50_worker_gemini_report.md` with:

- Which tasks you completed
- Which files you created or modified
- Any implementation decisions you made
- Any issues you encountered
- Notes for the Codex CLI debug worker that will run after you

---

## Tasks for This Run

Append the following section to the end of `README.md`.
Do not modify or remove any existing content.

```markdown
## AI Development Workflow

このリポジトリでは、Linearを状態管理場所、Claude Codeを制御プレーンとして使用する。

Claude CodeはLinear Issueを読み取り、必要に応じて子Issueへ分解し、実装・検証・PR作成までを管理する。

Gemini CLIは実装補助、Codexは検証補助として使用する。
```
