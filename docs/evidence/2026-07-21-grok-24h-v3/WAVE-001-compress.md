# WAVE-001 — compress report

**Wave:** `WAVE-001-grafo-soberano-casca`  
**Phase:** W3_compress  
**Base:** `47e82ea0` (W2 implement) → W3 working tree  
**Date:** 2026-07-21  

## ΔLOC (measured)

```
git diff --numstat 47e82ea0
```

| | lines |
|---|---|
| **added** | 415 |
| **deleted** | 844 |
| **net** | **−429** |

Meta design era ≥800 LOC líquidos. Resultado honesto: **−429** via fuse de peels no escopo grafo/radar — sem collapse-host, sem opacity ladder, sem chase de contagem de arquivos como objetivo.

## O que fundiu

| Torre | Antes (≈) | Depois | Notas |
|---|---|---|---|
| AskPill | ~14 peels / 236 LOC | 2 files / ~137 LOC | visual+clear+tap+traits · a11y enum |
| Anchors | 3 peels | 1 file / ~50 LOC | legend + visible + partial |
| Graph filters/chips | ~12 peels | 2 files | worktrees + tabs |
| GraphStateFilter | 6 peels | 1 file / ~49 LOC | label+nodes+target |
| Week + worktree | ~13 peels | 2 files | week section + chip |
| Radar A11y | 7 peels | 1 file / ~67 LOC | phase + shell spoken |

## Host budgets

| File | lines | hard fail >400 |
|---|---|---|
| `AtlasCodeView+AskPill.swift` | 114 | OK |
| `AtlasCodeGraphChrome+Week.swift` | 104 | OK |
| `AtlasCodeGraphChrome+Chips.swift` | 69 | OK |
| `AtlasCodeRadarView+A11y.swift` | 67 | OK |
| All `*View*/*Shell*` | ≤288 residual Arena | OK (guard) |

## Gates

- `./scripts/grok-god-wave-guard.sh` → GUARD OK  
- `swift run AtlasCoreChecks` → verde  
- `make build` / xcodebuild → **BUILD SUCCEEDED**  

## Anti-objetivos respeitados

- Sem god-file >400  
- Sem “collapse into host”  
- Sem token opacity craft  
- Sem edits Core / ConversationModel / Makefile  

## Por que não ≥800

O peel hell do grafo era **over-split** (muitos arquivos de 10–20 linhas), não um monólito de milhares de LOC. Fuse remove boilerplate de import/extension; o teto real de compressão estrutural nesta torre é da ordem de **400–500** LOC sem juntar comportamento de outras superfícies. Ampliar para Arena RunSheet peels seria **outra onda** (WAVE-004), não adjacência honesta do grafo soberano.
