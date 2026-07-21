# WAVE-026 — autonomos-decision-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-026-autonomos-decision-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Autônomos é a frota soberana do operador; o ritual **pedir decisão** é o
  eixo de soberania humana (OBRA: intenção · julgamento · assinatura · veto).
- Live: `AutonomosHubVestment.resolve` já classifica **awaiting** a partir de
  backlog real (`decisionRequired` / `operatorDecisionRequired`) e fala
  kicker **"Pede você"** / hero **"N decisões"** (`AutonomosHubVestment.swift`).
- **Mentira de órgão:** `AutonomosHubView.primaryVerb` para `.awaiting` e
  `.live` é **`EmptyView()`** — o hub grita "pede você" e **não oferece verbo**.
- Destinos `.decisions` / `.decisionInbox` / `.decisionOrder` / `.moment` /
  `.incident` em `AutonomosMapShell.route` renderizam placeholder **"Ainda no
  escopo local"** mesmo quando o model já expõe `decide`, `backlog`,
  `startRun`, `control` (`AutonomosModel.swift`).
- `AutonomosListView` só rankeia pause→quiet (WAVE-025); **não** eleva unidades
  com backlog awaiting real quando área/backlog estiver hidratado.
- Pack `AutonomosAskContext` declara absence "não invente backlog" em destinos
  decision — honesto para o placeholder, **errado** se backlog publicado existe
  e a casca se recusa a mostrar.
- WAVE-007/025 fecharam **vestment words**. Residual = **instrumento de
  decisão** (julgar + assinar), não tipografia nem fuse de peels.

## Patamar

| Antes | Depois |
|---|---|
| "Pede você" sem CTA | Hub awaiting → **verbo primário** abre decisões reais |
| Destinos decision = theater vazio | Faces de decisão com rows do backlog **publicado** |
| List = pause-only judgment | List eleva awaiting quando signal hidratado |
| Pack mente absence em decision screen | Pack subjects = itens reais + absences honestas |
| Operator cannot act | Operator **julga e decide** em ≤10s (ReasonSheet + decide) |

Δ = **soberania operacional da frota** — o humano assina decisões reais;
silêncio quando não há backlog; zero theater de inbox inventada.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** Usa `AutonomosModel.backlog`, `live`, `decide`,
  `selectedArea` / seleção já existentes — **não** inventa contagens.
- **Honesty:** backlog nil → silence / quiet face; never fake inbox.
- **Silence when quiet:** zero alarm chrome se awaiting count = 0.
- **Pack law 020:** surface · subject · anchors · facts · absences · can_do
  (`faceCTALocal` já existe — deepen subjects).
- **Um domínio/arquivo:** Judgment puro separado de Surface/Shell.
- **§5:** só se faltar DTO ou create-unit server; create POST continua out.

### Fluxo / layout alvo

```
Lista (judgment order)
  → awaiting units first (real backlog OR vestment signal)
  → open hub

Hub vestment == awaiting
  → primary CTA "Ver decisões" / "1 decisão"
  → push .decisions

Decisions surface
  → exclusive faces: empty | loading | items | failed
  → rows: inbox decisionRequired + workOrders operatorDecisionRequired
  → tap → detail / ReasonSheet → model.decide(...)

Quiet hub
  → silence decisions chrome; resume only if paused
```

### Tipos / módulos a criar ou elevar

| Nome | Papel |
|---|---|
| `AutonomosDecisionJudgment` | rank/order/exclusive face from published backlog |
| `AutonomosDecisionGrammar` (optional) | copy/spoken product words (awaiting/item/empty) |
| `AutonomosDecisionPack` helper | pack subjects from real items (or extend AskContext) |
| `AutonomosDecisionSurface` / list rows | composition 1 domínio decisões |
| Existing | `AutonomosHubVestment`, `AutonomosReasonSheet`, `AutonomosModel.decide` |

### Arquivos prováveis

- `AutonomosDecisionJudgment.swift` (**new** pure judgment)
- `AutonomosHubView.swift` — primaryVerb awaiting → CTA
- `AutonomosMapShell.swift` — route decisions for real backlog
- `AutonomosListView.swift` — judgment order with awaiting signal
- `AutonomosHubVestment.swift` — only if listFace needs backlog-aware face
- `AutonomosAskContext.swift` — subjects/absences honesty
- Thin decision list/detail views (`Autonomos*Decision*`)
- A11y IDs domain Autônomos (stable)

### Densidade alvo

- Shell/View rota (`AutonomosView` / MapShell) **≤600**
- Judgment **200–800**
- Decision Surface **800–1500** (fail >2000)
- Não colapsar hub+list+decision no mesmo host

### Fora de escopo

- Create Autônomo no servidor / POST fleet 24/7 inventada
- Continuity App Group data
- Nova tab ou domínio fora Autônomos
- Re-chrome pill dock (016)
- Arena / Código

### §5 Core

`nenhum` para o caminho feliz se backlog + decide já hidratam.  
Pedido §5 **só se** `selectedArea` nunca for ligável a unit local sem novo
campo Core — documentar absence e silenciar, **não** inventar wire.

---

## DoD produto (≥5 checkboxes casca-prováveis)

- [ ] Hub `awaiting` mostra **CTA primário** para a superfície de decisões
      (não EmptyView).
- [ ] Destino `.decisions` lista **somente** itens publicados com
      `decisionRequired` / `operatorDecisionRequired` (zero inventados).
- [ ] Empty/loading/failed faces exclusivas; quiet silence when count=0.
- [ ] Operator pode completar `decide` via ReasonSheet (ou path existente)
      com recibo honesto de erro.
- [ ] List judgment eleva units awaiting quando signal hidratado; quiet last.
- [ ] Pack invite ≡ emptyPrompt ≡ turnFacts occasion; subjects = real items;
      absences honestas se backlog nil / create server pendente.
- [ ] Spoken a11y ≡ face product words (025 vestment + decision face).
- [ ] Gates `AtlasCoreChecks` + `make build`; CODEMAP 1 linha "onde decide".

## Anti-objetivos (B não deve)

- micro-onda / tipografia isolada / opacity ladder
- fuse multi-domínio (Autônomos + Arena + Home no mesmo arquivo)
- inventar contagens de inbox / frota 24/7
- App Group Continuity data
- colapsar Shell >600 ou Surface >2000
- inventar endpoint/campo Core sem §5
- reabrir WAVE-025 só para rename de kicker
- fuse-as-WAVE de peels sem DoD de decisão

## Plano W3 — código GOD (ordem)

1. **Extract** `AutonomosDecisionJudgment` (faces + rank + item projection
   from published backlog types) — regra pura primeiro.
2. **Rename honesty + MARKs** em decision hosts densos.
3. **Wire** Hub primaryVerb + MapShell route + List order (mesmo domínio).
4. **Fuse** só peels do domínio decisão (placeholder → surface legível).
5. **Delete** morto: copy "Ainda no escopo local" quando backlog real
   (rg prova: placeholder só se area/backlog realmente indisponível).
6. **Pack** subjects/absences align 020.
7. B atualiza CODEMAP (decisão → Judgment + Surface).
8. Estimativa: **~8–12 arquivos · ~400–900 LOC estrutural** (Judgment +
   surface + hub/list/shell wire + pack) — escala ≥300 e ≥5 files e ≥30 min.

## Proof / device

Operador no device:

1. Unit com backlog awaiting real → lista eleva / hub "Pede você" + CTA.
2. CTA → lista de decisões com subjects reais.
3. Decide uma → UI reflete quiet/awaiting residual sem contagem falsa.
4. Unit quiet sem backlog → zero alarm chrome; pack absence honesta.
5. DEVICE_PENDING se passcode; senão screenshot hub+decisions.

## Council

**Código explore:** residual Código = commit-map (024 runner-up), não Autônomos.  
**Conversa/Pílula explore:** presence primary + occasion pack — eixos Conversa,
não frota.  
**Arena/Home/Autônomos explore:** **#1 residual max** = decision organ morto
(hub EmptyView + destinos placeholder vs Model.decide/backlog vivos).  
Este Δ **vence** home-ops e arena-live porque é o único com **soberania
assinatura** quebrada (humano não consegue o papel que o vestment promete).
Home-ops e commit-map seguem como WAVEs 028–029.
