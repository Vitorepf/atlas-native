# WAVE-030 — autonomos-run-control-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-030-autonomos-run-control-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- WAVE-026 fechou **assinatura de decisão** (awaiting → CTA → decide +
  ReasonSheet). Residual de soberania da frota = **veto / controle do loop**
  (OBRA: Intenção · Julgamento · Assinatura · **Veto** com recibo).
- **Wire vivo; casca morta.** `AutonomosModel.control(.pause|.resume|.kill|
  .clearKill)`, `startRun`, `transfer`, `revertCycle` existem sobre Core
  (`controlAutonomosRun`, …). Grep `App/**`: **`model.control` = 0 call
  sites**. Só `startRun(.dryRun)` roda via Nightly ReasonSheet.
- **"Pausar / Retomar" é teatro local.** Hub → `setOperatorUnitPaused` só
  (`AutonomosMapShell` → `AutonomosHubView`). Pack ainda fala
  `estado: pausado (local)`. Operador acha que parou a frota; o loop no
  servidor **não** recebe sinal.
- **`.live` primaryVerb = `EmptyView()`.** Vestment grita "Vivo / Evoluindo"
  e **não** oferece pause/kill/start governados. 026 só fechou `.awaiting`.
- **Área nunca se seleciona.** Após compressão onda-1 (delete
  `AutonomosAreaPicker*`), **`selectArea` não é chamado da UI**.
  `selectedArea` fica nil → `loadSelectedDetails` / live / backlog / fleet
  não hidratam; `control` / `decide` / `startRun` dão `guard selectedArea
  else { return }`. Órgãos 025–026 ficam **quiet theater** sem bind.
- Sinais já decodificados e não julgados: `live.isRunning/isPaused/isKilled`,
  `AtlasAutonomosLoopPhase`, `lastControlReceipt.applied` + flags pause/kill.
  Arena tem `ArenaPremiumStopSheet` wired; Conversation tem cancel/steer;
  Autônomos loop = **último furo max casca-unblocked**.

## Patamar

| Antes | Depois |
|---|---|
| "Vivo" sem verbo de controle | Hub live → **CTA governado** (pausar loop / kill) via ReasonSheet |
| Pausar = opacity local | Pausar wire = **`model.control`** + recibo; local demoted/honesty |
| Quiet sem start | Quiet + area registered → **start / dry-run** honest path |
| `selectedArea` always nil | Bind automático (1 registered) ou silence + absence (multi/zero) |
| Pack mente "local pause" | Pack: **loop phase · last control receipt · canControl** |
| Operador sem veto | Operador **veto o loop** em ≤10s com recibo |

Δ = **soberania operacional da frota** — o humano aplica sinal real
(pause/resume/kill/start) no loop publicado; silêncio se área unbound /
unregistered; zero teatro de "parei" só no catálogo.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** Usa `areas`, `selectArea`, `live`, `control`, `startRun`,
  `canControlSelectedArea`, receipts e `AutonomosReasonSheet` **já
  existentes** — zero endpoint novo.
- **Honesty:** area nil / unregistered / live nil → faces de absence /
  silence; never fake "pausado no servidor" a partir de `unit.paused`.
- **Silence when quiet unbound:** zero alarm chrome se não há area
  controlável; pack absence "área não ligada neste iPhone".
- **Local pause demotion:** se wire control disponível, nav "Pausar" local
  **não** finge ser o loop; renomear/honesty ("só lista") ou remover do
  primary path. Prefer **não** dois "Pausar" ambíguos.
- **WAVE-026 pétreo:** decision organ permanece; esta onda **não** reabre
  inbox/decide — só garante que area hydrate **desbloqueia** 026 de fato.
- **Pack law 020:** surface · subject · anchors · facts · absences · can_do
  (`faceCTALocal` para control CTAs).
- **Um domínio:** Judgment puro de loop separado de DecisionJudgment.
- **§5:** só se multi-area product exigir binding unit↔area nomeado no Core;
  default = first registered auto-select + absence se zero/multi sem
  escolha honesta thin.

### Fluxo / layout alvo

```
Autonomos appear / load areas
  → AutonomosRunControlJudgment.bindPolicy(areas)
       · 0 registered → unbound (silence control; pack absence)
       · 1 registered → selectArea(id) once
       · N registered → thin chooser OR keep last + absence honesty
  → loadSelectedDetails → live · backlog · fleet

Hub vestment resolve (existing) + control face
  → awaiting (026) still wins primary for decisions
  → else control face from live:
       running  → primary "Pausar loop" / secondary "Encerrar loop (kill)"
       paused   → primary "Retomar loop" / clear-kill if killed signal
       idle     → primary "Iniciar" (startRun) if canControl
       unbound  → silence verbs; hero honesty
       failed   → controlError face

CTA → AutonomosReasonSheet(actor+reason)
  → model.control(action) | model.startRun(mode)
  → surface lastControlReceipt / lastStartRunReceipt (applied? note?)
  → refresh live face

Local unit pause
  → only catalog list opacity OR explicit "lista local" — never primary
    when canControlSelectedArea
```

### Tipos / módulos a criar ou elevar

| Nome | Papel |
|---|---|
| `AutonomosRunControlJudgment` | pure: bind policy · exclusive control face · primary/secondary actions · receipt summary |
| `AutonomosRunControlGrammar` (optional) | product words (running/paused/killed/idle/unbound) |
| Existing | `AutonomosHubVestment`, `AutonomosReasonSheet`, `AutonomosModel.control/startRun/selectArea` |
| Pack | extend `AutonomosAskContext` with loop phase + receipt + absences |
| Optional thin | receipt line under hub CTA (applied / note) — not fleet monólito |

### Arquivos prováveis

- `AutonomosRunControlJudgment.swift` (**new** pure judgment)
- `AutonomosHubView.swift` — primaryVerb live/quiet control (not EmptyView)
- `AutonomosMapShell.swift` — bind area on appear; wire ReasonSheet → control/startRun; demote local pause
- `AutonomosView.swift` — header subtitle live = loop face when hydrated (not only unit.paused)
- `AutonomosAskContext.swift` — facts/absences/can_do honesty for control
- `AutonomosHubVestment.swift` — only if face needs live-phase product words beyond 025
- A11y IDs domínio Autônomos (stable new ids for control CTAs if needed)
- B updates CODEMAP 1 linha "Controle do loop Autônomos" (implementer only)

### Densidade alvo

- Shell/View rota (`AutonomosView` / MapShell) **≤600**
- Judgment **200–800**
- Hub permanece fino; **não** ressuscitar Fleet*/Digest* monólito
- Não colapsar hub+decision+control no mesmo god file

### Fora de escopo

- Create Autônomo no servidor / POST fleet inventada
- Continuity App Group data / widgets
- Transfer mission surface completa (API exists — runner-up separado)
- Self-construction `revertCycle` full veto surface (runner-up; pode thin-wire
  se mesmo ReasonSheet grammar na mesma passagem **sem** expandir escopo)
- Evolution delivered deep surface
- `.moment` / `.incident` theater
- Arena / Código / Conversation decision strip (runner-up conversa)
- Re-chrome pill dock (016)
- NL mandar-fazer write
- Nova tab

### §5 Core

`nenhum` no caminho feliz: `listAutonomosAreas` + `selectArea` + `live` +
`control`/`startRun` já no model.  
§5 **só se** product exigir unit↔area id no wire — documentar absence e
auto-bind first registered; **não** inventar DTO.

---

## DoD produto (≥5 checkboxes casca-prováveis)

- [ ] Em appear/load, área **registered** é bound (auto se 1) **ou** pack/UI
      declara absence unbound (nunca finge live/control).
- [ ] Hub face `live` / running com area controlável mostra **CTA primário**
      de controle (não `EmptyView()`).
- [ ] CTA → ReasonSheet → `model.control` com action real; UI reflete
      `lastControlReceipt` / live pós-refresh (applied honesty; erro via
      `controlError`).
- [ ] Quiet/idle + `canControlSelectedArea` oferece start (ou dry-run) path
      honesto — não só opacity de unit local.
- [ ] "Pausar" local **não** compete como se fosse o loop quando wire
      control está disponível (demote/honesty label).
- [ ] Pack: loop phase · canControl · last receipt fact; absences se unbound
      / unregistered / live nil; can_do face CTA local.
- [ ] Spoken a11y ≡ product words do control face.
- [ ] Gates `AtlasCoreChecks` + `make build`; CODEMAP 1 linha controle do loop
      (B).

## Anti-objetivos (B não deve)

- micro-onda tipografia / opacity ladder
- fuse multi-domínio (Autônomos + Arena + Home monólito)
- ressuscitar fleet dashboard monólito onda-1
- inventar contagens / frota 24/7
- App Group Continuity data
- colapsar Shell >600
- inventar endpoint/campo Core sem §5
- reabrir WAVE-026 só para rename de decisão
- fuse-as-WAVE de peels sem DoD de control
- fingir `unit.paused` = `live.isPaused`

## Plano W3 — código GOD (ordem)

1. **Extract** `AutonomosRunControlJudgment` (faces + actions + bind policy
   from published `areas`/`live`/receipts) — regra pura primeiro.
2. **Bind** area on shell appear/load (1 registered auto; multi honesty).
3. **Wire** Hub primaryVerb live/quiet → ReasonSheet → control/startRun.
4. **Demote** local pause path; rename honesty se permanece.
5. **Receipt line** thin under hub (applied/note/error) — não monólito.
6. **Pack** loop facts/absences/can_do align 020.
7. **Delete** morto: EmptyView live branch; copy que promete pause server
   sem wire (rg prova).
8. B atualiza CODEMAP (controle do loop → Judgment + Hub).
9. Estimativa: **~7–12 arquivos · ~400–900 LOC estrutural** (Judgment +
   hub/shell wire + pack + bind) — escala ≥300 e ≥5 files e ≥30 min.

## Proof / device

Operador no device:

1. Áreas: 1 registered → open Autônomos → live hidrata (ou quiet honest).
2. Loop running → hub "Vivo" + CTA Pausar loop → ReasonSheet → receipt;
   live vira paused **no servidor** (não só opacity da lista).
3. Paused → Retomar; kill path com confirmação governada.
4. Unbound / zero areas → zero CTAs falsas; pack absence.
5. Awaiting ainda vence primary (026) quando backlog decisionRequired > 0.
6. DEVICE_PENDING se passcode; senão screenshot hub control + receipt.

## Council (2026-07-21 · ≥3 explore read-only)

**Autônomos sovereignty explore:** **#1 residual max** = run-control organ
morto (`control` 0 call sites + local pause theater + `selectArea` unmounted
+ `.live` EmptyView). Após 026 (assinatura), este é o **veto** do papel
humano OBRA.  
**Conversa/Pílula explore:** runner-up max =
`conversation-decision-control-instrument` (strip só Parar/Redirecionar
enquanto StateCard tem choices; attention→face running). **Não absorver** —
domínio conversa; 027/029 já na fila.  
**Home/Workspace/Radar explore:** runner-up =
`workspace-live-thread-judgment-instrument` (lista workspace sem rank live
por threadId). Δ alto; não vence veto da frota.  
**Outros runner-ups:** self-construction `revertCycle` veto (sheet canRevert
false); evolution delivered proof surface.

Δ **max**: único residual casca-unblocked com **soberania de veto do loop
vivo** quebrada — APIs Core+Model prontas, casca finge pause local.

### Explicitamente NÃO esta onda

| Item | Por quê |
|---|---|
| WAVE-027 presence chrome | open high · conversa vocabulary |
| WAVE-028 codigo commit-map | open high · grafo |
| WAVE-029 occasion pack | open high · thread entry |
| WAVE-026 decide path | done · não reabrir |
| Continuity App Group | BLOCKED |
| Conversation choice strip elevate | runner-up onda própria |

---

## Runner-ups (fila futura · não implementar aqui)

1. `conversation-decision-control-instrument` (Δ max conversa) — strip
   Escolher / attention face honesty.
2. `self-construction-retroactive-veto-instrument` (Δ high) — wire
   `revertCycle` no receipt sheet.
3. `workspace-live-thread-judgment-instrument` (Δ high/max workspace) —
   threadId live rank + pack scoped.
4. `autonomos-evolution-delivered-proof-surface` (Δ high–med).
