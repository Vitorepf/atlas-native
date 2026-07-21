# WAVE-112 — artifact-sheet-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-112-artifact-sheet-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 1 IDLE · fila vazia · density)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ArtifactSheet.swift` **471 LOC** mistura chrome a11y · empty · list rows ·
  preview pane · load async no mesmo arquivo.
- Residual density pós-viewer-100 / list-093: sheet monólito.
- Agent-optimal: 1 read ≠ 1 intenção.

## Patamar

| Antes | Depois |
|---|---|
| 471 monólito | **3 peels** chrome / host+list / preview |
| Multi-domain surface | Same domain, clear suffixes |

Δ = **densidade do sheet de artefatos** — peels canônicos.

---

## Arquitetura

### Princípios

- Casca only. Zero Core.
- Judgment already pure; only View peels.
- Delivery stays `ArtifactSheetDelivery`.

### Layout alvo

```
ArtifactSheetChrome.swift   a11y · toolbar · empty/unavailable
ArtifactSheet.swift         host · list rows
ArtifactSheetPreview.swift  preview face · load · failure panes
```

### Arquivos (≥5)

1. ArtifactSheet.swift  
2. ArtifactSheetChrome.swift (**new**)  
3. ArtifactSheetPreview.swift (**new**)  
4. CODEMAP  
5. design + compress  

### Densidade

Each peel ≤200. Total LOC moved ~same net.

### Fora de escopo

- Core artifact endpoints  
- Tipografia  
- Preview Judgment rewrite  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Host ArtifactSheet ≤200 LOC.  
- [ ] Chrome peel owns a11y/empty.  
- [ ] Preview peel owns load/pane.  
- [ ] Build green · behavior unchanged.  
- [ ] CODEMAP.  
- [ ] Gates + DEVICE_PENDING.  

## Anti-objetivos

- inventar kinds  
- tipografia  
- fundir Delivery  

## Plano W3

1. Split by domain.  
2. Gates.  
3. CODEMAP.  
4. DONE/compress/regen.  

## Proof

1. `wc -l` three peels ≤200.  
2. `make build` green.  
3. DEVICE_PENDING.

## Council

Density residual after ConversationSurface-111 pattern.

### Why full-bar

- ≥5 files · density product · DoD≥5 · design ≥120  

---

*End WAVE-112 design.*
