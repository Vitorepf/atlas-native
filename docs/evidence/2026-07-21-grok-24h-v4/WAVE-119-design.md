# WAVE-119 — conversation-sheets-body-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-119-conversation-sheets-body-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · density residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ConversationSheetsBody.swift` **397 LOC** misturava camera cover ·
  sheets modifier body · trace ref types.
- Residual density conversation sheets.

## Patamar

| Antes | Depois |
|---|---|
| 397 monólito | **2 peels** Body helpers · ComposerSheetsModifier |

Δ = **densidade das sheets do composer**.

---

## Arquitetura

### Layout

```
ConversationSheetsBody.swift                camera cover · early extensions · types
ConversationComposerSheetsModifier.swift    sheets modifier body
```

### Arquivos (≥5)

peels · CODEMAP · design · compress · LEDGER

### Densidade

Each ≤270.

### Fora de escopo

- Core · tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Body peel.  
- [ ] Modifier peel.  
- [ ] Build green.  
- [ ] CODEMAP.  
- [ ] Gates.  
- [ ] DEVICE_PENDING.  

## Anti-objetivos

- inventar sheets  
- tipografia  

## Plano W3

1. Split. 2. Gates. 3. CODEMAP. 4. DONE.

## Proof

1. `wc -l`. 2. Build. 3. DEVICE_PENDING.

## Council

Density residual after CommitRow-118.

### Why full-bar

- ≥5 files · density · DoD≥5 · design ≥120  

---

*End WAVE-119 design.*
