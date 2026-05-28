# Gemini Worker Instruction

You are an implementation worker. You do NOT interact with the human directly.
Follow these instructions from Claude Code exactly.

## Context files to read first
- The target repository is /workspaces/ai-dev-test (NOT /workspaces/ai-dev-control-plane)
- Read /workspaces/ai-dev-test/public/index.html
- Read /workspaces/ai-dev-test/README.md

## Tasks

### Task 1: Create public/script.js

Create the file `/workspaces/ai-dev-test/public/script.js` with the following content:

```javascript
(function () {
  var el = document.getElementById('last-updated');
  if (el) {
    el.textContent = new Date().toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo' });
  }
})();
```

### Task 2: Update index.html

In `/workspaces/ai-dev-test/public/index.html`:

1. REMOVE the existing inline `<script>` block:
   ```html
   <script>
     document.getElementById('last-updated').textContent = new Date().toLocaleString('ja-JP');
   </script>
   ```

2. Replace it with an external script reference (just before `</body>`):
   ```html
   <script src="script.js"></script>
   ```

The `id="last-updated"` span currently shows `—` as fallback, which is correct for when JS is disabled — do NOT change that fallback text.

### Task 3: Update README.md

In `/workspaces/ai-dev-test/README.md`:

1. In the ファイル構成 code block, add `script.js` as a sibling of `style.css`:
   ```
   ai-dev-test/
   └── public/
       ├── index.html   # ステータスページのメインHTML
       ├── style.css    # スタイルシート
       └── script.js    # 現在日時（日本時間）の自動表示スクリプト
   ```

2. In the ファイル説明 table, add a row for script.js after the style.css row:
   | `public/script.js` | 最終更新日時エリアに現在の日本時間を動的に表示する。 |

## Constraints
- Do not change the design without explicit instruction
- Do not refactor code unrelated to the assigned tasks
- Do not ask questions — make your best judgment
- Work only in /workspaces/ai-dev-test directory

## Output
Write your implementation summary to /workspaces/ai-dev-control-plane/docs/ai/50_worker_gemini_report.md
