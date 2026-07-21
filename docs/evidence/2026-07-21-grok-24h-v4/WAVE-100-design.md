# WAVE-100 — artifact-viewer-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-100-artifact-viewer-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ArtifactPreviewJudgment` (WAVE-058) tem face + pack, mas **ainda
  chama** `ArtifactViewerA11y` para `spokenTooLarge`, `spokenPreview` e
  leave spoken kind soup no Chrome.
- `ArtifactViewerZoomA11y` e `spokenFicha` vivem em peels laterais —
  três dialetos para o mesmo órgão de preview.
- Residual pós-list-093 / preview-058: **viewer chrome incompleto**.

## Patamar

| Antes | Depois |
|---|---|
| Judgment → A11y soup | **Judgment only** spoken family |
| Zoom A11y local | Judgment zoom spoken/hint/action |
| Ficha A11y local | Judgment spokenFicha |
| Pack face only | pack + kind honesty already; pure helpers |

Δ = **soberania total do viewer de artefato** — uma língua face/spoken/pack.

---

## Arquitetura

### Princípios

- Casca only. Item/kind/bytes from published artifact metadata.
- `ArtifactViewer.byteLabel` / `kindLabel` stay as presentation format
  helpers (or move into Judgment if pure) — no Core.
- Zero tipografia.

### Fluxo

```
item · content · scale?
  → ArtifactPreviewJudgment
       spokenPreview · spokenTooLarge · spokenDecodeFailure
       spokenFicha · spokenZoomImage · zoomHint · resetAction
  → PreviewChrome · Zoom · FileFicha wire
  → delete ArtifactViewerA11y + ArtifactViewerZoomA11y
```

### Arquivos (≥5)

1. `ArtifactPreviewJudgment.swift` (extend)
2. `ArtifactPreviewChrome.swift` (wire + delete A11y)
3. `ArtifactPreviewZoom.swift` (wire + delete ZoomA11y)
4. `ArtifactFileFicha.swift` (wire)
5. `App/Atlas/CODEMAP.md`
6. design + compress evidence

### Densidade

Judgment +120–200 · Chrome thinner · Zoom thinner · delete ~80 LOC soup

### Fora de escopo

- Core artifact decode  
- New preview kinds  
- Tipografia / glass  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] spokenPreview / spokenTooLarge / spokenDecodeFailure on Judgment.
- [ ] spokenFicha on Judgment; FileFicha Judgment-only.
- [ ] Zoom spokenImage + zoomHint + resetAction on Judgment.
- [ ] Delete ArtifactViewerA11y enum soup from Chrome.
- [ ] Delete ArtifactViewerZoomA11y enum.
- [ ] ArtifactPreviewFace.spokenFace no longer calls A11y.
- [ ] Gates + CODEMAP + DEVICE_PENDING.

## Anti-objetivos

- inventar kind labels  
- tipografia  
- fundir TraceEvidence com viewer  

## Plano W3

1. Extend ArtifactPreviewJudgment with full spoken family.  
2. Rewire Chrome / Zoom / FileFicha.  
3. Delete both A11y enums.  
4. CODEMAP organ line.  
5. ~5–7 files · ~200–400 LOC net density.

## Proof

1. Image preview VO ≡ kind + name + size.  
2. Too-large face spoken ≡ Judgment constant path.  
3. Zoom scale 2.0 → "ampliada 200 por cento".  
4. Decode failure spoken without A11y type.  
5. DEVICE_PENDING operator screenshot path.

## Council

Residual after reason-098 + governance-099 + IDLE 23–24 deletes.
Same density pattern: pure Judgment organ, views wire only.

### Rejection criteria

If B only renames A11y without deleting enums + pack face purity → fail.

### Density notes (agent-optimal)

| File | Before | Target |
|---|---|---|
| ArtifactPreviewJudgment | ~115 | ~250–300 |
| ArtifactPreviewChrome | ~206 | −A11y block |
| ArtifactPreviewZoom | ~60+ | −enum |
| ArtifactFileFicha | ~37 | 1 call site |

### Related organs (do not reopen)

- ArtifactListJudgment (list silence)  
- ArtifactJudgment (turn delivery)  
- TraceEvidenceJudgment (loading chrome)

### Operator honesty

- Never invent byte size  
- Never invent sha prefix beyond published  
- Mute kind → "arquivo" fallback only via existing kindLabel

### W2 checklist

1. Judgment spoken family complete  
2. Face.spokenFace self-contained  
3. Zoom pack optional scale fact if needed  
4. Call sites rewired  
5. Enums deleted  
6. CODEMAP  
7. Gates green  

### W3 checklist

1. compress.md truth  
2. DONE 100  
3. regen-queue  
4. LEDGER waves_completed=95 · phase idle  
5. commit feat(ui)

### Risk

- `ArtifactViewer.byteLabel` used by many call sites — keep on Viewer
  as format helper (not A11y).  
- `@MainActor` not required for pure strings.

### Non-goals again

- PDF renderer  
- new download path  
- Core max-bytes change  

### Acceptance quotes (spoken)

- "preview de imagem report.png, 24 KB"  
- "relatorio.md, grande demais para visualizar aqui, 3,2 MB"  
- "imagem chart.png, ampliada 200 por cento"  
- "imagem shot.png não pôde ser decodificada, 12 KB"

### Mapping table

| Old | New |
|---|---|
| ArtifactViewerA11y.spokenPreview | ArtifactPreviewJudgment.spokenPreview |
| ArtifactViewerA11y.spokenTooLarge | ArtifactPreviewJudgment.spokenTooLarge |
| ArtifactViewerA11y.spokenDecodeFailure | ArtifactPreviewJudgment.spokenDecodeFailure |
| ArtifactViewerA11y.spokenFicha | ArtifactPreviewJudgment.spokenFicha |
| ArtifactViewerZoomA11y.spokenImage | ArtifactPreviewJudgment.spokenZoomImage |
| ArtifactViewerZoomA11y.zoomHint | ArtifactPreviewJudgment.zoomHint |
| ArtifactViewerZoomA11y.resetAction | ArtifactPreviewJudgment.zoomResetAction |

### Why full-bar (not IDLE)

- ≥5 files across Judgment + 3 views + CODEMAP + evidence  
- Deletes two A11y dialects and completes WAVE-058 sovereignty  
- Design ≥120 lines · DoD ≥5 · product patamar for artifact operator  

### Sequence after ship

1. DONE + compress + regen  
2. Max 1–2 IDLE if residual A11y  
3. Else wait A or next residual full-bar (CommitRow A11y / TurnPresence)

---

*End WAVE-100 design.*
