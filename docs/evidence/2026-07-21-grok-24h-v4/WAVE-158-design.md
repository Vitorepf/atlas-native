# WAVE-158 — home-workspace-radar-can-do-pack-honesty-instrument

**Status:** design · proposed  
**Wave:** `WAVE-158-home-workspace-radar-can-do-pack-honesty-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2 fill)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Partida surfaces still **hardcode** `canDo: .readChat`:
  - `HomeAskContext` — packs LiveNow rank + HomeOps faces, always readChat
  - `WorkspaceAskContext` — packs scoped live, always readChat
  - `AtlasCodeRadarAskContext` — packs radar screen/attention, always readChat
- Mid-thread / Arena / Autônomos already use **can_do matrices**
  (ConversationCanDo · Arena 083 · Autonomos 088). Partida is the last
  **door pack lie**: facts say “vivo / pede decisão / frota” while can_do
  claims pure read — agent under-authorizes or invents wrong verbs.
- Home ops door elevates awaiting/incident (HomeOpsJudgment) but never
  elevates can_do to faceCTALocal when doors are nav-only — need **honest
  matrix**: nav doors → readChat; live ongoing home → status/read with
  absence “CTAs de stop/escolher só na thread”; never claim ctaOnlyRunStop
  on Home without published stop surface.
- Radar heal/attention subjects in pack without can_do honesty for face
  CTAs if any (usually readChat is correct — then **document** with
  absences, not silent hardcode).

## Patamar

| Antes | Depois |
|---|---|
| canDo always readChat | **PartidaCanDoJudgment** (or per-host matrix) |
| Live/ops facts + mute can_do | can_do + absences aligned to doors |
| Three hosts copy hardcode | One law reusable |
| Agent under/over claims | Pack ≡ what face can do |
| ≤5s partida wrong power | Honest read vs face CTA local |

Δ = **soberania can_do das portas** — última superfície partida após 083/088/095.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** HomeOps faces, LiveNow pack, WorkspaceThread live, Radar
  screen already pure.
- **Honesty:** Home/Workspace **do not** invent stop/steer (no strip).
  Default readChat + absences “controle do run na conversa aberta”.
  Elevate faceCTALocal **only** if published face CTA exists on that
  surface (e.g. heal on code radar if CTA local; nightly accept on
  Autônomos catalog is Autônomos host not Home).
- Prefer thin `PartidaCanDoJudgment` shared by Home/Workspace/Radar.
- Do not re-litigate pill free-write / picker-first (Cursor-port).
- One domain: partida can_do pack.

### Fluxo / layout alvo

```
HomeAskContext
  → ops = HomeOpsJudgment.faces
  → live = LiveNowJudgment.pack
  → canDo = PartidaCanDoJudgment.home(ops, liveCount)
       usually readChat
       + absences if ops awaiting: "abrir Autônomos para assinar; NL home não decide"
WorkspaceAskContext
  → scoped live
  → canDo = PartidaCanDoJudgment.workspace(scopedLive)
RadarAskContext
  → screen face + attention
  → canDo = PartidaCanDoJudgment.radar(hasHealFaceCTA?)
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `PartidaCanDoJudgment` | matrix home/workspace/radar |
| HomeAskContext · WorkspaceAskContext · RadarAskContext | wire |

### Arquivos prováveis

- `PartidaCanDoJudgment.swift` (**new**)
- `HomeAskContext.swift`
- `WorkspaceAskContext.swift`
- `AtlasCodeRadarAskContext.swift`
- Optional HomeOpsJudgment pack can_do helpers
- CODEMAP (B)

### Densidade

- Judgment **150–400**
- AskContexts stay thin

### Fora de escopo

- Free-write pill intention  
- Mid-thread can_do rewrite  
- Density peels 156  
- Core  
- Autônomos veto (separate runner-up)  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] No bare `canDo: .readChat` without matrix helper on Home/Workspace/Radar.
- [ ] Awaiting ops on Home → absences about where to act (Autônomos), not fake decide can_do.
- [ ] Live on Home → no ctaOnlyRunStop invent; honest absence to open thread.
- [ ] Radar heal face CTA if published → faceCTALocal or documented read+absence.
- [ ] Workspace scoped live → same law.
- [ ] Spoken/pack absences stable product words.
- [ ] Gates + CODEMAP partida can_do (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- invent Home stop/steer  
- tipografia  
- density peel  
- reabrir picker-first  

## Plano W3

1. PartidaCanDoJudgment matrix.  
2. Wire three AskContexts.  
3. rg hardcode canDo readChat only via matrix.  
4. CODEMAP (B).  
5. Estimativa: **~5–8 files · ~250–500 LOC**.

## Proof / device

1. Home quiet → readChat + no fake CTAs.  
2. Home with Autônomos awaiting pack fact → absence where to sign.  
3. Live sessions on Home → no stop claim in can_do.  
4. Radar → honest can_do.  
5. DEVICE_PENDING se passcode.

## Council

**Pack council:** Home/Workspace/Radar last hardcode after Arena/Autônomos
matrices.  
**Arena organ pack wire** = WAVE-157 max.  
**Self-construction veto pack** = next Autônomos residual.

### Runner-ups

1. autonomos-selfconstruction-veto-pack-and-can-do  
2. conversation-steer packFacts + strip stop pack honesty  
3. autonomos receipt tone controlApplied wire  
4. composer queue row action Judgment  

---

*End WAVE-158 design.*
