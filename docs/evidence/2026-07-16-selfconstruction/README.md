# V3 Self-Construction evidence

Date: 2026-07-16

## What was unlocked (2026-07-16 night — "Destrava tudo")

1. **`software_company_loop` worker** — Docker `atlas-queue` only listens
   `transcription,default`. A dedicated host worker drains SCL:
   ```bash
   cd ../atlas-server
   php artisan queue:work database --queue=software_company_loop --sleep=1 --tries=1 --timeout=87000
   ```
   Proven: enqueued dry_run job `RUNNING → DONE` (cycle 54 `dry_run_planned`).

2. **Mechanical R2 healer** — AP-786/senior-loop is the wrong tool for
   constitution dead-symbol cleanup (blocks on TDD/BDD capabilities;
   `factory_max` steals selection toward AP-789 forge seeds). New path:
   ```bash
   php artisan atlas:native:constitution-heal \
     --repo=/Users/vitorepf/develop/Atlas/atlas-native \
     --finding-hash=sha1:… [--execute] [--file-findings] --json
   ```
   Proven on real canary `sha1:19fc748292b5ba86400dfaf8800a214d8e4e27e6`:
   `dry_run_planned` → `healed`, file deleted, re-scan canary absent.

3. **start-run passthrough** — `repo_root`, `allow_canonical_worktree_write`,
   `injected_finding` now reach the queued runner/session input.

## Still blocked for full DoD (honest)

| Gap | Exact reason |
|---|---|
| App "O ATLAS MELHOROU O PRÓPRIO APP" receipt | `model.delivered` empty — heal does not fabricate an AP-790 merge ledger row |
| factory_max → canary | Default scope prefers AP-789 forge topology seeds |
| Device screenshots | `passcodeRequired=true` on iPhone |
| Execute on canonical without opt-in | `stopped_canonical_worktree_write_refused` |

## Earlier proof chain

1. Synthetic public dead symbol canary planted in atlas-native.
2. `atlas:native:constitution-scan` detected R2/heal; backlog HTTP showed hash.
3. First dry_run without worker: `requires_worker=true`, `lock.held=false`.
4. Worker unlock + mechanical heal close the plant→scan→cura gap without
   fabricating merge/delivered.

## Native gates

- Healer PHPUnit: 5 tests / 23 asserts green.
- start-run passthrough test green.
- Canary removed after heal; no fabricated delivery.
