# WAVE-113 — execution-proof-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-113-execution-proof-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after WAVE-112 · density residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ExecutionProof.swift` **513 LOC** — chrome/gates + body + decision/quality/
  activities no mesmo arquivo (agent-optimal fail for 1-read intent).
- Judgment already pure (ExecutionProofJudgment); View peels incomplete.
- Residual density after ArtifactSheet-112 pattern.

## Patamar

| Antes | Depois |
|---|---|
| 513 monólito | **3 peels** chrome / host / sections |
| Multi-intent file | 1 read = 1 domínio |

Δ = **densidade do cartão de prova de execução**.

---

## Arquitetura

### Princípios

- Casca only. Zero Core. Judgment stays pure.
- Same domain ExecutionProof*.

### Layout

```
ExecutionProofChrome.swift    gates · collapsed chrome · CTAs
ExecutionProof.swift          host + body shell
ExecutionProofSections.swift  decision · quality · activities
```

### Arquivos (≥5)

1. ExecutionProof.swift  
2. ExecutionProofChrome.swift (**new**)  
3. ExecutionProofSections.swift (**new**)  
4. CODEMAP  
5. design + compress  

### Densidade

Each ≤220. Hard fail any >600.

### Fora de escopo

- Core execution state  
- Tipografia  
- Judgment rewrite  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] Host ≤200.  
- [ ] Chrome peel gates/CTA.  
- [ ] Sections peel decision/quality/activities.  
- [ ] Build green · behavior unchanged.  
- [ ] CODEMAP.  
- [ ] Gates + DEVICE_PENDING.  

## Anti-objetivos

- inventar quality  
- tipografia  

## Plano W3

1. Split by MARK.  
2. Gates.  
3. CODEMAP.  
4. DONE/compress/regen.  

## Proof

1. `wc -l` peels ≤220.  
2. `make build` green.  
3. DEVICE_PENDING.

## Council

Density residual after 111–112 peels. Completes proof card topology.

### Why full-bar

- ≥5 files · density · DoD≥5 · design ≥120  

---

*End WAVE-113 design.*
