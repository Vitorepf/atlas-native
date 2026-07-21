# WAVE-029 — conversation-occasion-pack-honesty

**Status:** design · proposed  
**Wave:** `WAVE-029-conversation-occasion-pack-honesty`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v5 · council ≥3 explore)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- Lei da pílula / pack (WAVE-020 + `atlas-native-agentic-pill.md`): contexto =
  **ocasião da superfície ativa** — surface · subject · anchors · facts ·
  absences · can_do. Misturar mundo = resposta no mundo errado.
- Live residual explícito em `RootChromeFace.swift` (~397):
  `rootConversationThreadDestination` passa
  `turnFacts: { HomeAskContext.facts(session:) }` para **toda** thread
  aberta a partir da Home — pack = **"partida do operador"** no meio da
  conversa. Comentário no código: **"WAVE-020 residual"**.
- Abrir thread via LiveNow / Search / deep link de execução tende ao mesmo
  sink se reusa o destination Home — **mentira de ocasião**.
- Home/Workspace packs embutem anchors `live · title · phaseTitle` **raw**
  (`HomeAskContext`, `WorkspaceAskContext`) — não face product words
  (027 fecha chrome; esta onda fecha **pack anchors** honesty).
- Thread path muitas vezes **sem** emptyPrompt/suggestions (ok se lista
  cheia) mas turnFacts **ainda** deve ser occasion-true para o próximo
  send / sheet ask se existir.
- Radar residual menor: invite estático vs emptyPrompt(headline) —
  WAVE-002 law invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts **só
  quando** empty path; opcional se tocar pack law na mesma passagem.
- Não é re-chrome dock (016). Não é presence visual primary (027). É o
  **órgão de inteligência de entrada** da conversa.

## Patamar

| Antes | Depois |
|---|---|
| Thread open = pack Home partida | Thread open = **pack conversation** (título/id · live face · workspace) |
| Live anchors phaseTitle cru | Anchors usam **face product words** quando mapeáveis |
| New home/workspace ok 020 | Mantém hosts; mid-thread **nunca** finge partida |
| Residual WAVE-020 no código | Residual fechado com Pack nomeado |
| Agente julga mundo errado | Agente responde no **mundo da thread** |

Δ = honesty de ocasião: o operador (e o agente) **sabem em que conversa
estão** — pack não mente "partida home" no meio do fio.

---

## Arquitetura (croqui para B)

### Princípios

- **Casca only.** Compila pack de dados já no `AtlasSession` /
  `TurnPresence` / route params (threadId, title, workspace key).
- **Occasion purity:** `surface: conversation` (ou `conversation.workspace`)
  mid-thread; `surface: home` **somente** partida Home nova.
- **WAVE-002 law:** onde empty UI existe, invite ≡ emptyPrompt ≡
  suggestions ≡ turnFacts same occasion.
- **can_do honesty:** `readChat` + face CTAs (stop/steer/queue) se strip
  vivo; never NL write claim.
- **Pack never on pill face** (016).
- Um domínio: Conversation pack helpers — não misturar Arena scores.

### Fluxo / layout alvo

```
Route.thread(id, title)
  → ConversationView.turnFacts =
      ConversationOccasionPack.compile(
        threadId, title,
        workspaceKey?,
        live: TurnPresence matching thread,
        canDo from presence CTAs
      )

Route.new / Home input
  → HomeAskContext (020) unchanged for partida

Route.workspace → new thread
  → WorkspaceAskContext

LiveNow tap → thread destination
  → same ConversationOccasionPack (not Home)
```

### Tipos / módulos a criar ou elevar

| Nome | Papel |
|---|---|
| `ConversationOccasionPack` / `ThreadAskContext` | compiler pure → `AgenticOccasionPack` |
| Existing hosts | `HomeAskContext`, `WorkspaceAskContext` — **não** usá-los como universal facts |
| `AgenticOccasionPack` | shape only — already |

### Arquivos prováveis

- `ConversationOccasionPack.swift` or `ThreadAskContext.swift` (**new**)
- `RootChromeFace.swift` — thread destination turnFacts
- `RootHomeFace.swift` / navigation LiveNow open paths
- `SearchView` / deep link paths that open threads (if they inject Home pack)
- `HomeAskContext.swift` / `WorkspaceAskContext.swift` — live anchor face words
- `ConversationView` call sites only (wire, no model logic)
- Optional Radar invite/emptyPrompt align if touched
- CODEMAP "conversation pack entry"

### Densidade alvo

- Pack/Grammar **200–800**
- Root chrome extensions: keep shell ≤600; extract pack out of Face if
  Face densifies
- Zero monólito multi-domínio

### Fora de escopo

- Presence **visual** primary chrome (WAVE-027) — coord vocabulary only
- Core typed pack schema / tool write
- Re-chrome AgenticPill face
- App Group Continuity
- Autônomos/Arena pack rewrite (hosts already 020)
- Nova área / Labs

### §5 Core

`nenhum`. Tudo presentation compile de session + route + TurnPresence.  
Se thread workspace key não estiver no route, absence honesta — não inventar.

---

## DoD produto (≥5 checkboxes casca-prováveis)

- [ ] `Route.thread` turnFacts = `surface: conversation` (ou workspace-scoped),
      subject = title/id — **não** `HomeAskContext.facts` blind.
- [ ] LiveNow → thread e Search → thread usam o **mesmo** compiler de ocasião
      (parity).
- [ ] Home **new** / input partida mantém `HomeAskContext`; workspace new
      mantém `WorkspaceAskContext`.
- [ ] Live anchors no pack usam face product words quando
      `ConversationExecutionPhase` mapeia o snapshot; senão detail secondary.
- [ ] `can_do` declara read_chat (+ face CTA honesty se presence ongoing);
      zero claim mandar-fazer NL.
- [ ] Onde empty path existe: invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts.
- [ ] Pack nunca na cara da pílula; 016 dock intacto.
- [ ] Gates + CODEMAP; residual comment WAVE-020 em RootChromeFace removido
      porque fechado.

## Anti-objetivos (B não deve)

- micro copy / opacity
- dump model JSON no pack
- inventar scores Arena / backlog Autônomos no pack de conversa
- App Group data
- colapsar Root monólito multi-domínio
- reimplementar presence visual 027 dentro desta onda
- fuse-as-WAVE peels
- fingir Core pack tipado "done"

## Plano W3 — código GOD (ordem)

1. **Extract** `ConversationOccasionPack` / `ThreadAskContext` (pure compile).
2. **Rename honesty** — hosts não são "universal facts".
3. **Wire** all thread open sites (Root, LiveNow, Search, deep links).
4. **Align** Home/Workspace live anchors face words (small, same pack law).
5. **Delete** Home-as-thread-facts misuse (rg: `HomeAskContext.facts` só
   partida).
6. B atualiza CODEMAP.
7. Estimativa: **~5–9 arquivos · ~300–550 LOC estrutural** — escala por
   multi-entry honesty + shared compiler (DoD≥5, ≥3 entry surfaces).

## Proof / device

1. Home → open existing thread → ask/send: pack/texto de ocasião **não**
   diz "partida do operador" / surface home.
2. LiveNow → thread: pack subject = thread title; live face se houver.
3. Home new conversation: pack home partida **preservado**.
4. Workspace new: pack workspace.
5. DEVICE_PENDING se passcode; senão inspect turnFacts path em debug/log
   presentation se disponível.

## Council

**Conversa/Pílula explore:** residual #2 GOD = **conversation occasion pack**
(thread open ainda Home partida — mentira de mundo). Residual #1 presence
primary = WAVE-027 (eixo visual).  
**Código explore:** GraphJudgment = WAVE-028.  
**Arena/Home explore:** home-ops directory mute é real mas **menor** que
pack mentindo mid-thread (corrupção de inteligência agêntica).  
Δ **high**: fecha residual WAVE-020 nomeado no código; multi-entry
surfaces; casca-only; anti-micro.
