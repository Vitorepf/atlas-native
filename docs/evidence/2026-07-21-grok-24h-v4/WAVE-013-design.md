# WAVE-013 — artifact-change-review-instrument

**Status:** design · proposed  
**Wave:** `WAVE-013-artifact-change-review-instrument`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **high** (max no eixo julgamento humano do output do agente)  
**Rank:** 2  

---

## Problema

O momento de **assinatura/veto** do operador sobre o trabalho do agente vive em
dois torres peels (~200+ arquivos Artifact* + ChangeReview*):

1. **ArtifactSheet / ArtifactViewer** — list · select · preview · mount · too-large
   · fail · unavailable — dialects de lifecycle.
2. **ChangeReview** — patches · file accept/reject · council · findings · diff —
   contratos C15/C16 já no Core; casca ainda é névoa Elite.

WAVE-012 cobre aftermath proof CTA de artifacts; **não** é a galeria nem o
accept/reject por arquivo. WAVE-008 exclui empty de artifact do load-fail canon.
Sem este wave, o operador **não fecha em 5s**: o que saiu · abrir · aceitar/
rejeitar · council.

---

## Patamar

| Antes | Depois |
|---|---|
| Artifact + Review = 2 produtos peels | **Um** instrument de julgamento de output |
| Preview/unavailable dialects | Estados mutuamente exclusivos honestos |
| Accept sem grammar visual | File decisions + applying state model-only |
| CTA proof → dialect diferente | Mesma voz (glue fino) |

Δ = capacidade de **veto soberano** sobre o patch/artefato (papel humano canônico).

---

## Arquitetura

### Princípios

- **Casca only.** Diff/accept/reject já model-owned (C15/C16). Zero inventar
  `engineering_run_id`, fake diffs, fake council.
- **Trace-scoped only.** Sem run unívoco → unavailable explícito.
- **Unavailable ≠ empty catalog** (lista sem itens ≠ load fail).
- **Preview states exclusive:** loaded | too-large | fail | busy | unavailable.
- **No global “Aprovar”** doctrine violation.
- Hosts ≤400; W3 fuse peels.

### Árvores alvo

```
ChangeReviewInstrument
  header (run/trace) · patches · file row decisions · council · findings

ArtifactInstrument
  list · select · preview surface · mount honesty
```

### Fora de escopo

- WAVE-012 proof expand (só glue CTA).
- Core new review endpoints.
- Device proof operator (note DEVICE_PROVEN).
- Nova rota/tab.
- Autônomos self-construction (outro eixo).

---

## Arquivos (W2)

| Área | Mudança |
|---|---|
| `ChangeReview*` | Instrument tree; fuse peels |
| `ArtifactSheet*` / `ArtifactViewer*` | Instrument + exclusive preview states |
| Proof CTA mount (se preciso) | Thin glue → same grammar |
| A11yID review/artifact | Estáveis |

### W3

| Alvo | Estimativa |
|---|---|
| Artifact + ChangeReview fuse | **−500…−1200** |

`WAVE-013-compress.md`.

---

## DoD (≥5)

1. **Review instrument:** header · patches · file decisions · council · findings
   numa árvore visual/spoken.
2. **Artifact instrument:** list · select · preview · mount; unavailable ≠ empty.
3. File accept/reject **só** em paths do patch model; applying state visível.
4. Preview: loaded / too-large / fail / busy **mutuamente exclusivos**; zero content inventado.
5. Trace-scoped; absence de review/artifacts = unavailable explícito.
6. A11y IDs preservados; hosts ≤400.
7. Gates guard + checks + build; glue opcional do ExecutionProof CTA sem segundo dialect.

---

## Anti-objetivos

- Global approve theater.
- Inventar diffs/council.
- Opacity ladder.
- WAVE-008 load-fail steal.
- God-file monólito.

---

## Plano W3

DoD instruments → fuse Artifact then Review → delete dead → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — veto soberano |
| DoD≥5 + multi surface + W3≥500 | **SIM** |
| Casca | **SIM** (C15/C16 live) |
| Design | **SIM** |
| Anti-micro | **SIM** (~200 files) |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Fake diff | critical if | model-only |
| Unavailable as empty | major | DoD2 |
| Break XCUITest IDs | major | preserve |

**Critical open:** 0.

---

## §5

Nenhum se contratos C15/C16 já expostos ao model. Device proof = operador.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- residual #2 artifact-change-review  
