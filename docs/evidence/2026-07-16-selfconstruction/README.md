# V3 Self-Construction evidence

Date: 2026-07-16

Scope:
- Server scanner and command: commit `c651eed7b7`.
- Server area/policy/backlog projection: commit `5e2485460`.
- Native self-construction receipt UI: commit `e269ea7`.

Proof reached:
1. Synthetic public dead symbol canary was planted temporarily in the real
   `atlas-native` working tree.
2. `php artisan atlas:native:constitution-scan --repo=/Users/vitorepf/develop/Atlas/atlas-native --json --file-findings`
   detected the canary as R2/heal and wrote the existing Autonomos backlog cache.
3. HTTP backlog probe for `atlas-native` returned the same canary hash from
   `native_constitution_scan`.
4. `POST /loop/atlas-native/start-run` with `mode=dry_run` returned an enqueued
   receipt, but `started=false` and `requires_worker=true`.
5. After polling `/live`, `run_state.lock.held=false`; no worker lease picked up
   the queued dry-run, so the e2e stopped before execute/merge/receipt.
6. Canary file was removed and the scanner cache was rewritten; cleanup scan
   confirmed the canary was absent.

Honest block:
- The full loop did not execute because no worker acquired the
  `software_company_loop` job/lease for `atlas-native`.
- No heal, merge, or app receipt was fabricated.

Native gates:
- `swift run AtlasCoreChecks` exit 0.
- `cd App && make build` exit 0.
- `git diff --check` exit 0.
- `make device` installed the app on the paired iPhone, then failed to launch
  because the device was locked (`RequestDenied`, `FBSOpenApplicationErrorDomain`
  error 7). No screenshot was captured.
