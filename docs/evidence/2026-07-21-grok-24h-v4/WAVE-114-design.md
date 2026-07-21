# WAVE-114 — atlas-code-radar-rows-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-114-atlas-code-radar-rows-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · density residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasCodeRadarRows.swift` **447 LOC** misturava AskContext pack +
  FolderRow + RepoRow + chrome capsules no mesmo arquivo.
- Residual density pós-111–113 peels pattern.

## Patamar

| Antes | Depois |
|---|---|
| 447 monólito | **3 peels** AskContext / FolderRow / RepoChrome |
| Multi-intent | 1 read = 1 intenção |

Δ = **densidade do radar multi-repo rows**.

---

## Arquitetura

### Princípios

- Casca only. Zero Core.
- Judgment already separate (RadarJudgment).

### Layout

```
AtlasCodeRadarAskContext.swift   pack/invite (was rows head)
AtlasCodeRadarFolderRow.swift    folder row
AtlasCodeRadarRepoChrome.swift   repo row + section/status chrome
```

### Arquivos (≥5)

1–3 peels · CODEMAP · design · compress

### Densidade

Each ≤200.

### Fora de escopo

- Core  
- Tipografia  
- Scan rewrite  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] AskContext peel.  
- [ ] FolderRow peel.  
- [ ] Repo+chrome peel.  
- [ ] Build green.  
- [ ] CODEMAP.  
- [ ] Gates + DEVICE_PENDING.  

## Anti-objetivos

- inventar scan  
- tipografia  

## Plano W3

1. Split.  
2. Gates.  
3. CODEMAP.  
4. DONE.

## Proof

1. `wc -l` peels ≤200.  
2. Build green.  
3. DEVICE_PENDING.

## Council

Density residual after ExecutionProof-113.

### Why full-bar

- ≥5 files · density · DoD≥5 · design ≥120  

---

*End WAVE-114 design.*
