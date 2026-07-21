# WAVE-004 — arena-runsheet-instrument

**Status:** design approved  
**Wave:** `WAVE-004-arena-runsheet-instrument`  
**Date:** 2026-07-21  

## Problema

Nova Medição (ArenaRunSheet) is a **48-peel fog tower** (~866 LOC) with a real honesty bug: visual says worker *desligado no servidor*; VoiceOver says *ainda não implementado*. Empty engines/suites paths exist but live under 1-string a11y peels that fight fidelity.

## Patamar

One **legible measurement instrument**: form · toggle · submit · receipt with unified truth (visual = spoken), fused structure (~8–10 files, hosts ≤200 / hard ≤400).

## Arquitetura

Fuse map (behavior-preserving):
| After | Absorbs |
|---|---|
| `ArenaRunSheet.swift` | state, body, nav, toolbar, sheet a11y, status, submit, defaults, input |
| `ArenaRunSheet+Form.swift` | suites, engines, governance fields |
| `ArenaRunSheet+Toggle.swift` | toggle row + section helper |
| `ArenaRunSheet+Receipt.swift` | receipt card + copy + worker gap |
| `ArenaRunSheet+Spoken.swift` | all spoken strings (worker copy unified) |

Keep `ArenaFieldChrome`, `ArenaToggleSymbolBounce` as-is if already separate.

## Arquivos

All `App/Atlas/ArenaRunSheet*.swift` (48 → ~5). No Core/Model edits.

## DoD (≥5)

1. `workerImplemented == false`: **same** copy visual + VO: “desligado no servidor — fila aguardando” (never “não implementado”).
2. Zero engines: empty label + submit disabled + spoken engines-empty.
3. Zero installed suites: empty + block.
4. Valid only with suites+engines+arms+ator+motivo; multi-engine multi-POST receipt when count>1.
5. Receipt: hash + enqueued/status + worker gap when false; RM transitions preserved.
6. No `*View`/`*Shell` >400; gates green; `A11yID.arenaRunSheet` remains.

## Anti-objetivos

- Invent worker enabled / fake enqueue success.
- God-file collapse >400.
- Opacity token craft as compress.
- New product area.

## Plano W3

Primary deliverable **is** structural fuse (48→~5). Report `git diff --numstat` honesty; expect **−250…−400 net** (import tax), not forced 800.

## Gates

`./scripts/grok-god-wave-guard.sh` · `swift run AtlasCoreChecks` · `cd App && make build`
