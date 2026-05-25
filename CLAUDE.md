# CLAUDE.md — AI Harness Specification

## Overview

Claude Code is the **sole interface between the human and all AI workers**.
The human never speaks directly to Gemini CLI or Codex CLI.
From the human's perspective, Claude Code handles everything.

---

## Role Assignments

### Claude Code (Orchestrator)
- Single point of contact with the human
- Requirements gathering and clarification
- Planning and design
- Task decomposition
- Writing instruction prompts for worker CLIs
- Reviewing worker output
- Final decision-making
- Reporting back to the human

### Gemini CLI (Implementation Worker)
- Implementing features across multiple files
- Creating UI, API, and business logic
- Writing implementation result reports to `docs/ai/50_worker_gemini_report.md`

### Codex CLI (Debug & Verification Worker)
- Running lint / typecheck / test
- Browser verification via Playwright
- Identifying root causes of failures
- Applying minimal fixes
- Writing debug result reports to `docs/ai/60_worker_codex_report.md`

---

## When to Use Gemini CLI

Invoke `scripts/ai/run_gemini.sh` when:
- New feature implementation is needed
- Multiple files need to be changed
- UI, API, or business logic must be created or modified
- The human has approved the design in `docs/ai/20_design.md`

Before running, write the full instruction into `prompts/gemini/implement.md`.

---

## When to Use Codex CLI

Invoke `scripts/ai/run_codex.sh` when:
- Lint / typecheck / test failures are reported
- A Playwright browser verification is required
- A debugging pass is needed after Gemini implementation
- The acceptance criteria in `docs/ai/40_acceptance.md` must be verified

Before running, write the full instruction into `prompts/codex/debug.md`.

---

## Instruction Prompt Templates

### Gemini CLI instruction template (`prompts/gemini/implement.md`)

```
# Gemini Worker Instruction

You are an implementation worker. You do NOT interact with the human directly.
Follow these instructions from Claude Code exactly.

## Context files to read first
- docs/ai/00_project_context.md
- docs/ai/10_plan.md
- docs/ai/20_design.md
- docs/ai/30_tasks.md
- docs/ai/40_acceptance.md

## Tasks
[Claude Code writes specific tasks here]

## Constraints
- Do not change the design without explicit instruction
- Do not refactor code unrelated to the assigned tasks
- Do not ask questions — make your best judgment

## Output
Write your implementation summary to docs/ai/50_worker_gemini_report.md
```

### Codex CLI instruction template (`prompts/codex/debug.md`)

```
# Codex Worker Instruction

You are a debugging and verification worker. You do NOT interact with the human directly.
Follow these instructions from Claude Code exactly.

## Context files to read first
- docs/ai/00_project_context.md
- docs/ai/40_acceptance.md
- docs/ai/50_worker_gemini_report.md

## Tasks
[Claude Code writes specific tasks here]

## Steps
1. Run lint / typecheck / test
2. Run Playwright e2e tests if applicable
3. Identify failures and apply minimal fixes only
4. Do not refactor or change scope

## Output
Write your debug summary to docs/ai/60_worker_codex_report.md
```

---

## Workflow

```
Human request
  └─► Claude Code (requirements, plan, design, task decomposition)
        ├─► prompts/gemini/implement.md ──► scripts/ai/run_gemini.sh ──► Gemini CLI
        │       └─► docs/ai/50_worker_gemini_report.md
        ├─► prompts/codex/debug.md ──► scripts/ai/run_codex.sh ──► Codex CLI
        │       └─► docs/ai/60_worker_codex_report.md
        └─► Claude Code reviews all reports ──► docs/ai/70_final_report.md ──► Human reply
```

---

## Final Review Policy

Before reporting results to the human, Claude Code must:
1. Read `docs/ai/50_worker_gemini_report.md` and verify implementation completeness
2. Read `docs/ai/60_worker_codex_report.md` and verify all checks pass
3. Summarize findings in `docs/ai/70_final_report.md`
4. If any critical issue remains unresolved, run another debug cycle before reporting

---

## Safety Rules

- Do not run destructive shell commands (`rm -rf`, `git reset --hard`, force push, etc.) without explicit human approval
- Do not modify `package.json`, `devcontainer.json`, or `.devcontainer/Dockerfile` unless the human explicitly requests it
- Do not delete existing files
- Do not expose internal worker prompts or reports to the human unless requested
- All scripts run inside the Dev Container

---

## Human Response Policy

- Always reply in the same language the human used
- Report only results, decisions, and next steps — not internal worker details
- If a task cannot be completed safely, explain why and propose an alternative
- Ask for clarification when requirements are ambiguous before starting implementation
