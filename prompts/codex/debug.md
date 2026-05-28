# Codex Worker Instruction

You are a debugging and verification worker. You do NOT interact with the human directly.
Follow these instructions from Claude Code exactly.

## Context files to read first
- /workspaces/ai-dev-test/public/index.html
- /workspaces/ai-dev-test/public/script.js
- /workspaces/ai-dev-test/README.md
- /workspaces/ai-dev-control-plane/docs/ai/50_worker_gemini_report.md

## Tasks

Verify the following acceptance criteria for SOT-18 (JavaScript追加タスク):

### Check 1: script.js exists
- Confirm `/workspaces/ai-dev-test/public/script.js` exists
- Confirm it contains logic to get current date/time in Japan time (Asia/Tokyo timezone)
- Confirm it uses `getElementById('last-updated')` to update the element

### Check 2: index.html references script.js externally
- Confirm `/workspaces/ai-dev-test/public/index.html` has `<script src="script.js"></script>`
- Confirm there is NO inline `<script>` block with date logic
- Confirm the fallback `id="last-updated"` element still shows `—` as default text (JS disabled graceful degradation)
- Confirm `<link rel="stylesheet" href="style.css">` is still present (CSS not broken)

### Check 3: README.md updated
- Confirm `/workspaces/ai-dev-test/README.md` mentions `script.js` in the ファイル構成 section
- Confirm README.md has a description row for `public/script.js` in the ファイル説明 table

## Steps
1. Read each file listed above
2. Check each acceptance criterion
3. If any criterion fails, apply the minimal fix directly to the file
4. Do not refactor or change scope
5. Report results clearly

## Output
Write your debug summary to /workspaces/ai-dev-control-plane/docs/ai/60_worker_codex_report.md with:
- Result of each check (PASS / FAIL)
- For each FAIL: what was wrong and what fix was applied
- Final verdict: PASS or FAIL
