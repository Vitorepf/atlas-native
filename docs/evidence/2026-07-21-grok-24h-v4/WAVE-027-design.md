# WAVE-027 — conversation-presence-primary-chrome

**Status:** design · proposed  
**Wave:** `WAVE-027-conversation-presence-primary-chrome`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- WAVE-018 (glance) + WAVE-022 (ribbon face) + WAVE-023 (strip / StateCard /
  LiveNow **adapters**) criaram a **máquina de face**
  (`ConversationExecutionFace`: finished · reconnect · paused · multi ·
  running · quiet) — mas o **chrome primário** que o olho lê ainda é dialeto.
- **StateCard** (`ExecutionStateCard.swift` ~664 LOC): kicker primário ainda
  é `state.title` (servidor); `presenceFace.productWord` fica terciário —
  operator reaprende a fase no card.
- **LiveNowRow**: linha visual principal ainda é `session.phaseTitle` raw;
  só `timingWord` usa spokenFace — hub Home fala dialecto paralelo ao strip.
- **Composer honesty hole:** `ConversationComposer.liveBubble` =
  `model.bubbles.last(where: { $0.streaming })` — **streaming-only**.
  Run paused / reconnect / decision-required / recovering **sem stream** some
  do strip enquanto hub/LiveNow ainda mostram o run → **mentira de quiet**.
- **AgentRow** (`ConversationCockpitBody`): `statusWord` = processando / na
  fila / … — dialeto de agente paralelo à face multi/running.
- **Ribbon gate** some quando `!streaming` mesmo com execution presence
  ongoing → sink e footer divergem.
- WAVE-012 dual-surface (strip owns reconnect primary while streaming) é
  pétreo — esta onda **preserva**, não reabre.
- Continuity App Group / widgets **data** permanecem BLOCKED; glance adapter
  table é só honesty de mapeamento (reconnect/quiet → o que glance tem).

## Patamar

| Antes | Depois |
|---|---|
| Face adapters + primary title soup | **Primary kicker = face words** em strip/card/LiveNow |
| Composer strip some pós-stream | Strip segue **presence-ongoing** (não só streaming) |
| Agent lanes re-ensinam status | Agent vocabulary sob face/attention ou silence |
| Hub phaseTitle ≠ in-app face | phaseTitle demoted a detail; face line lead |
| Glance paralelo sem tabela | Adapter table explícita glance ↔ face |

Δ = operador **julga a fase do run** em ≤5s em qualquer superfície de
atenção in-app (composer · sink · hub) com **uma** língua primária.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** Presentation from `ChatBubble`,
  `executionPresentationState`, `LiveSessionSnapshot`, ContentState.
- **One primary vocabulary:** spokenFace / productWord no **lead** chrome;
  server title/phaseTitle = **detail secondary** only.
- **Presence-ongoing selection:** composer live bubble / strip selection
  alinha a `executionPresence.isOngoing` / `currentPresenceBubble` (ou
  equivalente já no model) — **não** inventar campo Core.
- **WAVE-012 dual-surface pétreo:** streaming+reconnect → strip primary;
  ribbon silences reconnect primary copy.
- **Attention overlays** (023): awaiting · recovering · replanning · failed ·
  decision — nunca viram faces.
- Densidade agent-optimal: StateCard fuse seções, não god-concat.

### Fluxo / layout alvo

```
Selection: presenceBubble = last ongoing (trace + executionPresence)
           fallback streaming

Strip / StateCard header / LiveNow lead line
  → ConversationExecutionPhase.spokenFace(face)  [PRIMARY]
  → title / phaseTitle / progress                   [DETAIL]

AgentRow under multi/running
  → map through attention/face OR silence raw dialect

Glance (read-only map)
  → finished|multi|paused|running; reconnect/quiet honesty note
```

### Tipos / módulos a criar ou elevar

| Nome | Papel |
|---|---|
| `ConversationPresenceJudgment` **or** grow `ConversationExecutionPhase` | primary label helpers + ongoing selection pure |
| `ConversationExecutionFace` / `Attention` | already — consumers only |
| Glance adapter table | map face → glance face + honesty absences |

### Arquivos prováveis

- `ConversationExecutionPhase.swift` — helpers primaryLabel / ongoing predicate
- `ConversationComposer.swift` + `ConversationComposerBody.swift` — liveBubble
- `ConversationCockpitBody.swift` — ExecutingStrip + AgentRow
- `ExecutionStateCard.swift` — primary header = face
- `ExecutionRibbon.swift` — gate honesty with ongoing (preserve 012)
- `LiveNowRow.swift` / `LiveNowSection.swift` — lead face line
- `EditorialTurn.swift` — ribbon/card order if needed
- Widgets glance grammar **only** if adapter table lives there (chrome only)
- A11y spoken ≡ face

### Densidade alvo

- Shell/View rota Conversation ≤600
- Judgment/Phase **200–800**
- StateCard surface **≤1500** (hoje ~664 — fuse seções, fail se >2000)
- Não empurrar ConversationSurface monólito multi-domínio

### Fora de escopo

- App Group Continuity data / widget restore
- Core execution DTO novo
- Re-chrome pill 016
- WAVE-028 conversation occasion pack (entrada de thread — onda separada)
- Mandar-fazer tool write
- Nova tab

### §5 Core

`nenhum` se `executionPresence` / bubble fields já publicam ongoing.  
§5 só se ongoing **não** existir no model e a casca precisaria inventar —
nesse caso documentar absence e usar o melhor signal publicado (não inventar).

---

## DoD produto (≥5 checkboxes casca-prováveis)

- [ ] Primary kicker visual em strip, StateCard header e LiveNow lead usa
      **face product words** (spokenFace); title/phaseTitle só detail.
- [ ] Composer seleciona bubble **presence-ongoing**, não apenas streaming;
      paused/reconnect/decision mantêm strip quando signal existe.
- [ ] WAVE-012 dual-surface reconnect preservado (strip primary, ribbon
      silence reconnect copy).
- [ ] AgentRow status sob multi/running mapeia face/attention ou silencia
      dialeto paralelo confuso.
- [ ] Tabela/adapters glance ↔ ConversationExecutionFace documentados no
      código (reconnect/quiet honesty; sem inventar ContentState).
- [ ] A11y spoken ≡ visual face em strip/card/LiveNow.
- [ ] Timer honesty residual: never false 0:00 (parity 018/023).
- [ ] Gates + CODEMAP "presence primary" se topologia mudar.

## Anti-objetivos (B não deve)

- micro-onda tipografia / opacity
- fuse multi-domínio (Conversation + Arena monólito)
- inventar App Group / ContentState fields
- segundo enum de face sem adapter (anti-023)
- fuse-only StateCard peels **sem** DoD de primary face
- colapsar Shell >600
- reabrir WAVE-023 compress como "done" sem primary chrome
- claim Continuity restore

## Plano W3 — código GOD (ordem)

1. **Extract/elevate** primaryLabel + ongoing selection em
   `ConversationExecutionPhase` / `ConversationPresenceJudgment`.
2. **Rename honesty** nos kickers (title→detail, face→primary) + MARKs
   canônicos em StateCard denso.
3. **Wire** composer liveBubble, strip, LiveNow lead, AgentRow.
4. **Fuse** só seções do mesmo domínio presence no StateCard (não multi-world).
5. **Delete** morto: ramos bool-soup que duplicam face (rg prova).
6. B atualiza CODEMAP.
7. Estimativa: **~7–11 arquivos · ~350–700 LOC estrutural** (selection +
   primary chrome + a11y + residual fuse) — ≥300 estrutural e multi-superfície.

## Proof / device

1. Run streaming → strip + card + LiveNow mesma face word.
2. Pausar / reconnect / decision (signals reais) → strip **permanece**;
   composer não finge quiet.
3. Multi-agent → face multi; agent lanes não gritam dialeto oposto.
4. Finished → silence reconnect/watchdog noise (023 law).
5. DEVICE_PENDING se passcode.

## Council

**Conversa/Pílula explore:** residual #1 = presence **primary chrome** após
adapters 023; sharpest lie = streaming-only `liveBubble`.  
**Código explore:** eixos Radar/Grafo — não compete.  
**Arena/Home explore:** arena-live e home-ops são GOD noutros domínios;
presence in-app é o órgão **write→fly→read→judge** da conversa.  
Δ **high** (não max): max reservado a soberania de assinatura (WAVE-026
decisões Autônomos); este fecha o órgão de presença que 023 deixou com
adapters sem voz primária unificada.
