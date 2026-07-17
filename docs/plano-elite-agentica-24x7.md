# Atlas Native — Plano Elite Agêntica 24×7

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `superpowers:subagent-driven-development` (recommended) or
> `superpowers:executing-plans`. Tasks use checkbox syntax. Design canon:
> `docs/superpowers/specs/2026-07-17-elite-agentica-24x7-design.md`.

**Goal:** Fechar tudo que ainda falta no Atlas Native, depois comprimir o
código ao máximo, depois aprofundar o que já existe até o patamar elite da
era agêntica, depois comprimir de novo — em loop contínuo 24×7 — sem criar
nenhuma rota nova dentro do app, com liberdade total fora do app
(Island / lock / widgets / notifs), sob a doutrina **humano fora do fluxo
operacional**.

**Architecture:** Atlas Server = cérebro. AtlasCore = contratos tipados
fail-closed. Models `@Observable` = único seam da casca. SwiftUI projeta.
ActivityKit/WidgetKit/UNUserNotification = presença fora do app via App
Group snapshot + ContentState. Autônomos e Arena são rotas próprias já
existentes; Session Hub = deepen de `LiveNowSection`, nunca rota nova.

**Tech Stack:** Swift 6, SwiftUI, Observation, ActivityKit, WidgetKit,
App Intents (mecânicos), UserNotifications, XCTest/XCUITest, Laravel
Atlas Server. Zero dependência nova sem decisão §6.

## Global Constraints

- **Zero `Route` cases novos.** Enum fecha em 9 (`.arena` já existe).
- **Fora do app: criar todas as variações honestas** (ver Onda F).
- **Humano fora do fluxo ops:** sem “Aprovar” plumbing; veto com recibo;
  `ator+motivo` só no start governado.
- **Criação ≠ Medição:** UI/código nativo = Arena, nunca Rivals.
- **Ausência de contrato = ausência de UI.**
- **Ciclo obrigatório:** A Implementar → B Comprimir → C Aprofundar →
  D Comprimir → (repete C↔D).
- **Gates:** `env -u ATLAS_LIVE swift run AtlasCoreChecks` +
  `cd App && make build` + `git diff --check` antes de cada commit.
- **Commits escopados** `feat|fix|polish|docs(obra)` · stage arquivos
  explícitos · OBRA §7 append com prova.
- **Device:** se `passcodeRequired`, registrar `device-pending` (dono
  operador) e seguir; nunca fingir DEVICE_PROVEN.
- **Voice / Onda 9 / §B SKIP (M27/M41/M53/M60/M82):** não tocar sem
  decisão explícita do operador.

---

## Ordem mestra dos ciclos

```
┌─────────────────────────────────────────────────────────────┐
│  CICLO A — FECHAR O QUE FALTA (implementar)                 │
│    A0 Doutrina · A1 Honestidade · A2 Arena · A3 Contratos   │
│    A4 Casca deepen · A5 Fora-do-app · A6 Device             │
├─────────────────────────────────────────────────────────────┤
│  CICLO B — COMPRESSÃO 1 (refatorar / eliminar linhas)       │
│    B1 Split monólitos · B2 Dedup · B3 Delete · B4 Goldens   │
├─────────────────────────────────────────────────────────────┤
│  CICLO C — APROFUNDAR / NOVOS PATAMARES                     │
│    C1 Conversa elite · C2 Autônomos CC · C3 Arena depth     │
│    C4 Código · C5 Presença total · C6 Perf pós-M03          │
├─────────────────────────────────────────────────────────────┤
│  CICLO D — COMPRESSÃO 2 (mesmo rigor de B, meta mais dura)  │
│    D1 Re-split · D2 Saldo líquido negativo · D3 Solidificar │
└─────────────────────────────────────────────────────────────┘
         ▲                                           │
         └─────────── repetir C ↔ D ─────────────────┘
```

**Regra de passagem:** um ciclo só abre quando o anterior tem §7 com
prova e zero mentira de “DONE” sem evidência.

---

## File ownership map (relembrar)

| Área | Dono típico | Paths |
|---|---|---|
| Core / contracts / checks | FUNCIONA | `Sources/AtlasCore/**`, `Sources/AtlasCoreChecks/**` |
| Models | FUNCIONA | `App/Atlas/*Model*.swift`, `AtlasSession.swift` |
| Casca / design system | CASCA | `App/Atlas/*View*.swift`, Theme/Type/Motion, Assets |
| Widgets / LA | CASCA + seam Core | `App/Widgets/**`, `TurnPresence`, `AtlasActivityAttributes` |
| Server | FUNCIONA | `../atlas-server` só quando §5 exigir |
| Blackboard | ambos | `OBRA.md` append §4/§5/§6/§7 |

---

# CICLO A — FECHAR O QUE FALTA

## Onda A0 — Doutrina no blackboard

### Task A0.1: Canon “humano fora do fluxo” em OBRA

**Files:**
- Modify: `OBRA.md` (§0 ou §3 + §6)
- Reference: `docs/superpowers/specs/2026-07-17-elite-agentica-24x7-design.md`

- [ ] **Step 1:** Append em §6 a decisão do operador deste plano (zero rotas
  novas; fora-do-app livre; ciclo A→B→C→D; humano fora do fluxo ops).
- [ ] **Step 2:** Em §3 (anti-inchaço) ou §0, adicionar bullet canônico:
  Autonomia > aprovação; silêncio = produto; assinatura ≠ approve ops.
- [ ] **Step 3:** Em §4, criar fila **Elite 24×7** apontando para este plano
  com status das ondas A0…D.
- [ ] **Step 4:** Commit `docs(obra): canon elite 24x7 + humano fora do fluxo`

---

## Onda A1 — Honestidade de produto (P0)

Fecha mentiras estruturais antes de polir.

### Task A1.1: M01 heal → merge (ou heal-receipt)

**Files:**
- Server: stewardship heal/merge path (descobrir em `atlas-server`)
- Modify: `Sources/AtlasCore/AtlasAutonomos.swift` (ou DTO delivered)
- Modify: `App/Atlas/SelfConstructionReceiptSheet.swift`
- Test: PHPUnit + `AtlasAutonomosChecks` / Core checks
- Evidence: `docs/evidence/2026-07-17-onda0/` (append)

**Interfaces:**
- Consumes: healer R2 resultado real
- Produces: ciclo com `outcome=merged` + `merge_hash` **ou** contrato
  `heal-receipt` separado de `/done` — NUNCA fabricar merge fields

- [ ] **Step 1:** Probe atual `GET …/atlas-native/done` → documentar
  `delivered_total` e ledger.
- [ ] **Step 2:** TDD server: pós-heal governado grava merge real **ou**
  emite heal-receipt tipado com `merge_performed=false` explícito + campos
  públicos.
- [ ] **Step 3:** Decode Core fail-closed + casca mostra recibo só com dados
  reais (“O ATLAS MELHOROU…” somente se merge/ledger existir).
- [ ] **Step 4:** Gates + §7 + fechar §5 M01/V3 ou deixar ABERTO honesto se
  server bloqueado.

### Task A1.2: Arena worker → scoreboard (M61/A12)

**Files:**
- Server: worker de medição / queue rivals→arena
- Modify: recibo `worker_implemented` path
- Evidence: `docs/evidence/2026-07-17-arena/`

- [ ] **Step 1:** Reproduzir POST app → `runs/live` queued +
  `worker_implemented=false`.
- [ ] **Step 2:** Implementar drenagem real `queued→running→done` sem
  progresso simulado.
- [ ] **Step 3:** Provar scoreboard/composite atualizam após run do app.
- [ ] **Step 4:** Atualizar §5 M61/A12 → FEITO com prova; PT-M61 evidence.

### Task A1.3: Deep links honestos (widgets não mentem)

**Files:**
- Modify: `App/Atlas/RootView.swift` (`onOpenURL`)
- Modify: `App/Widgets/AtlasWidgets.swift` (URLs emitidas)
- Test: XCUITest ou unit de parsing de URL

- [ ] **Step 1:** Handler `atlas://autonomos` → `Route.autonomos`.
- [ ] **Step 2:** Handler `atlas://execution` (sem path) → Home LiveNow /
  última sessão viva (sem inventar thread).
- [ ] **Step 3:** Manter `atlas://execution/<trace>` e `atlas://code/<repo>`.
- [ ] **Step 4:** Gates + evidência.

---

## Onda A2 — Arena Continuity (fora do app)

### Task A2.1: Live Activity dedicada Arena (M61/A10)

**Files:**
- Create: `App/Atlas/AtlasArenaAttributes.swift` (ou extensão tipada)
- Modify: `App/Widgets/AtlasWidgets.swift`
- Modify: `App/Atlas/ArenaModel.swift` / Now section (“Seguir”)
- Core: campos públicos de `AtlasArenaLiveRun` se faltarem
- §5: fechar M61/A10

**Interfaces:**
- ContentState mínimo: `suite`, `engine`, `arm`, `casesCurrent`,
  `casesTotal`, `phase`, `startedAt`, `finished`
- **Não** reusar mentindo `AtlasTurnAttributes` de conversa

- [ ] **Step 1:** Golden Core para atributos/estado Arena.
- [ ] **Step 2:** ActivityConfiguration + Island variants RUN/Q/OK/FAIL.
- [ ] **Step 3:** Long-press “Seguir” em AGORA inicia LA; terminal encerra.
- [ ] **Step 4:** XCUITest/sim + §7 (device-pending se passcode).

### Task A2.2: App Intents mecânicos LA (M89)

**Files:**
- Create: intents mínimos em target app/widgets
- Modify: `AtlasWidgets` lock buttons
- Map **somente** ações reais (`cancel`/`retry`/`choice` de
  `presentationState.actions`)

- [ ] **Step 1:** Sem ação tipada = sem botão.
- [ ] **Step 2:** Parar / Retomar / Escolher… → model existente.
- [ ] **Step 3:** Checks + build; §5 M89.

---

## Onda A3 — Contratos §5 que destravam casca

Executar em parallel tracks quando independente. Cada contrato: TDD
server → Core decode → **zero UI inventada** até payload existir.

### Task A3.1: Pack Continuity / notif

- [ ] C9 TurnNotifier no finalize quando app ≠ `.active`
- [ ] M65 categoria texto + `thread_id` → `queue(text:)` seguro
- [ ] M04 APNs: documentar vault; se credenciais ausentes, §5 ABERTO
  (não simular)

### Task A3.2: Pack Autônomos / digest

- [ ] C19 / `next_digest_at` + digest por janela
- [ ] M12 abrir instância (só se contrato server; senão sem affordance)
- [ ] C13 finding decide copy + rationale high/critical

### Task A3.3: Pack AX / execução

- [ ] C18 `changeAxes` no recibo de conclusão
- [ ] C20 `agentVerdicts` / consensus cena 07
- [ ] Diff ao vivo pílula (server já tem `diff_stats` em parte — fechar
  decode+binding)
- [ ] Plan revisions “comparar versões” fiel (C21 / cena 02)

### Task A3.4: Pack payloads aditivos (M98+)

- [ ] Implementar **somente** endpoints/campos listados em §5
  M98/M100/M106/M107/M109/M112/M116/M126/M134/M140/M160 quando server
  puder; cada um com golden; UI sob CICLO C.

### Task A3.5: Pack Code

- [ ] M35 TreeSitter `grammar_missing` fail-closed
- [ ] M105 campo `agent` no grafo (se server)

---

## Onda A4 — Deepen casca (sem rota nova)

### Task A4.1: Execução Viva — fidelidade nas superfícies existentes

**Files:** `ConversationView`, `ConversationChrome`, `ConversationCockpit`,
`PlanCard`, `ExecutionStateCard`, `LiveTimeline`, `ChangeReviewView`,
`ArtifactSheet` — **split se >200** antes de crescer.

- [ ] Cenas 01–05, 07, 10–13: cards/ações só de
  `AtlasExecutionPresentationState` + model actions reais
- [ ] Cena 11 fila: prova XCUITest promote/remove/FIFO
- [ ] Cena 08 Continuity: `ConversationModel+Continuity` + recibo visual +
  deep link (sem Session Hub route)
- [ ] Session Hub = expandir `LiveNowSection` (multi-session, timers,
  phase, plan) — **não** criar `SessionHubView` route

### Task A4.2: Autônomos Command Center fidelity

**Files:** split `AutonomosView.swift` (1153) **antes** de adicionar UI

- [ ] Extrair `AutonomosFleetSection`, `AutonomosAreaDetail`,
  `AutonomosTaskHealth`, sheets
- [ ] Transfer UI + frota global + digest (dados reais)
- [ ] Silêncio quando saudável; alerta só por exceção

### Task A4.3: Código deepen (contratos existentes)

- [ ] Provenance/Why/Heal/Radar polish sem nova rota
- [ ] Fechar gaps H* já contratados; sem botão Approve

### Task A4.4: Arena deepen in-app

- [ ] Cobertura parcial honesta; suite sem adapter invisível no run sheet
- [ ] Estados loading / domínio ausente / stale selo

### Task A4.5: Fidelity matrix (processo)

**Files:**
- Create: `docs/fable-5-fidelity-matrix.md`

- [ ] Mapear cenas 01–08, 10–13 + Fleet + Island → model → view → teste →
  evidência → gap
- [ ] Voice marcada EXCLUÍDA

---

## Onda A5 — Fora do app (liberdade total)

Catalogar e implementar por domínio. Cada variante: dado real no
snapshot/ContentState ou **não renderiza**.

### Task A5.1: Snapshot completeness

**Files:** `Sources/AtlasCore/AtlasNativeSnapshot.swift`,
`App/Atlas/AtlasNativeSnapshotWriter.swift`

- [ ] Garantir writers: live_sessions, fleet, week, queued_count,
  arena-follow summary (se LA Arena)
- [ ] Fail-closed schema; staleness >6h visível
- [ ] Privacy: nada sensível no App Group

### Task A5.2: Widgets

- [ ] Fix W-L* (sessão) URLs
- [ ] M84 Semana do Código (ler `week` já escrito)
- [ ] W-A* Arena medium (opcional, se snapshot tiver follow)
- [ ] W-C4 exception-only code chip (silêncio se 0)
- [ ] Families S/M/L conforme especificado; Reduce Motion ok

### Task A5.3: Lock accessories

- [ ] A-C* circular: N sessions + attention + fleet incident
- [ ] A-R* rectangular: timer / ‖ / N/M / stale / fleet one-liner
- [ ] A-I* inline: silence / N / atenção / frota / arena

### Task A5.4: Live Activity + Dynamic Island (CONV)

- [ ] SD-2 completo: RUN/PROG/QUEUE/REC/REPL/EXT/ATT/PLAN/OK/FAIL/CXL
- [ ] Compact trailing `N/M` quando progresso real
- [ ] ⚠ attention; ✕ fail; ✓ finish ~5s
- [ ] M88 multi-session expanded list (follow)
- [ ] M123 share-safe minimal glyph

### Task A5.5: Live Activity FLEET / CODE

- [ ] LA-F-* missão / attention / handoff / entrega (só com Seguir ou
  exceção)
- [ ] LA-C-* heal em curso / curado / finding high (silêncio default)

### Task A5.6: Notificações

- [ ] N-T-* turn ok/fail/att + rich/grouping após M04/M65
- [ ] N-F-* / N-C-* exception-only
- [ ] N-A-DONE se Arena followed
- [ ] Nunca spam de trabalho saudável

### Task A5.7: System presence

- [ ] M91 StandBy (após LA estável)
- [ ] M92 Controls → cockpit / seguir
- [ ] M155 alternate icons (se operador autorizar arte)
- [ ] Share Extension → composer existente (Continuity, sem Route)

---

## Onda A6 — Device / operador (P1)

Não bloqueia o restante do plano, mas fecha mentiras “shipped”.

### Task A6.1: Roteiro operador

- [ ] Desbloquear iPhone (`passcodeRequired=false`)
- [ ] Rodar `make device` + C7 harness
- [ ] Prints U1–U10 + Arena E2E + widgets/Island
- [ ] M03 Instruments baseline → desbloqueia Onda C6
- [ ] M04 APNs vault
- [ ] Atualizar §4 vermelho M81 se >7d

---

# CICLO B — COMPRESSÃO 1

**Meta:** saldo líquido de linhas **negativo**; Model <800; views ~200;
nenhum arquivo Codex/Fable >400 sem justificativa §7.

### Task B1.1: Split AutonomosView (1153)

- [ ] Extrair seções/sheets em arquivos ≤250
- [ ] Build verde; comportamento idêntico (XCUITest Autônomos se existir)

### Task B1.2: Split AtlasAutonomos Core (1010)

- [ ] Módulos por superfície (fleet/backlog/digest/control/…)
- [ ] Goldens intactos

### Task B1.3: ConversationModel <800

- [ ] Peels adicionais (`+Execution`, `+Queue`, …)
- [ ] Medir linhas; §7

### Task B1.4: ConversationView / Chrome / RootView / Radar / ChangeReview

- [ ] Cada um ≤ alvo §3; zero mudança visual intencional

### Task B1.5: Dedup chrome

- [ ] LoadPhase failed/loading compartilhado
- [ ] SectionHeader mono
- [ ] ButtonStyles → Theme
- [ ] SheetShell universal

### Task B1.6: Delete

- [ ] UI morta / stubs sem contrato
- [ ] Comentários inglês órfãos (M36–M38 se caber)
- [ ] Re-grep 0 refs após delete

### Task B1.7: Reliability solidify

- [ ] Goldens para todo DTO tocado
- [ ] Boundary check: zero `/ai/uploads` fora do engine
- [ ] `make verify` (M78) verde no que for possível sem device

### Task B1.8: Registro de compressão

- [ ] §7 com `wc -l` before/after top-20
- [ ] Só então abrir CICLO C

---

# CICLO C — APROFUNDAR / NOVOS PATAMARES

Princípio: **profundidade nas 9 rotas + presença fora do app**, nunca
largura de telas.

## Onda C1 — Conversa elite

- [ ] M97/M101/M103/M127–M131/M143–M144/M150–M152 (quando contrato)
- [ ] Path quality, escalation, drafts, cite reply, tool heatmap
- [ ] Zero botão falso; Reduce Motion / Dynamic Type

## Onda C2 — Autônomos CC elite

- [ ] M115/M117/M138 digest history / incident drill / ensaio×execução
- [ ] Mission templates; frota como sistema nervoso 24/7
- [ ] Copy: “você não foi necessário” quando heal/merge real

## Onda C3 — Arena depth

- [ ] Após A12: séries históricas, capabilities profiles, sparklines
- [ ] Seguir medição KPI Island 0 taps / 0 hitches (operador)

## Onda C4 — Código elite

- [ ] M104/M108/M110/M111/M133/M135/M136 pan/zoom, mirror timeline,
  bio filters, minimap, blame v2, tags
- [ ] Sem Approve; veto only

## Onda C5 — Presença total (fora do app)

- [ ] Completar catálogo A5 que sobrou
- [ ] Multi-domínio Island: CONV + FLEET + ARENA coexistindo
  (um followed por vez se plataforma limitar)
- [ ] Notificação como cockpit: rich, group, reply→fila

## Onda C6 — Perf (só após M03)

- [ ] M28–M34 com baseline Instruments
- [ ] Sem claim de perf sem número

## Onda C7 — Patamares novos (ainda sem rota)

Propostas só como **sheets/seções/fora-do-app**:

- [ ] “Modo elite” densificação (já M125) + export audit
- [ ] Critério aprendido de wake-up (P9 endgame): sempre visível, nunca
  auto-decidir em silêncio
- [ ] Qualquer ideia que peça `case` novo em `Route` → **rejeitar** e
  redesenhar como deepen

---

# CICLO D — COMPRESSÃO 2

Mesmas regras de B, meta mais dura:

- [ ] Top-20 arquivos: nenhum view >250 sem ADR §6
- [ ] Saldo líquido do ciclo C deve ser **compensado** em D (delete ≥
  60% das linhas adicionadas em C, ou justificar)
- [ ] Re-auditar Observation scope, Equatable, LazyVStack
- [ ] Scanner constituição R2 triage (M36–M38)
- [ ] §7 medição + abrir próximo C

---

## Coverage matrix (o que o plano ataca)

| Origem da dívida | Onde fecha |
|---|---|
| Fable U1–U10 prints | A6 |
| Fable cenas / fidelity | A4.1 + A4.5 |
| PT M01 / V3 | A1.1 |
| PT-M61 Arena | A1.2 + A2 + C3 |
| §5 contratos abertos | A3 |
| Session Hub | A4.1 (LiveNow deepen) |
| Continuity / APNs | A3.1 + A5 + A6 |
| Fora-do-app elite | A5 + C5 |
| Anti-inchaço / SOTA regressão Model 885 | B + D |
| Profundidade M-items restantes | C* |
| Humano fora do fluxo | A0 + copy em C2 |
| Voice / Onda9 / §B SKIP | Fora (E) |

---

## Agent operating protocol (24×7)

1. Ler `OBRA.md` inteiro + este plano + design.
2. Pegar a **primeira** task unchecked da onda aberta.
3. Claim em §4 (Elite 24×7).
4. TDD quando Core/server; casca só após seam.
5. Gates verdes → commit escopado → §7 prova → checkbox.
6. Se bloqueio externo (passcode, APNs vault, worker host): §5 ABERTO +
   pular para próxima task **desbloqueada**.
7. Ao fechar onda: não abrir a próxima se compressão B/D estiver
   pendente na passagem de ciclo.
8. Preferir **subagent-driven-development**: 1 subagente por task +
   review entre tasks.
9. Nunca criar `Route` nova. Nunca Voice. Nunca fabricar dados.
10. Se a task pedir “tela nova”: redesenhar como sheet/seção/widget.

---

## Completion definition (missão contínua)

Não há “155/155 absolutos”. Há **patamares honestos**:

- **Patamar A fechado:** P0 honestidade (M01, Arena worker, deep links) +
  contratos críticos + deepen mínimo Execução/Autônomos/Arena + presença
  fora-do-app base + device-pending explícito.
- **Patamar B fechado:** top monólitos partidos; Model <800; saldo
  negativo medido.
- **Patamar C fechado:** frentes AX/Autônomos/Arena/Código/Presença com
  DoD por item e prova.
- **Patamar D fechado:** compressão pós-C com meta de delete.
- Em seguida: **C↔D contínuo** até o operador declarar freeze.

Um mock, um botão sem ação, um progresso inventado ou uma rota nova
**= falha de plano**, não atraso.

---

## Execution handoff

Plano salvo em `docs/plano-elite-agentica-24x7.md` (+ design em
`docs/superpowers/specs/2026-07-17-elite-agentica-24x7-design.md`).

**Opções de execução:**

1. **Subagent-Driven (recomendado)** — um subagente fresco por task,
   review entre tasks.
2. **Inline** — `executing-plans` nesta sessão, com checkpoints por onda.

Começar sempre por **A0 → A1** (doutrina + honestidade). Sem A1, o resto
é cosmético.
