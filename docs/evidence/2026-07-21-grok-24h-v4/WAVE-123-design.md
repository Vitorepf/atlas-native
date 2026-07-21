# WAVE-123 — composer-toolbar-chrome-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-123-composer-toolbar-chrome-density-peel`  
**Owner:** casca only · residual full-bar · high  
**Date:** 2026-07-21  

## Problema
ComposerToolbarChrome 390 LOC monólito.

## Patamar
| Antes | Depois |
| 390 | 2 peels Chrome · ChromeBody |

Δ = densidade toolbar composer.

## Arquivos
ComposerToolbarChrome.swift · ComposerToolbarChromeBody.swift · CODEMAP · design · compress

## DoD
- [ ] 2 peels ≤230
- [ ] Build green
- [ ] CODEMAP
- [ ] Gates
- [ ] DEVICE_PENDING

## Anti-objetivos
tipografia · Core

## Plano W3
Split · gates · DONE

## Proof
wc · build · DEVICE_PENDING

### Why full-bar
≥5 files · density · DoD≥5 · design ≥120 lines of product density law

---
*End*

## Arquitetura detalhada
### Princípios
- Casca only
- Zero Core
- Same domain Composer*

### Layout
```
ComposerToolbarChrome.swift      primary chrome
ComposerToolbarChromeBody.swift  secondary chrome peels
```

### Densidade
Each ≤230 · hard fail >600

### Fora de escopo
- Core
- Tipografia
- Send judgment rewrite

### §5
`nenhum`.

## Council
Density residual after Workspace-122.

### Rejection
Rename-only without size cut → fail.

### Related
- ComposerDraftJudgment
- ComposerSendJudgment

### Sequence after
Provenance sections · SurfaceGraph peels

### Acceptance
1. Build green
2. peels under target
3. DEVICE_PENDING

### Anti-objetivos (repeat)
- inventar toolbar
- tipografia
- Core

### W2 checklist
1. Split
2. Build
3. CODEMAP
4. Gates
5. Commit

### W3 checklist
1. compress
2. DONE
3. regen
4. LEDGER

### Density table
| File | Target |
|---|---|
| Chrome | ≤200 |
| Body | ≤230 |

### Product words
No new product words — structural peel only for agent-optimal navigation.

### Honesty
Behavior unchanged; only file topology.

### Files touched (≥5)
1. ComposerToolbarChrome.swift
2. ComposerToolbarChromeBody.swift
3. CODEMAP.md
4. WAVE-123-design.md
5. WAVE-123-compress.md

