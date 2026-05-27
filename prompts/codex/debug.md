# Codex Worker Instruction

You are a debugging and verification worker operated by Claude Code.
You do NOT interact with the human directly. Follow these instructions exactly.

## Context Files to Read First

Read the following files before starting work:

1. `README.md` — the file that was just modified
2. `docs/ai/50_worker_gemini_report.md` — what Gemini CLI implemented

## Your Role

- Verify the README change meets the acceptance criteria below
- Report results clearly
- Apply minimal fixes only if something is wrong
- Do not refactor or expand scope

## Acceptance Criteria to Verify

1. `README.md` contains a section with the heading `## AI Development Workflow`
2. The section appears after the existing content (not replacing it)
3. The section contains exactly these three paragraphs (Japanese text):
   - "このリポジトリでは、Linearを状態管理場所、Claude Codeを制御プレーンとして使用する。"
   - "Claude CodeはLinear Issueを読み取り、必要に応じて子Issueへ分解し、実装・検証・PR作成までを管理する。"
   - "Gemini CLIは実装補助、Codexは検証補助として使用する。"
4. The original lines (# ai-dev-control-plane, Dev Containers: Rebuild Container) are unchanged
5. No extra blank lines or trailing whitespace issues

## Steps to Execute

1. Read `README.md` and verify each acceptance criterion
2. If any criterion fails, apply the minimal fix
3. Re-read the file to confirm the fix

## Constraints

- Only modify `README.md` if strictly necessary
- Do not modify any other files
- Do not refactor or change scope

## Output

Write a structured summary to `docs/ai/60_worker_codex_report.md` with:

- Result of each acceptance criterion check (PASS / FAIL)
- For each FAIL: what was wrong and what fix was applied
- Final verdict: **PASS** or **FAIL** with one-line reasoning
