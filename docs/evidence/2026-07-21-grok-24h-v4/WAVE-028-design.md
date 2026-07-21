# WAVE-028 — codigo-commit-map-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-028-codigo-commit-map-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Radar multi-repo (WAVE-024) tem `AtlasCodeRadarJudgment` (issues-first,
  mute badge, top_attention). O **grafo single-repo** — porta diária do
  código — **não** tem Judgment homólogo.
- `AtlasCodeView` inicia `graphStateFilter = .all` sempre
  (`AtlasCodeView.swift`). Com sem-retorno publicados, o operador ainda
  scrolla história em "todos" até achar "fora" — **não** é julgamento 5s.
- Pack grafo (`AtlasCodeAskContext.occasionFacts`) tem repo/trunk/head/
  counts/phase — **falta** filtro ativo, worktrees, `statusHeadline` /
  scan voice. Agente responde sem "que fatia estou vendo?".
- Status capsule (`AtlasCodeGraphChrome`) só pulsa em `.violating`/`.unknown`;
  não dirige default attention slice.
- Host forest: `AtlasCodeSurface.swift` ~925 LOC (~40 extensions) +
  `AtlasCodeCommitRowBody.swift` ~584 — peel forest sem órgão nomeado
  (WAVE-024 design já listou **runner-up** `codigo-commit-map-instrument`).
- WAVE-019 pack base existe; residual = **instrumento de julgamento do mapa**
  (default slice + pack completeness + row organ), não dual-count Core.
- Heal CTA de face existe; pack `can_do: .readChat` — honesty de boundary
  opcional nesta onda (faceCTALocal se hasHealReceipt), **sem** inventar
  mandar-curar NL write.

## Patamar

| Antes | Depois |
|---|---|
| Grafo = scroll + chips default todos | Grafo = **5s commit-map judgment** |
| Filter só UI local | Default attention: `fora` quando signals; silence clean |
| Pack sem filter/worktrees/status | Pack inclui slice · status · worktrees · focus |
| Radar tem Judgment; grafo não | `AtlasCodeGraphJudgment` paridade de órgão |
| Peel Surface/CommitRow | Instrument legível + W3 mesmo domínio |

Δ = soberania **single-repo**: em ≤5–10s o operador vê o que está fora /
curado / quiet e a pílula sabe a fatia.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** Sort/default/filter from `violations` / `state(for:)` /
  `scanState` / worktrees **já hidratados**.
- **Honesty:** unscanned / unknown → não inventar severe-first falso;
  keep wire order / all + absence.
- **Silence when clean:** scan clean → default `.all` ou quiet capsule;
  never "0 problemas!" theater.
- **Severe-first default:** se `violating` count > 0 e filter ainda é
  default all on first load → bias attention to `.violating` **uma vez**
  (operator can override chips).
- **Pack 019/020:** append filter · statusHeadline · worktrees · focus;
  dual-count permanece absence (§5 Core).
- **can_do honesty:** se heal face CTA published → `faceCTALocal` or
  keep readChat + absence "NL não cura"; never overclaim write.
- Densidade: Surface fuse peels do domínio grafo; View rota fina.

### Fluxo / layout alvo

```
load graph + violations
  → AtlasCodeGraphJudgment.defaultFilter(scan, counts)
  → chips reflect selection
  → list = filter.nodes (existing) + optional attention rank within slice

capsule
  → statusHeadline / silence clean (existing law elevated)

pack open
  → surface code.graph
  → facts: repo, trunk, filter, status, worktrees, counts
  → anchors: focus commit
  → absences: dual-count, agent filter DTO
```

### Tipos / módulos a criar ou elevar

| Nome | Papel |
|---|---|
| `AtlasCodeGraphJudgment` | defaultFilter · attention rank · pack facts pure |
| Optional `AtlasCodeGraphGrammar` | product words fora/main/curados/quiet |
| Existing | `AtlasCodeGraphStateFilter`, `AtlasCodeAskContext`, CommitRow |

### Arquivos prováveis

- `AtlasCodeGraphJudgment.swift` (**new**)
- `AtlasCodeView.swift` / surface state for default filter
- `AtlasCodeSurface.swift` — list/order consume judgment
- `AtlasCodeGraphChrome.swift` — capsule/chips honesty
- `AtlasCodeAskContext.swift` — pack completeness
- `AtlasCodeCommitRow.swift` + `AtlasCodeCommitRowBody.swift` — row organ
  align (spoken ≡ state)
- `AtlasCodeGraphStateFilter.swift` — only if helpers move to Judgment
- Radar **out** (024 done) salvo shared naming discipline
- CODEMAP update

### Densidade alvo

- `AtlasCodeView` shell ≤600
- Judgment 200–800
- Surface 1 domínio 800–1500 (Surface hoje ~925 — **não** push >2000)
- CommitRowBody fuse peels same domain; fail multi-domain concat

### Fora de escopo

- Dual-count Core reconcile / agent filter DTO (absence only)
- Metal graph / TreeSitter
- Radar folder residual (optional micro idle B — not this WAVE alone)
- Provenance/Why depth re-peel (009 craft)
- App Group CodeWeek widgets
- Nova área
- tool_permissions write mandar-curar (Core)

### §5 Core

`nenhum` para default filter + pack slice + judgment rank.  
Absences explícitas: dual-count, agent filter.  
§5 só se mandar-curar NL for requisito de produto (fora DoD desta onda).

---

## DoD produto (≥5 checkboxes casca-prováveis)

- [ ] Com violations hidratadas e count>0, default attention slice =
      **fora** (ou equivalente) sem exigir tap no chip; operator override ok.
- [ ] Scan clean / unknown: default honesto (all + silence / unknown copy);
      zero fake severe ranking.
- [ ] Pack facts incluem **filter ativo**, statusHeadline/scan, worktrees
      se publicados, focus; absences dual-count/agent filter mantidas.
- [ ] Capsule + chips + list falam a mesma fatia (visual ≡ pack subject).
- [ ] Commit rows spoken/state align GraphJudgment product words where
      applicable.
- [ ] can_do honesty: no NL cure claim; face heal CTA remains face path.
- [ ] W3: Surface/CommitRow peels do domínio legíveis; hosts na faixa;
      gates verdes; CODEMAP "grafo judgment".

## Anti-objetivos (B não deve)

- micro tipografia / opacity ladder
- fuse multi-domínio (grafo + radar + home monólito)
- inventar dual-count totals
- App Group data
- colapsar View/Shell >600 ou Surface >2000
- reabrir Radar 024 product DoD
- fuse-as-WAVE peels sem DoD de default filter/pack
- inventar agent filter UI sem DTO

## Plano W3 — código GOD (ordem)

1. **Extract** `AtlasCodeGraphJudgment` (defaultFilter, pack slice facts,
   optional within-slice rank) — pure.
2. **Rename honesty + MARKs** em Surface/Chrome densos.
3. **Wire** View default filter once on load; AskContext pack complete.
4. **Fuse** peels mesmo domínio Surface/CommitRowBody até faixa
   agent-optimal (não chase file-count).
5. **Delete** morto com rg (helpers duplicados de state label).
6. B atualiza CODEMAP.
7. Estimativa: **~6–10 arquivos · ~400–800 LOC estrutural** (Judgment +
   pack + default wire + structural fuse) — ≥300 e multi-file.

## Proof / device

1. Repo com sem-retorno → abre grafo já em **fora**; counts chip batem.
2. Repo clean → silence capsule; filter all; pack sem theater de zero.
3. Pill pack texto contém filter + status; focus swipe enriquece (019).
4. Override chip manual funciona; não trava operator.
5. DEVICE_PENDING se passcode.

## Council

**Código explore:** residual #1 Código pós-024 = **commit-map instrument**
(GraphJudgment + pack incompleto + default todos).  
**Conversa explore:** presence/pack conversation — outro eixo.  
**Arena/Home explore:** Autônomos decision e home-ops — fora Código.  
WAVE-024 design **explicitamente** deferiu este residual. Δ **high**:
fecha o órgão diário single-repo com paridade Radar judgment; max fica
com soberania de assinatura (026).
