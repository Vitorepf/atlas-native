# Execution Composer Queue Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore the composer during live execution and add a functional Cursor-style follow-up queue without removing any existing proposal screen.

**Architecture:** Keep the proposal self-contained in `index.html`. Add a tiny pure queue model between named script markers so a Node test can execute the same logic used by the UI, then bind it to an Ink & Brass composer, conditional queue badge, and bottom sheet.

**Tech Stack:** HTML, CSS, browser JavaScript, Node.js `node:test` and `node:vm`.

## Global Constraints

- Preserve every existing section and all nine session screens.
- Sending during execution queues by default.
- Interruption is explicit through `Enviar agora` or `Parar`.
- The rejected brainstorming layout is not a visual reference.
- The prototype must remain one standalone HTML file.
- No new dependency.

---

### Task 1: Add and prove the execution follow-up queue

**Files:**
- Create: `scripts/codex-execution-queue.test.mjs`
- Modify: `docs/proposals/codex-execucao-viva/index.html:37-61`

**Interfaces:**
- Consumes: existing `.phone`, `.livebar`, timeline, and Ink & Brass tokens.
- Produces: `createQueueModel()`, `renderExecutionDock()`, `openQueueSheet()`, `closeQueueSheet()`, `queueCurrentDraft()`, `promoteQueuedMessage(id)`, and `removeQueuedMessage(id)`.

- [x] **Step 1: Write the failing behavioral test**

```js
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";

const html = fs.readFileSync("docs/proposals/codex-execucao-viva/index.html", "utf8");
const source = html.match(/\/\* QUEUE_STATE_START \*\/([\s\S]*?)\/\* QUEUE_STATE_END \*\//)?.[1];
assert.ok(source, "queue state source must exist inside the standalone proposal");
const context = {};
vm.createContext(context);
vm.runInContext(`${source};globalThis.createQueueModel=createQueueModel`, context);

test("send while executing appends and preserves FIFO order", () => {
  const queue = context.createQueueModel();
  queue.enqueue("primeira");
  queue.enqueue("segunda");
  assert.deepEqual(Array.from(queue.items(), item => item.text), ["primeira", "segunda"]);
});

test("empty messages are ignored", () => {
  const queue = context.createQueueModel();
  assert.equal(queue.enqueue("   "), null);
  assert.equal(queue.count(), 0);
});

test("promote and remove affect only the selected item", () => {
  const queue = context.createQueueModel();
  const first = queue.enqueue("primeira");
  const second = queue.enqueue("segunda");
  assert.equal(queue.promote(second.id).text, "segunda");
  assert.deepEqual(Array.from(queue.items(), item => item.text), ["primeira"]);
  assert.equal(queue.remove(first.id), true);
  assert.equal(queue.count(), 0);
});

test("all existing proposal surfaces remain present", () => {
  for (const label of ["1. Dentro do app", "2. Fora do app", "3. Estados terminais e recuperação", "Nove situações", "09 · Revisão entre agentes"]) {
    assert.ok(html.includes(label), `missing existing surface: ${label}`);
  }
});
```

- [x] **Step 2: Run the test and verify RED**

Run: `node --test scripts/codex-execution-queue.test.mjs`

Expected: FAIL with `queue state source must exist inside the standalone proposal`.

- [x] **Step 3: Implement the minimal queue model and Atlas UI**

Add a queue model inside the named markers. Replace only the execution phone's `.livebar` with `.execution-dock`, containing the compact execution strip, conditional `Na fila N`, input, attachment button, microphone button, submit button, and stop button. Add a bottom sheet within the same phone. Bind submit, badge, close, promote, remove, and stop actions. Use `textContent` for user messages and never interpolate them into HTML.

- [x] **Step 4: Run the behavioral test and verify GREEN**

Run: `node --test scripts/codex-execution-queue.test.mjs`

Expected: 5 tests passed, 0 failed (including the strengthened all-screens and complete-workflow guards).

- [ ] **Step 5: Run proposal integrity checks**

Run:

```bash
node --check <(sed -n '/<script>/,/<\/script>/p' docs/proposals/codex-execucao-viva/index.html | sed '1d;$d')
git diff --check -- docs/proposals/codex-execucao-viva/index.html scripts/codex-execution-queue.test.mjs
```

Expected: both commands exit 0 with no output.

- [ ] **Step 6: Commit the scoped implementation**

```bash
git add docs/proposals/codex-execucao-viva/index.html scripts/codex-execution-queue.test.mjs docs/superpowers/plans/2026-07-13-execution-composer-queue.md
git commit -m "feat(proposal): restore composer with follow-up queue"
```
