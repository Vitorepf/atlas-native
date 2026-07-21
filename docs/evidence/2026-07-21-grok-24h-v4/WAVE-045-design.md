# WAVE-045 — home-ops-attention-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-045-home-ops-attention-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Dentro de Autônomos (026–038) e Arena (021 score + stop sheets) os
  **órgãos de julgamento existem**. Na **porta Home · OPERAÇÃO** o operador
  ainda vê diretório mudo:
  - Autônomos row: spoken fixo *"abre catálogo de escopos soberanos"* —
    zero elevação de awaiting / incident / live loop / fleet pressure.
  - Arena row: `regression: nil` forçado (ordem 2026-07-18 home limpa) e
    só `domainUnavailable` — attention never elevates from published
    signals on the door.
- `HomeAskContext` empacota threads/live/workspaces e **proíbe inventar**
  contagens de frota/Arena — honesto, mas também **nunca** empacota
  attention ops **real** pós-hidratação → pack "safe empty", não steward.
- `session.autonomos` / `session.arena` vivem em `AtlasSession`; home quase
  não os lê. Fleet/backlog/taskHealth/digest hidratam **só** com area bind
  (Autônomos interior). A porta não faz hydrate leve global.
- Residual nomeado desde 026/029/031 councils: **home-ops directory mute**
  — último furo de **soberania de primeiro olhar** cross-surface após
  030–043 fecharem órgãos internos.
- WAVE-044 (timeline narrative face) é mid-run; esta onda é a **porta do
  produto**.

## Patamar

| Antes | Depois |
|---|---|
| OPERAÇÃO = labels fixos | OPERAÇÃO = **attention face** por row (awaiting > incident > live > quiet) |
| Pack Home sem ops | Pack inclui facts/absences ops **publicados** |
| Silêncio mesmo com frota pedindo | Meta/spoken elevam pressure real |
| Arena home sempre neutro | Mantém home limpa (sem badge regressão); domainUnavailable only; spoken-only se scoreboard cached |
| ≤5s na porta = "catálogo" | ≤5s = **o que pede o operador agora** |

Δ = **soberania de atenção na porta** — o humano vê se o mundo ops pede
julgamento antes de abrir o catálogo.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** Reusa `AutonomosModel` / judgments publicados
  (Decision · TaskHealth · Fleet · Digest · RunControl faces) e
  `ArenaModel.isDomainUnavailable` — **nunca inventa** contagens.
- **Silence when quiet / unbound:** zero alarm chrome se signals nil;
  pack absence "ops ainda não hidratados" / "área unbound".
- **Home limpa pétrea (2026-07-18):** **não** reintroduzir Arena
  regression badge na Home. Arena row = domainUnavailable honesty only
  (+ optional spoken-only if composite already cached — never red-dot).
- **Hydrate leve:** em Home appear, se areas/fleet/taskHealth/digest
  APIs já no model sem area, prefer global reads; se só com area —
  auto-bind first registered (paridade 030) **ou** absence. Não bloquear
  Home em spinner de frota.
- **Pack law 020:** surface home · ops anchors · facts · absences · can_do
  (`readChat` + face CTA local se entry tem verb real).
- Um domínio: `HomeOpsJudgment` — não monólito RootHome.

### Fluxo / layout alvo

```
Home appear
  → light ops hydrate (areas list · fleet? · taskHealth? · digest?
     silence until published; never invent)
  → HomeOpsJudgment.resolve(
        backlog?, live?, taskHealth?, fleet?,
        arenaDomainUnavailable
     )
  → OPERAÇÃO rows:
       Autônomos meta/spoken = face product words
         awaiting(N) > incident > live loop > fleet pressure > quiet
       Arena meta = domainUnavailable | quiet entry (no regression badge)
  → HomeAskContext += ops facts/absences (published only)
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `HomeOpsJudgment` | exclusive ops face · row meta · pack facts · spoken |
| Existing | Autonomos*Judgment faces (reuse words), RootHomeSections, HomeAskContext |
| Optional thin | `HomeOpsFaceStrip` under OPERAÇÃO header only if multi-signal |

### Arquivos prováveis

- `HomeOpsJudgment.swift` (**new** pure)
- `RootHomeSectionsBody.swift` — operacaoSection meta/spoken
- `RootHomeFace.swift` / `RootHomeSections.swift` — only if host needs hydrate hook
- `HomeAskContext.swift` — ops pack honesty
- `AtlasSession.swift` — only if shared hydrate entry already exists (presentation call)
- `AutonomosModel.swift` — **no** logic change; call existing load/refresh if already public
- A11yIDs stable home ops
- CODEMAP 1 linha (B)

### Densidade

- Judgment **200–800**
- RootHomeSections permanece fino; não god-concat Arena+Autônomos surfaces
- Fail se RootHome monólito >600 por esta onda

### Fora de escopo

- Arena regression badge na Home (ordem 2026-07-18)
- Re-litigar pill picker-first vs free write (015 residual · Cursor port —
  onda separada se operador reabrir)
- Continuity App Group data
- Core novos campos
- LiveNow redesign
- Autônomos create server
- WAVE-044 timeline narrative (paralela, mid-run)
- Micro tipografia / fuse-as-WAVE

### §5 Core

`nenhum` se fleet/taskHealth/digest/areas já listáveis.  
§5 só se home precisar endpoint global que **não** existe — documentar
absence e silenciar, não inventar.

---

## DoD produto (≥5)

- [ ] OPERAÇÃO Autônomos row eleva **meta/spoken** quando signal awaiting /
      incident / live publicado (não spoken fixo de catálogo).
- [ ] Quiet / unbound / nil signals → **silence** (zero "0 problemas" theater).
- [ ] Arena row **sem** regression badge; domainUnavailable honesty preserved.
- [ ] `HomeAskContext` inclui facts/absences ops **só** com dados publicados.
- [ ] Hydrate leve não inventa backlog; Home não trava em spinner ops.
- [ ] A11y spoken ≡ product words do face.
- [ ] Gates + CODEMAP "home ops attention" (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- micro-onda tipografia
- fuse multi-domínio Home+Autônomos monólito
- inventar contagens
- badge Arena regressão na Home
- App Group Continuity
- reabrir 015 pill intention sem ordem operador
- fuse-as-WAVE peels sem DoD attention

## Plano W3

1. Extract `HomeOpsJudgment` (faces + precedence + pack helpers).
2. Wire light hydrate honesty (existing model APIs).
3. Wire operacaoSection meta/spoken.
4. Pack HomeAskContext.
5. Delete spoken fixo mentiroso quando signal existe (rg prova).
6. CODEMAP (B).
7. Estimativa: **~6–10 files · ~350–700 LOC**.

## Proof / device

1. Area bound + backlog awaiting → Home Autônomos fala "pede N decisões"
   (ou product word canônico).
2. Quiet catalog → silence alarm; pack absence ok.
3. Arena domain unavailable → spoken honesto; sem pingo regressão.
4. Offline / nil → zero theater.
5. DEVICE_PENDING se passcode.

## Council (2026-07-21 · ≥3 explore)

**Sovereignty explore:** #1 residual max pós-042 = **home-ops door mute**
(cross-surface attention).  
**Conversa explore:** home-pill intention + composer readiness — intention
conflita com Cursor-port order; composer = WAVE-046.  
**Código/Arena explore:** heal veto / arena live control — high; home door
vence como primeiro olhar.  
WAVE-043 repo-health e WAVE-044 timeline = outros eixos (já done/open).

### Runner-ups (não esta onda)

1. `composer-send-readiness-judgment` (Δ high) → WAVE-046  
2. `conversation-agent-lanes-judgment` (Δ high)  
3. `codigo-heal-veto-judgment` (Δ high — undoError never rendered)  
4. `arena-live-control-judgment` (Δ high)  
5. `home-pill-intention-primary` — **blocked** sem reabrir ordem picker-first  

---

*End WAVE-045 design.*
