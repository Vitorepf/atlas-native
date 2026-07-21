# WAVE-089 — search-list-row-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-089-search-list-row-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia · residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- WAVE-071 owns **screen** face (loading/offline/empty/results).
  O **órgão editorial da lista** (field spoken · RECENTES caption ·
  results caption · row spoken · miss headline) ainda é dialeto em
  `SearchSurface` (`spokenFieldLabel`, `SearchThreadLink.spokenLabel`,
  captions, `SearchMissEmpty`).
- Rank live-first já via `WorkspaceThreadJudgment`; row spoken inventa
  “executando” / “novo” localmente sem face product word exclusiva de
  lista/row.
- Pack screen existe; falta `search_list_face` / row honesty no organ.

## Patamar

| Antes | Depois |
|---|---|
| Captions/row soup | **SearchListJudgment** faces |
| Field spoken local | Judgment spokenField |
| Miss headline View | Judgment missHeadline |
| Row parts dialect | rowFace + spokenRow |
| Pack screen only | pack list + row anchors optional |

Δ = **soberania da lista de busca** — captions/rows falam a face, não
string solta.

---

## Arquitetura

### Princípios

- Casca only. Threads already session-loaded (zero invent results).
- WAVE-071 pétreo: screen face stays; this is list/row **inside** results.
- WAVE-032 rank stays WorkspaceThreadJudgment.
- Honesty: never invent message counts; miss caps at loaded 100.

### Fluxo

```
query + face(screen) + threads[]
  → SearchListJudgment
       listFace recent|results|miss
       spokenField · spokenRecentCaption · spokenResultsCaption
       spokenRow(thread) · missHeadline
  → SearchSurface peels wire
  → optional pack list facts
```

### Tipos

| Nome | Papel |
|---|---|
| `SearchListJudgment` | list face · captions · row · miss · pack |
| SearchSurface | wire |
| SearchScreenJudgment | may append list pack from list organ |
| CODEMAP | |

### Arquivos

- `SearchListJudgment.swift` (**new**)
- `SearchSurface.swift`
- `SearchScreenJudgment.swift` (optional pack compose)
- CODEMAP
- design/compress

### Densidade

Judgment 150–350 · Surface thinner

### Fora de escopo

- Core search API  
- New remote search  
- ThreadRow redesign  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] list_face product words (recent / results / miss).
- [ ] Field + captions spoken from Judgment.
- [ ] Row spoken from Judgment (running/new honesty via WorkspaceThread + Model).
- [ ] Miss headline honesty (100-cap).
- [ ] Pack search_list_face facts.
- [ ] Gates + CODEMAP.
- [ ] DEVICE_PENDING.

## Anti-objetivos

- inventar threads  
- reabrir screen face monólito  
- tipografia  

## Plano W3

1. Judgment.  
2. Wire Surface.  
3. Pack.  
4. CODEMAP.  
5. ~5 files · ~200–400 LOC.

## Proof

1. Empty query recentes caption spoken ≡ face.  
2. Query miss 100-cap headline.  
3. Running thread row includes executando.  
4. DEVICE_PENDING.

## Council

Residual after screen-071 + idle peels. Runner-up: Artifact delivery polish closed.

---

## Detalhe list faces

| Face | Quando |
|---|---|
| recent(N) | browsing empty query with N recents |
| results(N) | query non-empty with N hits |
| miss | query non-empty zero hits |
| silence | loading/offline (screen owns; list silent) |

Row attention words: running (WorkspaceThreadJudgment) · newer (hasNewerContent) · plain.

## Critérios de rejeição

Se B só renomear spoken sem face/pack → fail.  
Se fundir com SearchScreenJudgment monólito >800 → fail peel.

---

*End WAVE-089 design.*
