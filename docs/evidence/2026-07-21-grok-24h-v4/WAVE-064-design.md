# WAVE-064 — home-live-now-attention-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-064-home-live-now-attention-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore · proposed < 2)  
**Δ patamar:** **max**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- **VIVO AGORA** é a porta de continuidade in-app, mas o **ranking de
  atenção** ainda é View-local em `LiveNowSection.sessions` (face rank
  running → paused → finished) — **sem pure Judgment** reutilizável.
- **Deep-link Continuity** `handleExecutionHomeDeepLink` ordena por
  `startedAt` e abre o **último** com `threadId` — **dialeto paralelo**
  ao hub VIVO AGORA. Operador toca "Seguir" e pode cair na thread **errada**
  vs a row #1 do hub.
- **`HomeAskContext` pack** ancora `liveSessions.prefix(5)` em **wire/raw
  order** — não face rank → pack mente "o que está mais vivo".
- Pós-023/027 (face words) e 045/047 (home-ops door): residual **cross-entry
  live attention** (section · deep-link · pack) ainda **três dialetos**.
- Continuity **App Group data** permanece BLOCKED; esta onda é **casca
  rank honesty** sobre `LiveSessionSnapshot` já publicado — não inventa
  ContentState.

## Patamar

| Antes | Depois |
|---|---|
| Rank só em LiveNowSection | **LiveNowJudgment.rank** único |
| Deep-link = chrono last | Deep-link = **same attention head** com threadId |
| Pack live wire order | Pack anchors = **ranked** sessions |
| Spoken section count-only | Section face: empty silence / hub / single |
| ≤5s "qual vivo?" diverge | Uma língua: hub = pack = Seguir |

Δ = **soberania de atenção viva na porta** — Seguir e pack apontam o mesmo
mundo que VIVO AGORA.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** `LiveSessionSnapshot` + `ConversationExecutionPhase.face`
  já existem.
- **Honesty:** zero invent de sessão; deep-link sem live com threadId →
  home silence (path clear already).
- **Merge local+remote** stays one function (move pure to Judgment).
- **App Group data BLOCKED** — não tocar widgets ContentState fields.
- **WAVE-023 face order** preserved as Judgment law (not re-litigate).
- Pack law 020: home anchors live ranked; absences if empty.
- Um domínio: LiveNow attention — não monólito RootHome+Conversation.

### Fluxo / layout alvo

```
local + remote snapshots
  → LiveNowJudgment.merge
  → LiveNowJudgment.rank (face precedence + stable tie)
  → LiveNowJudgment.headForOpen (first with threadId, or nil)
  → LiveNowSection.rows = rank
  → handleExecutionHomeDeepLink → headForOpen
  → HomeAskContext live anchors = rank.prefix(N) product words
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `LiveNowJudgment` | merge · rank · headForOpen · section face · pack anchors · spoken |
| Existing | LiveNowSection/Row, RootHomeFace deep-link, HomeAskContext, Phase face |

### Arquivos prováveis

- `LiveNowJudgment.swift` (**new** pure)
- `LiveNowSection.swift` — consume rank (delete inline sort)
- `LiveNowRow.swift` — only if spoken helpers move
- `RootHomeFace.swift` / `RootView` extension — deep-link head
- `HomeAskContext.swift` — ranked live anchors
- Optional: `ConversationOccasionPack` live line if shares rank helper
- CODEMAP (B)

### Densidade

- Judgment **200–600**
- Section stays thin; fail if Root monólito

### Fora de escopo

- App Group / widget **data** restore  
- New Route Session Hub  
- Core live API  
- Arena regression badge Home  
- Home pill free-write intention (Cursor-port blocked)  
- Micro tipografia / fuse-as-WAVE  
- Re-rank LiveTimeline chrono (sacred 042/044)  

### §5

`nenhum` — snapshots publicados.

---

## DoD produto (≥5)

- [ ] `LiveNowJudgment.rank` é a **única** ordem de atenção (section usa).
- [ ] Deep-link "Seguir" abre **head ranked com threadId** (não chrono last).
- [ ] Sem live threadable → home silence (não inventa thread).
- [ ] Home pack live anchors seguem rank + face product words quando mapeáveis.
- [ ] Merge local/remote honest (remote flag preserved).
- [ ] Spoken section ≡ Judgment (hub/single/count).
- [ ] Gates + CODEMAP "live now attention" (B).
- [ ] DEVICE_PENDING se passcode.

## Anti-objetivos

- inventar sessões  
- App Group fields  
- tipografia  
- fuse multi-domínio  
- reabrir free-write pill  

## Plano W3

1. Extract merge+rank+head from LiveNowSection → Judgment.  
2. Wire section.  
3. Wire deep-link.  
4. Wire HomeAskContext.  
5. Delete dual chrono path (rg prova).  
6. CODEMAP (B).  
7. Estimativa: **~6–9 files · ~300–550 LOC**.

## Proof / device

1. 2+ live (running + finished) → hub shows running first; pack same.  
2. Deep-link with multi live → opens same thread as row #1 com threadId.  
3. Only finished remote → ranked finished; open if threadId.  
4. Empty live → no section; deep-link stays home.  
5. DEVICE_PENDING se passcode.

## Council (2026-07-21 · ≥3 explore)

**Conversa/Home:** #1 residual max = LiveNow triple dialect (section /
deep-link / pack).  
**Código/Arena:** multi-area bind + arena now phase = WAVEs irmãs.  
**WAVE-063** change-review sheet load = open high (paralela).  
**WAVE-062** ask-pill done.

### Runner-ups (não esta)

1. `autonomos-multi-area-bind-chooser` → WAVE-065  
2. `arena-now-phase-judgment`  
3. `codigo-radar-screen-judgment`  
4. `conversation-steer-composer-one-voice` leftovers  

---

*End WAVE-064 design.*
