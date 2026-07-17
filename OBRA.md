# OBRA — Atlas AI Mobile Max (atlas-native)

> **O blackboard único.** Fable 5 (casca) e GPT 5.6/Codex (funciona) leem este
> arquivo ANTES de qualquer trabalho e o atualizam DEPOIS de cada entrega.
> Formato de cooperação: fronteiras → gates → fila → pedidos → registro.

## 0. Missão e a lição que não se repete

**Missão:** o aplicativo nº 1 — e disparado — de programação agêntica de
altíssimo nível. Dois pilares: Atlas AI (conversa, execução viva, presença) +
Atlas Código (grafo, cure 24/7). Autônomos é frota própria. Continuity fora do
app (Island / lock / widgets) é território livre. Voice / Atlas-wide permanecem
verticais futuras congeladas.

**Papel do humano (canon):** Intenção · Julgamento (produto/preço/risco) ·
Assinatura (publicação/destruição) · Veto retroativo com recibo. **Operação
nunca espera humano** — Autonomia > aprovação; silêncio é o produto; atenção
é o recurso mais caro. Plano vivo: `docs/plano-elite-agentica-24x7.md`.

**A lição (o app RN morreu disso):** grande demais, nada funcionava, código
inchado e bagunçado. O antídoto NÃO é prudência tímida — é disciplina:
verticais completas e demonstráveis no device, gates que não mentem,
fronteiras executáveis por check, deletar > adicionar. Ciclo obrigatório:
Implementar → Comprimir → Aprofundar → Comprimir. O atlas-server já é
excepcional; este app é a casca que encaixa nele — a inteligência mora no
servidor, o app entrega experiência.

## 1. Fronteiras de propriedade (executáveis, não aspiracionais)

| Território | Dono | Conteúdo |
|---|---|---|
| `Sources/AtlasCore/` | **Codex** | contrato, engine, transporte, streaming, modelos, merge |
| `Sources/AtlasImaging/` | **Codex** | normalização de mídia (ImageIO, iOS+macOS) |
| `Sources/AtlasCoreChecks/` | **Codex** | golden checks, fixtures, live-probes, boundary checks |
| `Package.swift` · `App/project.yml` · `App/Makefile` · `App/scripts/` | **Codex** | build, gates, deploy |
| `App/Atlas/ConversationModel.swift` · `AtlasSession.swift` | **Codex** | lógica dos models @Observable (o seam) |
| `App/Atlas/*View*.swift` · `RootView` · componentes visuais | **Fable** | toda a casca SwiftUI |
| `App/Atlas/AtlasTheme.swift` · `AtlasType.swift` · `AtlasMotion.swift` | **Fable** | design system (slate teal + gold + Fraunces — identidade própria, NÃO cópia do Cursor) |
| `App/Atlas/Assets.xcassets` · ícone · fontes | **Fable** | assets |
| `packages/atlas-rich-input-canon/` (fixtures/script) | **Codex** | régua TS↔Swift |

**O seam entre os dois** = os models `@Observable` + tipos públicos do
AtlasCore (`ChatBubble`, `LocalDraft`, `ExecAgent`, `UploadProgress`,
`AtlasComputeEffort`, `Workspace`). A casca renderiza SÓ o que o model expõe.

**Regras da fronteira:**
1. Quem não é dono **não edita** — pede via §5 (Pedidos de contrato).
2. Fable pode adicionar helpers *presentation-only* em arquivo separado
   (`ConversationModel+UI.swift`), nunca tocando a lógica.
3. Nenhum código da casca chama endpoint direto (o boundary check já proíbe
   `/ai/uploads` fora do engine — princípio vale pra tudo: casca fala com
   model, model fala com AtlasCore, AtlasCore fala com o servidor).
4. Views não importam `AtlasCore` para fazer rede — só para tipos.

## 2. Gates (antes de QUALQUER commit — sem exceção, sem `|| true`)

```bash
swift run AtlasCoreChecks        # 195+ golden checks — verde ou não commita
cd App && make build             # o app compila (gate honesto, exit != 0 em falha)
```

- **Codex adicional:** mexeu em wire/contrato → `ATLAS_LIVE=1 ATLAS_TOKEN=… swift run AtlasCoreChecks`
  (live-probe contra o atlas-server real). Mexeu no canon TS → regenerar
  fixtures (`npx tsx scripts/export-fixtures.ts`) e rodar o teste TS também.
- **Fable adicional:** mudança visual → `make device` + screenshot do operador
  (Wispr Flow bloqueia verificação no simulador; device é a prova).
- Commits escopados e prefixados: `feat(core)|fix(core)` = Codex ·
  `feat(ui)|polish(ui)` = Fable · branch **main local apenas**, sem merges.
- **M81 · device-pending envelhecido:** qualquer prova `DEVICE-PENDING` ou
  `device-pending` com mais de 7 dias vira linha destacada em vermelho em §4
  (`<span style="color:red">...</span>`) com owner/`Claimed by` =
  **operador**. Pendência de device não pode ficar escondida em nota antiga.

- **N8 (performance como lei):** mudança que regride um baseline de F5.1
  (Instruments no device: cold launch, hitches @120Hz, grafo 200, upload 20MB)
  **não commita**. Sem baseline medido, a pendência fica em §5 — nunca declarar
  alvos atingidos sem evidência.
- Warnings de StrictConcurrency: **não aumentar** (baseline ~22; meta = 0
  antes do bump pro modo Swift 6).

### Protocolo da main compartilhada

1. Antes de iniciar, marque a linha da tarefa com `IN_PROGRESS`, agente, escopo
   de escrita e dependência. Uma linha já reclamada não pode ser tomada.
2. Atualizações deste arquivo usam o lock atômico `.atlas-mobile-plan.lock`;
   lock existente significa reler `git status` e trabalhar fora do blackboard.
3. Imediatamente antes de aplicar patch ou commitar: releia `OBRA.md`, rode
   `git status --short` e preserve todo arquivo fora do seu escopo.
4. Stage sempre explícito (`git add <arquivos>`), nunca `git add -A`.
5. Ao entregar, preencha evidência/commit, mude para `DONE` e libere o claim.

## 3. Anti-inchaço (a constituição — cada linha nasce culpada)

1. Dependência externa: **ZERO** hoje (Foundation/SwiftUI/ImageIO/CryptoKit).
   Adicionar uma exige decisão registrada em §6 com justificativa.
2. Protocol novo só com **2º consumidor real** (os 2 que existem —
   `AttachmentByteSource`, `UploadTransport` — pagaram a entrada com testes).
3. Arquivo passando de ~300 linhas (view ~200) = candidato a split; registrar
   em §5 se cruzar a fronteira.
4. Feature = **vertical demonstrável no device**. Sem "fundação pra depois".
5. Toda lógica não-trivial deixa um golden check. Plano ≠ código ≠ prova.
6. Deletar > adicionar. Simplificação deliberada leva comentário `ponytail:`.

## 4. Fila de trabalho (Conversation Supremacy — vertical ativa)

### SOTA 10/10 (Grok 4.5 · spec `docs/plano-sota-10-de-10.md`)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance | Evidence |
|---|---|---|---|---|---|---|---|
| S1 | **DONE** | **Grok 4.5** | `Sources/AtlasCore/{AtlasAiTelemetry,AtlasAiPolicies,AtlasAiProviders,AtlasAiAttachments}.swift`; `Sources/AtlasCoreChecks/main.swift` | decisão §6 2026-07-16 | F0.2 poda 4 arquivos inteiros + cascata checks | 0 refs produto; checks+build verdes | −1.577 Swift; cascata main.swift; checks exit 0; build exit 0 |
| S2 | **DONE** | **Grok 4.5** | `Sources/AtlasCore/{AtlasAiDecisions,AtlasAiQuality,AtlasAiThreadsExtra}.swift` | S1 | F0.3 poda parcial Decisions/Quality/ThreadsExtra | tipos pinados pelo trace vivos; APIs mortas fora; checks+build verdes | −456 Swift; checks exit 0; build exit 0 |
| S3 | **DONE** | **Grok 4.5** | `Sources/AtlasCore/{Models,Merge}.swift`; trio VERIFICAR em AtlasAiModels; checks main.swift | S2 | F0.4+F0.5 Models+Merge DELETE (default) + trio VERIFICAR | 0 refs produto; checks+build verdes | −~210 Swift; Session/Message KEEP (estruturais); Providers enum DELETE; ressalva sync offline em §7 |
| S4 | **DONE** | **Grok 4.5** | `App/Atlas/{AtlasTheme,RootView}.swift` | S3 | F0.6 tema morto + botão morto | 0 usos dos tokens; zero botão falso; build verde | −5 tokens + botão falso; prussian fica; checks+build exit 0 |
| S5 | **DONE** | **Grok 4.5** | `App/Atlas/Fonts/*`; `AtlasType.swift`; `Info.plist` | S4 | F0.7 fontes inalcançáveis | só SemiBold/Regular/Italic/Mono no bundle; build verde | −144K Bold+Medium; 28/28 serif→SemiBold; checks+build exit 0 |
| S6 | **DONE** | **Grok 4.5** | `docs/proposals/**`; `docs/superpowers/`; `.gitignore` | S5 | F0.8 docs dups + arquivamento | links repontados; dups fora; archive | dups −~264K + index; superpowers→archive; checks+build exit 0 |
| S7 | **DONE** | **Grok 4.5** | `Sources/AtlasCore/AtlasTurnStatus.swift` + call sites | S6 | F1.1 AtlasTurnStatus | 0 literais de status fora do enum/checks; checks+build verdes | enum + computed turnStatus; InteractionRun/Model/Cockpit; 11 golden checks; exit 0 |
| S8 | **DONE** | **Grok 4.5** | `Sources/AtlasCore/AtlasIDs.swift` + ChangeReview/Client Core + casca mínima | S7 | F1.2 IDs tipados (Core) | TraceID/PatchID nas APIs de review + getAiInteraction; checks+build verdes | AtlasIDs + golden; review APIs tipadas |
| S9 | **DONE** | **Grok 4.5** | `App/Atlas/ConversationModel.swift` (+ presence/bridge) | S8 | F1.2 IDs tipados (models) | threadId/jobId/clientId/traceId tipados no model | ChatBubble/Model seams tipados; checks+build exit 0 |
| S10 | **DONE** | **Grok 4.5** | `App/Atlas/*View*.swift` | S9 | F1.2 IDs tipados (views) | 0 Id:String em assinatura de view do loop | Route/ConversationView/askThread tipados; rg 0 em App/Atlas |
| S11 | **DONE** | **Grok 4.5** | `Sources/AtlasCore/AtlasDecoding.swift` + 9 call sites | S10 | F1.3 requireSchema() | schema-guards deduplicados; checks fail-closed verdes | −~64; 9 sites; checks+build exit 0 |
| S12 | **DONE** | **Grok 4.5** | `App/Atlas/LoadPhase.swift` + models | S11 | F1.4 LoadPhase compartilhado | Autonomos/Code/Workspace/Session usam LoadPhase | Provenance/Ask mantêm Phase própria (associada); F1 FECHADA |
| S13 | **DONE** | **Grok 4.5** | `AtlasClient` SSE + `AtlasAiStream` Data path | S12 | F2.1 SSE sem gordura (TDD) | drain por cursor; 1 decoder; checks equiv | TDD red→green; checks+build exit 0; live skip (sem token) |
| S14 | **DONE** | **Grok 4.5** | `Sources/AtlasCore/JSONValue.swift` | S13 | F2.2 JSONValue via JSONSerialization | API pública igual; checks byte-a-byte verdes | ponte JSONSerialization; checks+build exit 0 |
| S15 | **DONE** | **Grok 4.5** | InteractionRun + AtlasAgentActivity + ConversationModel | S14 | F2.3 poll incremental + check contagem | projeção ≤500 em ledger 500 | cache lastProjected; índice por id |
| S16 | **DONE** | **Grok 4.5** | `Sources/AtlasCore/AtlasTime.swift` | S15 | F2.4 AtlasTime fast-path | ISO plain sem throw/catch | `64a3863`; checks+build exit 0 |
| S17 | **DONE** | **Grok 4.5** | `Sources/AtlasCoreChecks/{main,InteractionRunChecks}.swift` | S16 | F2.5 goldens item_id snake_case | goldens snapshot+SSE | `2677b5a`; checks+build exit 0 |
| S18 | **DONE** | **Grok 4.5** | Markdown/RichInput/Imaging | S17 | F2.6 micro-opt hot path | trim/prefix/bytes | `1dd7d5e`; checks+build exit 0 |
| S19 | **DONE** | **Grok 4.5** | `App/Atlas/{AtlasMarkdownView,ConversationView}.swift` | S18 | F2.7+F2.8 markdown memo + scroll | throttle 100ms; scroll coalescido | checks+build exit 0 |
| S20 | **DONE** | **Grok 4.5** | `App/Atlas/{AtlasCodeView,ConversationChrome,ConversationView}.swift` | S19 | F2.9+F2.10 LazyVStack + Equatable | grafo lazy; bolha `.equatable()` | checks+build exit 0 |
| S21 | **DONE** | **Grok 4.5** | `App/Atlas/A11yID.swift`; `App/project.yml`; UITests | S20 | F4.1 A11yID compartilhado | 0 literais accessibilityIdentifier na casca; UITests usam A11yID | checks+build exit 0 |
| S22 | **DONE** | **Grok 4.5** | `App/Atlas/ChangeReviewModel.swift` (+ Continuity/Types) | S21 | F3.1 ChangeReviewModel | ConversationModel < 800; sheet usa reviews | `d99c053`; 797 linhas; checks+build exit 0 |
| S23 | **DONE** | **Grok 4.5** | `App/Atlas/AtlasCode*.swift` | S22 | F3.2 split AtlasCodeView | nenhum arquivo CodeView > 400 | `c2ddf0c`; View 176; checks+build exit 0 |
| S24 | **DONE** | **Grok 4.5** | PlanCard/ExecutionStateCard/LiveTimeline | S23 | F3.3 split ConversationCockpit | shell 115; cards < 250 | `0c12f96`; checks+build exit 0 |
| S25–S27 | **DONE** | **Grok 4.5** | Cockpit DiffStats; PlanCard revisions; ChangeReview Council | S24 | F3.4 seams C18/C19/C21 na casca | refs em App/Atlas; ausência≠zero | F3.4 commit; Council pré-existente na sheet; checks+build exit 0 |
| S28 | **DONE** | **Grok 4.5** | `App/Atlas/AtlasTheme.swift` + cards | S27 | F4.2 `.atlasCard()` | chrome canônico migrado onde idêntico | `2f338df`; checks+build exit 0 |
| S29 | **DONE** | **Grok 4.5** | `Sources/AtlasCore/AtlasRoute.swift` + clients | S28 | F4.4 AtlasRoute | paths centralizados | `4cea5df`; checks+build exit 0 |
| S30 | **DONE** | **Grok 4.5** | `TurnPayloadBuilder` + golden | S29 | F4.5 TurnPayloadBuilder | equivalência payload; 0 JSON cru montado na casca | `9339f0c`; checks+build exit 0 |
| S31–S32 | **DONE** | **Grok 4.5** | ThreadReadCache + ConversationModel/View | S30 | F6.1 read-cache SWR | selo «visto há»; offline ≠ tela vazia | `4cdeb9f`+`a777d6c`; Model 798; checks+build exit 0 |
| S33 | **DONE** | **Grok 4.5** | OBRA §2 N8 + §5 DEVICE_PROVEN | S32 | F5.3+F5.4 N8 gate + prints | N8 em §2; prints = pendência operador | este commit |
| S34 | **DONE** | **Grok 4.5** | OBRA §7 registro final | S33 | docs(obra) fechamento SOTA | DoD por eixo com prova/honesto | este commit |

### Próximo Patamar (Grok 4.5 · spec `docs/spec-proximo-patamar.md`)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance | Evidence |
|---|---|---|---|---|---|---|---|
| P01 | **DONE** | **Grok 4.5** | TurnPresence + ConversationView | decisão §6 | V1.T1.1 liveSessions + threadId | liveSessions tipado; zero rota nova | `11bb1bb` |
| P02 | **DONE** | **Grok 4.5** | LiveNowSection + RootView + A11yID | P01 | V1.T1.2 seção VIVO AGORA | só com ≥1 sessão; atlasCard | `d86cf2c` |
| P03 | **DONE** | **Grok 4.5** | AtlasLiveNowTests + evidence | P02 | V1.T1.3 prova XCUITest | idle sem seção; live com seção; some ao fim | 1/0 falhas; screenshots evidence |
| P04 | **DONE** | **GPT-5.5** | `Sources/AtlasCore/AtlasDayRhythm.swift`; `Sources/AtlasCoreChecks/{AtlasDayRhythmChecks,main}.swift` | P03 | V2.T2.1 AtlasDayRhythm + golden checks | mediana 7d, cold start, persistência v1, cap 14d, timezone safe | `9f7d7ea`; 8 checks novos; checks+build+diff |
| P05 | **DONE** | **GPT-5.5** | `App/Atlas/{AtlasSession,ConversationModel}.swift` | P04 | V2.T2.2 recordActivity nos models | instância única + 1 linha no load + 1 linha no accept de envio | `bc8485d`; checks+build+diff |
| P06 | **DONE** | **GPT-5.5** | `App/Atlas/{NightlyProposal,A11yID,AtlasApp,RootView,AutonomosView}.swift` | P05 | V2.T2.3 proposta das 21h | delegate, scenePhase, card Autônomos, sheet prefilled, manhã sem números | `316d82e`; checks+build+diff |
| P07 | **DONE** | **GPT-5.5** | `App/Atlas/AutonomosView.swift`; `App/UITests/AtlasNightlyProposalTests.swift`; `docs/evidence/2026-07-16-proposta-21h/`; `OBRA.md` | P06 | V2.T2.4 prova + registro | XCUITest card→sheet→dismiss; card independe do carregamento; screenshots; device físico honesto | este commit; sim verde; device-pending |
| P08–P11 | **DONE** | **GPT-5.5** | `../atlas-server` artifacts; `Sources/AtlasCore*`; `App/Atlas/{ChangeReviewModel,ConversationChrome,ExecutionStateCard,ArtifactSheet,A11yID}.swift`; `docs/evidence/2026-07-16-artifacts/`; `OBRA.md` | P07 | V4 Artifacts & Proof commits 08–11 | manifesto+content trace-scoped; Core fail-closed; linha/sheet; prova §V4.6 | server `99ba5abd3`; core `5396b21`; ui `d6732ea`; prova neste commit; device/live token pendentes |
| P12–P15 | **PARCIAL** | **GPT-5.5→Grok 4.5** | scanner+healer server; área/backlog; UI recibo; `docs/evidence/2026-07-16-selfconstruction/` | P11 | V3 Self-Construction scanner→backlog→cura mecânica R2 + UI | Scanner R1–R5 + healer R2 PHPUnit verde; worker SCL drenou dry_run; canário plant→scan→heal→ausente; falta delivered/merge no app | healer+worker unlock nesta sessão; evidência atualizada; bloqueios restantes §5 |
| P16–P20 | **DONE** | **GPT-5.5** | AtlasCodeWhy + sheet + XCUITest | P15 | V5 H1 Biografia do arquivo | DoD §F / prova §7 P19 | §7 2026-07-16 P19; `docs/evidence/2026-07-16-h1-why/` |

### Profundidade Total (Grok 4.5 · `docs/plano-profundidade-total.md` + M61 `docs/spec-arena-medicao.md`)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance | Evidence |
|---|---|---|---|---|---|---|---|
| PT0 | **PARCIAL** | **Grok 4.5** | evidence + OBRA | decisão §6 2026-07-17 | Onda 0 M01–M06 | M06 live DONE; M01 último passo+§5; M02–M05 roteiro operador | `docs/evidence/2026-07-17-onda0/`; M06 log |
| PT1 | **PARCIAL** | **GPT-5.5** | `App/Atlas/{A11yID,AutonomosView,ConversationChrome,ConversationCockpit,ConversationView,ExecutionStateCard,SelfConstructionReceiptSheet,SteerInteractionSheet}.swift`; `OBRA.md` | PT0 | Onda 1 M07–M14 + casca sprint M15/M62/M11 | M07–M09 casca ligadas; M15 aplicado; M62/M11 verificados | este commit; checks+build+diff verdes; device-pending |
| PT-M61 | **PARCIAL** | **GPT-5.5** | server A1–A3 já shipped; native `AtlasArena.swift`+checks+`App/Atlas/Arena*`+RootView+A11yID+XCUITest+evidence | PT1 casca sprint | M61 Arena A4–A12 (única rota nova `.arena`) | Core/UI/test/prova de enqueue app; falta drenagem worker→scoreboard final | `b2bffeb`→`1930ed3` + este commit; `docs/evidence/2026-07-17-arena/` |
| PT2–8 | **PARCIAL** | **GPT-5.5** | `App/Atlas/*`; `Sources/AtlasCore/AtlasTraceGovernance.swift`; `Sources/AtlasCoreChecks/AtlasTraceGovernanceChecks.swift`; `OBRA.md` | PT-M61 | Ondas 2–8 batch M10/M16/M17/M19/M20/M21/M24/M26/M48/M52/M64/M66 | council/revisions/LiveNow/cache/artifact/grafo/Autônomos/privacy fechados; M65 deferido; M27/M41/M53/M60/M82 defaults | este commit; checks+build+diff em §7 |
| PT10 | **PARCIAL** | **GPT-5.5** | `App/Makefile`; `OBRA.md` | contínuo | Onda 10 M76–M81 rituais; M78/M80/M81 entregues | `make verify`; ledger §B no OBRA; regra device-pending >7d | este commit; gates finais em §7 |
| PT11–18 | **PARCIAL** | **GPT-5.5** | `Sources/AtlasCore/AtlasNativeSnapshot.swift`; `Sources/AtlasCoreChecks/AtlasNativeSnapshotChecks.swift`; `App/Atlas/{AtlasNativeSnapshotWriter,AtlasSession,ConversationModel,AutonomosModel,AtlasCodeModel,TurnPresence}.swift`; `App/Widgets/*`; entitlements/project | M118 antes widgets | Patamar Supremo M83/M85/M86/M121 | SD-1 App Group entregue; widgets leem snapshot fail-closed; staleness >6h visível; M87 deferido sem campos discretos | este commit; checks+build+diff em §7 |
| PT19–22 | **PARCIAL** | **GPT-5.5** | `App/Atlas/{A11yID,AtlasSession,RootView,ConversationModel,ConversationModel+ReadCache,ConversationTypes,ConversationView,ConversationCockpit,ExecutionStateCard,LiveNowSection,LiveTimeline,AutonomosView}.swift`; `Sources/AtlasCore/{InteractionRun,ThreadReadCache}.swift`; `Sources/AtlasCoreChecks/InteractionRunChecks.swift` | PT11–18 | Ondas 19–22 M94/M95/M99/M113/M114/M125/M139/M141/M145/M146/M148/M149/M153/M158 | Profundidade sem nova Route; dados só dos models/Core | este commit; checks+build+diff em §7 |
| PT-priority-robustez | **PARCIAL** | **GPT-5.5** | `Sources/AtlasCore*`; `App/Atlas/*`; `App/Widgets/*`; `docs/motion-haptics-map.md`; `OBRA.md` | PT19–22 | Priority batch M43–M51/M87/M96/M102/M105/M132/M137/M142/M147/M154/M157/M159/M14/M22/M25 | Robustez Core + bindings UI sem nova Route; sem Onda 9; sem §B SKIP; dependências sem contrato em §5 | este commit; gates finais em §7 |

### Elite 24×7 (Grok 4.5 · `docs/plano-elite-agentica-24x7.md` + design `docs/superpowers/specs/2026-07-17-elite-agentica-24x7-design.md`)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance | Evidence |
|---|---|---|---|---|---|---|---|
| E0 | **DONE** | **Grok 4.5** | `docs/plano-elite-agentica-24x7.md`; design; `OBRA.md` | decisão operador 2026-07-17 | Canon + plano mestre A→B→C→D | zero Route nova; fora-do-app livre; humano fora do fluxo ops | este commit |
| E-A1 | **PARCIAL** | **Grok 4.5** | Core `AtlasDeepLink` + RootView + Widgets M84; server M01/A12 | E0 | Onda A1 honestidade P0 | A1.3 deep links DONE; M84 Semana widget; M01/A12 **BLOCKED(server)** neste ambiente | deep link + week widget neste commit; gates Swift BLOCKED(cloud Linux) |
| E-A2 | **PENDING** | — | Arena LA + App Intents | E-A1 A12 | Onda A2 Arena Continuity | LA `suite·engine·braço·N/M`; botões só ações reais | — |
| E-A3 | **PENDING** | — | §5 contratos C9/M65/C18–C21/M98+/… | E0 | Onda A3 contratos | TDD + decode; UI só depois | — |
| E-A4 | **PARCIAL** | **Grok 4.5** | deepen + fidelity matrix | E0 | Onda A4 casca deepen | A4.5 matrix DONE; A4.1 Session Hub DONE; Search/Workspace A11y+empty/offline DONE; Arena empty/404+AtlasFailureCopy + CodeRadar/hub silence DONE; demais cenas ainda pendente | LiveNow + Search/Workspace `a037aa7` + Arena/Radar silence este commit |
| E-A5 | **IN_PROGRESS** | **Grok 4.5** | `App/Widgets/*` + `AtlasDeepLink` | E-A1 deep links | Onda A5 fora-do-app | M84 Semana + lock accessories; `atlas://arena`→`.arena`; lock `queueLabel` cápsula gold; Island SD-2 ATT/EXT/FAIL/REC/PLN + N/M + fila; LockScreen/WidgetViews peel; widgetURL Arena home entry opcional | `4191353` SD-2 + `953740d`/`0217603` peels + `e0bce46`+`183f01f`+`08f0dda`+`0ab1682`+`a702926` |
| E-A6 | **PENDING** | **operador** | device unlock + prints | passcode | Onda A6 DEVICE_PROVEN | U1–U10 + Arena E2E + M03/M04 | — |
| E-B | **PARCIAL** | **Grok 4.5** | peels contínuos App+Core | E-A* | CICLO B compressão 1 | **Ledger HEAD:** Client 305 (+Query/SSE); AgentActivity 45 (+FromEvent/Timeline); Model 250 (+Send 262); AutonomosView~191 (+Loaded/Header); Provenance sheet 47 (+Sections 252); Nightly 215 (+Card); Widgets shell 175 (+Views 387 +Lock 122). Core zero >400. Ainda >300: RichInputEngine 354, InteractionRun 351, AtlasWidgetViews 387. | peels + `wc -l`; build Mac-pending |
| E-C | **IN_PROGRESS** | **Grok 4.5** | silence + Island SD-2 + Continuity/PlanCard | E-B PARCIAL | CICLO C patamares | Frota/fila quietas; failureKind; Arena/Radar honestos; Island badges de phaseTitle; Continuity ready/pending editorial; PlanCard revisions só com metadata real; `rg Aprovar App/Atlas`=0 | `dc787be` + `4191353` + `2df3195` |
| E-D | **PENDING** | — | compressão 2 | E-C | CICLO D | delete ≥60% linhas de C ou ADR | — |

### Codex (funciona)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance | Evidence |
|---|---|---|---|---|---|---|---|
| C1 | **DONE** | — | `Sources/AtlasCore/{AtlasClient,InteractionRun}.swift`; checks; `ConversationModel.swift` | `f900ef1` | Reconnect SSE (`after=` + backoff, max 4) + `InteractionRun` | Retoma de `lastSequence` sem duplicar; create/stream/poll/cancel têm um único dono; cancel encerra transporte, polling e job | `ec3ffe6`; 220 checks; live create→SSE content→done; app build verde |
| C2 | **DONE** | — | core + model persistence | C1 | Outbox durável: clientId estável, recovery e `shouldKeep` | Rede/408/429 sobrevivem a relaunch; erros terminais não criam loop | `d1c78ba`; JSON atômico + relaunch/recovery; 232 checks; live outbox drenada no done |
| C3 | **DONE** | — | `Sources/AtlasCore/{RichInputEngine,AttachmentAdapters}.swift`; boundary checks; `App/Atlas/ConversationModel.swift` | F5 | engine único para imagens/arquivos/câmera/clipboard; hardening: fileImporter off-main e FileByteSource security-scoped | Arquivo grande não é materializado na MainActor; leitura continua chunked e válida depois do picker; send aguarda preparações | `da9399a` + `3b80c72` + `ec369f1`; TDD red→green; arquivo real lê por offset; live upload 3,2MB preserva SHA-256; Core + App verdes |
| C4 | **DONE** | — | `Sources/AtlasCore/LongMessage.swift`; `Sources/AtlasCoreChecks/LongMessageChecks.swift`; `ConversationModel.swift` | C3 | Long-message >40k → `.md` | Texto longo chega uma vez como documento canônico | `03192bd`; red→green; live upload→create→provider leu canary existente só no Markdown |
| C5 | **DONE** | — | trace DTO/model + checks | C1 | tool events + decisão/quality + atividade atual honesta | Reasoning/progress intercalado não substitui tool aberta; completion libera o slot; View sem parsing | evidência anterior + `30b2023`; TDD red→green, live `shell.started` >5s/replay, XCUITest encontrou `Executando comando` ao vivo |
| C6 | **DONE** | — | `Package.swift`; `App/project.yml`; `Sources/AtlasCore/AtlasTime.swift`; check runner e demais warnings Core | C1–C5 | Zerar warnings e ativar Swift 6 | Core e App compilam em Swift 6 com zero warning próprio | `475267f` + `97c9fdc`; rebuild limpo Core e `xcodebuild clean build` App sem warning próprio |
| C7 | **IN_PROGRESS** | **Codex** | `App/project.yml`; `App/Makefile`; `App/UITests/**`; scripts de device proof; `Sources/AtlasCoreChecks/{InteractionRun,DeviceProofHarness}Checks.swift` | U1–U6 | Harness só fica verde com envio confirmado, tool exata ao vivo e tool persistida visível/tocável | XCUITest dirige conversa/tool/cockpit e captura evidence attachment no iPhone real | `9af0b72` + `9b92a8a` + `df55878`; Simulator Hermes/Kimi: 1 teste/0 falhas. O CoreDevice pode abrir túnel sob demanda, portanto o preflight aceita iPhone pareado e sonda lock antes de qualquer limpeza/Xcode. Core + App verdes. Em 2026-07-13 o aparelho respondeu, mas `passcodeRequired: true`; ainda não há prova física. |
| C8 | **DONE** | — | `../atlas-server/app/Services/Ai/{AtlasFinalResponseSanitizer,HermesCliProvider}.php`; `../atlas-server/app/Services/Ai/Hermes/Acp/{HermesAcpProtocol,AtlasHermesAcpRuntime}.php`; testes correspondentes; `Sources/AtlasCore/AtlasAssistantPresentation.swift`; checks | C5 | Hermes/Kimi provider-neutral: ACP projeta thought/tool start/tool completion; Reasoning-only nunca vira sucesso/apresentação; mobile solicita transporte estruturado | Ferramenta real chega live, persiste no ledger e reaparece no replay; reasoning fica somente como atividade sanitizada; resposta final utilizável ou falha honesta | `f356bd4a1` + `d77cf5a`; migration aplicada; 129 testes/733 asserts no server; Core checks + App build; live Hermes ACP com `shell.started` >5s, persistência e replay |
| C14 | **IN_PROGRESS** | **Codex** | `Sources/AtlasCore/AtlasExecutionPresentationState.swift`; checks; `ConversationModel.swift`; `../atlas-server/app/Services/Ai/{AiExecutionPresentationState,AiWorker,AiProviderChoiceResolver,AiJobController}.php` | C1, C5, C10 | Contrato público versionado para atenção, replanejamento, espera externa, recuperação, falha e conclusão | A casca recebe somente estados e ações declarados pelo servidor; último evento do ledger vence snapshot após reconexão; nenhum texto/model reasoning é inferido | Provider choice real projeta `attention_required`; o recibo produz `recovering|awaiting_external|failed`; worker direto **e council dual-review** gravam `completed|failed`; reparação nativa publica `replanning` somente após enfileirar a próxima iteração; cancelar diretamente grava `Sessão encerrada`; fallback automático Gemini→Claude e recovery stale (direto + Council) só publicam `recovering` após reenfileirar de verdade; falha stale só é terminal quando o rollup Council também encerrou. Lifecycle permanece sanitizado. O timer público acumula somente execução ativa, e Core rejeita timer incompatível com a fase. TDD red→green: 57 testes PHP (403 asserts); `swift run AtlasCoreChecks`, `make build` e `git diff --check` verdes. Faltam integrar e provar as telas Fable 5 no iPhone. |
| C15 | **PARCIAL** | **Codex→Fable** | `../atlas-server/app/{Http/Controllers/Ai,Services/Ai,Models}; ../atlas-server/routes/api.php; Sources/AtlasCore/AtlasChangeReview.swift; Sources/AtlasCoreChecks/AtlasChangeReviewChecks.swift; ConversationModel.swift` | C5, C10, C12 | Projeção de artefatos e revisão vinculada ao trace | Todo artefato, diff e decisão resolve por `engineering_run.trace_id == ai_traces.id`; a casca nunca recebe `engineering_run_id`, nem inventa diff, resultado de check ou aprovação | Rotas trace-scoped de revisão/diff/decisão e recibo lifecycle são reais; zero ou múltiplos runs viram indisponibilidade explícita. TDD: 5 PHP/38 asserts; checks Core + build iOS verdes. Falta a casca renderizar e provar no iPhone. |
| C16 | **PARCIAL** | **Codex→Fable** | `../atlas-server/app/{Http/Controllers/Ai,Services/Ai,Models}; migration; ../atlas-server/routes/api.php; Sources/AtlasCore/AtlasChangeReview.swift; Sources/AtlasCoreChecks/AtlasChangeReviewChecks.swift; ConversationModel.swift` | C15 | Decisão por arquivo vinculada ao patch imutável | `file_path` só é aceito se pertence ao patch do run unívoco da trace; a decisão atual é persistida por `(patch,file)`, ligada ao `diff_hash`, e cada ação produz recibo lifecycle | Aceite global agora aceita todos os arquivos capturados antes de aceitar o run; `accept|reject` por arquivo usa rota trace-scoped, sem `engineering_run_id`. TDD: 7 PHP/48 asserts; Core checks e `make build` verdes. Renderização e prova física seguem pendentes. |

### Fable (casca)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance | Evidence |
|---|---|---|---|---|---|---|---|
| U1 | **IN_PROGRESS** | **Fable** | `App/Atlas/ConversationView.swift` | F5 | Provar foto → strip → progresso → envio e polir strip | Fluxo real legível no device, inclusive erro e remoção | `ed10c81` instalado+aberto no iPhone 23:55; falta print do operador p/ DEVICE_PROVEN |
| U2 | **IN_PROGRESS** | **Fable** | `App/Atlas/ConversationView.swift` | U1 | Composer supremo em todos os estados | Nenhum controle falso; estados e motion aprovados no device | `a59003f` slot 3-estados honesto instalado; falta aprovação visual |
| U3 | **IN_PROGRESS** | **Fable** | execution views | C5 | Cockpit v2 para tools/receipt/quality | Substitui `ExecutionRibbon` estático; mostra atividade atual e timeline registrada/expansível em cada resposta, incluindo tools, comandos sanitizados, receipt e quality | `97c9fdc` + C8; Simulator Hermes/Kimi mostra tool live e timeline persistida de 9 passos alcançável; falta aprovação/prova no físico |
| U4 | DONE (falta print) | **Fable** | `RootView.swift`, `WorkspaceView.swift` | C1 | Vazio, rede, offline e servidor fora | Toda falha tem explicação e recuperação acionável | `c9adefb`+`da9399a`; `RootView.failureHeadline`/`failureHint` ligam `session.failureKind` (offline×timeout×refused×lost×401×maintenance×503); print device-pending |
| U5 | **IN_PROGRESS** | **Fable** | `AtlasType.swift` + views | U2–U4 | Dynamic Type, VoiceOver, Reduce Motion, 120Hz/startup | Auditorias e métricas no device registradas | `a582dac` Dynamic Type em TODA tipografia (relativeTo) + VoiceOver labels; falta auditoria visual no device |
| U6 | **IN_PROGRESS** | **Fable** | Assets.xcassets | U2 | Ícone, splash e masthead final | `5aa6245` ícone ✦ Ink & Brass no bundle e instalado; falta aprovação do operador na home | — |

### Fable · Experience Max (goal do operador 2026-07-13: notificações + tela
### bloqueada como o Cursor + polimento extraordinário)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance |
|---|---|---|---|---|---|---|
| U7 | DONE (falta print) | **Fable** | RootView/SearchView (casca) | — | Busca REAL na home (o botão hoje é morto — viola constituição) | `SearchView` existe: filtra `session.threads` (título case/diacritic-insensitive) + `NavigationLink`→`.thread`; home→`.search`; print device-pending |
| U8 | DONE (falta print) | Fable | ConversationView | — | Conversa suprema r2 + TIMELINE VIVA (passos empilham, atual pulsa — a progressão do Cursor) | `ca59dc2`+`c3eda84` |
| U9 | DONE (falta print) | Fable | TurnPresence (casca, withObservationTracking — C9 dispensado: zero edição no model) | — | Notificação local na tela bloqueada ao concluir fora do app; permissão no 1º turno | `c3eda84` |
| U10 | DONE (falta print) | Fable | Widgets/ + AtlasActivityAttributes + project.yml (TRAVESSIA ADITIVA autorizada pelo goal do operador; AtlasDeviceProof intacto) | — | Live Activity + Dynamic Island: ✦ + fase + timer; 'resposta pronta ✓' | `c3eda84` |

### Verticais seguintes (ordem)
Voice Supremacy (LiveKit/ditado/resposta falada) → Agent Cockpit (sessões
multiagente, pausar/redirecionar/escolhas) → Artifacts & Proof (screenshots,
diffs, aprovação, evidência) → Continuity (Live Activities, Dynamic Island,
push, widgets, App Intents, Share Extension) → Atlas-wide (agenda, saúde,
decisões, capturas, busca universal). **Autônomos Command Center é uma área
24/7 própria e não pertence ao Agent Cockpit nem ao Session Hub.**

> **Escopo ativo · Execução Viva Fable 5:** Voice permanece vertical futura.
> Não criar microfone, LiveKit parcial, affordance decorativa ou tela “em
> breve” nesta obra. Somente contratos sem UI já necessários ao runtime podem
> existir; a cena 09 não entra em nenhum gate desta entrega.

### AVISO CANÔNICO A TODA IA — Autônomos possui superfície própria 24/7

Esta decisão do operador é obrigatória para Codex, Fable e qualquer agente
futuro. **Nunca encaixar Autônomos como card, conversa longa ou sessão comum.**
O app terá uma rota/área superior exclusiva para operar todo o plano
Autônomos, conforme o protótipo
`docs/proposals/codex-autonomos-command-center/index.html`.

A superfície própria deve, com dados reais e persistentes:

- listar **todas as instâncias Autônomos** e contar registradas, executando,
  aguardando, pausadas, stale, falhas e atenção necessária;
- mostrar **onde cada instância roda**: placement humano, host/runtime,
  workspace/repo, branch/escopo, capacidades, uptime, heartbeat, lease,
  último checkpoint/restart e política de recuperação/failover;
- mostrar **o que cada instância está fazendo**: missão, objetivo, limites,
  estágio, plano N/M real, agentes, ferramentas/ações agregadas, próxima ação,
  próxima revisão e timer 24/7;
- oferecer o **ledger completo de tasks**: fila, executando, implementada,
  verificada, falhou, bloqueada, pulada ou cancelada, incluindo o que foi
  implementado, o que não foi, arquivos/diffs/commits, artifacts, receipts,
  evidências e motivo honesto de cada estado;
- preservar histórico de replanejamento, decisões públicas, incidentes,
  handoffs, recuperações, aprendizados e resultados, sem apagar versões;
- obter pelo contrato canônico do Atlas os **prompts/context packs do Cérebro
  Externo e do Músculo Externo**, com ação explícita para copiar/abrir/usar no
  executor correto. A projeção padrão é provider-safe e sanitizada; prompt
  bruto, IDs/traces internos e detalhes de provider só aparecem no modo de
  auditoria quando o operador solicitar;
- ter controles reais e governados: criar missão, seguir, pausar, retomar,
  drenar instância, transferir/handoff, reexecutar, cancelar e encerrar. Zero
  botão falso e nenhuma ação destrutiva sem autoridade;
- sobreviver a relaunch, troca de device e execução sem o app aberto. Trabalho
  saudável entra em digest/checkpoints; notificação, tela bloqueada e Live
  Activity aparecem por atenção real ou quando o operador escolher **Seguir**.

O seam continua contract-first: atlas-server/AtlasCore fornecem identidade,
estado e ledger; SwiftUI apenas projeta. Se o backend não fornecer um campo,
a casca não inventa número, progresso, status, prompt ou prova.

## 5. Pedidos de contrato (Fable ⇄ Codex)

> Formato: `- [ABERTO|FEITO] <quem pede>→<quem entrega>: <o que> — <por quê>`

- [ABERTO · M61/A10 · GPT-5.5→Fable/Codex] Live Activity dedicada da Arena — `AtlasTurnAttributes`/Widgets atuais são específicos de turnos de conversa; para "Seguir medição" na lock screen sem mentira, falta contrato/widget `suite · engine · braço · casos N/M` ligado a `AtlasArenaLiveRun` e encerramento terminal por `runs/live`.
- [ABERTO · M61/A12 · GPT-5.5→Codex/Server] Worker de medição da Arena para runs iniciados pelo app — A12 provou `POST /api/arena/runs` real pelo app e aparição em `runs/live`, mas o recibo declara `worker_implemented=false`; falta drenar `terminal_bench/mockllm` queued → running/done → scoreboard/composto sem simular progresso. **2026-07-17 · Grok 4.5:** neste workspace `atlas-server` **ausente** → leafs A1.2b **BLOCKED(server)**; native segue A1.2a/d (recibo honesto) + A1.3 deep links.
- [ABERTO · M49 · GPT-5.5→Codex/Native] Host pinning por perfil — precisa ADR/config de hosts não-locais + `URLSession` delegate opcional por host. Não foi implementado aqui para não introduzir pinning falso nem quebrar localhost/Tailscale.
- [ABERTO · M89 · GPT-5.5→Codex/Fable] Live Activity App Intents mecânicos — alvo atual não depende de `AppIntents.framework` e não há `AppIntent/LiveActivityIntent` no código; quando existir, mapear somente ações reais (`state.actions`/cancel/retry/choice) para Parar/Retomar/Escolher.
- [ABERTO · M35 · GPT-5.5→Codex/Server] TreeSitter `grammar_missing:<lang>` fail-closed — `atlas-server` já documenta o follow-up, mas o patch toca `CodeGraphTreeSitterExtractor`/indexer e deve vir com PHPUnit de grammar fake ausente; não foi seguro mexer no server sujo desta sessão.
- [ABERTO · M36/M37/M38 · GPT-5.5→Codex/Fable] Triagem pós-verticais — rodar scanner R2 no HEAD, triar os 319 findings em real/falso/threshold e fazer sweep final de comentários em inglês por arquivo tocado; grande demais para este commit de bindings.
- [ABERTO · M40 · GPT-5.5→Fable] Snapshot tests de views-chave — criar harness `ImageRenderer` + referências versionadas; opcional não executado por não ser quick sem aprovar baseline visual.
- [ABERTO · M105 agente · GPT-5.5→Codex/Server] Grafo com filtro por agente — app entregou chips por estado real; `AtlasCodeGraphNode` ainda não expõe `agent`/`traceAgent`, então filtro de agente precisa campo aditivo no DTO do grafo ou índice leve de proveniência.
- [ABERTO · M98/M100/M106/M107/M109/M112/M116/M126/M134/M140/M160 · GPT-5.5→Codex/Server] Contratos aditivos não expostos nesta casca — quality breakdown, custo/tokens por turno, compare de commits, histórico/tendência de scans, semana comparativa, checkpoints públicos da missão, série de gasto por agente, feedback por passo, commits-by-trace, série temporal task-health e último item M160 precisam payload provider-safe explícito; sem contrato a UI permanece ausente.
- [FEITO] GPT-5.5→Codex/Autônomos: worker `software_company_loop` — `php artisan queue:work database --queue=software_company_loop` no host (Docker `atlas-queue` só ouve `transcription,default`). Prova: job dry_run RUNNING→DONE; ciclo 54 `dry_run_planned`.
- [FEITO] Grok 4.5→Codex: healer mecânico R2 `atlas:native:constitution-heal` — AP-786/senior-loop é ferramenta errada p/ dead_symbol (TDD/BDD + factory_max rouba seleção). Canário `sha1:19fc7482…` dry_run→healed; re-scan ausente. start-run passa `repo_root` / `allow_canonical_worktree_write` / `injected_finding`.
- [ABERTO] Grok 4.5→Codex/Fable: V3 DoD restante — heal mecânico ainda **não** grava ciclo `outcome=merged` em `model.delivered`; casca sem recibo "O ATLAS MELHOROU O PRÓPRIO APP" até haver merge/ledger real **ou** contrato de heal-receipt (sem fabricar delivered). Device screenshots: `passcodeRequired=true`.
- [ABERTO · M01 · 2026-07-17 · Grok→Codex/server] Bridge heal→merge ausente: probe `GET …/atlas-native/done` → `delivered_total=0` (59 ledger). Healer R2 prova `merge_performed=false` por design. Pedido: (a) pós-heal governado commit+merge+append AP-790 com `merge_hash` real, OU (b) contrato heal-receipt separado de `/done` + seam na casca — NUNCA fabricar merge fields. Evidence: `docs/evidence/2026-07-17-onda0/`. **2026-07-17 · Grok 4.5:** neste workspace `atlas-server` **ausente** → leafs A1.1b/c **BLOCKED(server)**; native A1.1a/d (inventário + casca fail-closed, sem fabricar delivered).
- [ABERTO · Onda0 · operador] M02 DEVICE_PROVEN / M03 Instruments / M04 APNs / M05 verticais-device — roteiros em `docs/evidence/2026-07-17-onda0/README.md`. Device `passcodeRequired=true`.
- [FEITO] Fable→Codex: AtlasSession expor o TIPO da falha de rede (offline do device × timeout × conexão recusada × 401) — `AtlasSession.failureKind` + `AtlasNetworkFailureKind` entregues em `da9399a`.
- [FEITO] Codex→Fable: concluir a nova assinatura de `DraftStrip` (`reduceMotion` + `onFailedTap`) — fechado em `ed10c81`; `make build` verde.
- [FEITO] Codex→Fable: U3 executado em `97c9fdc` — Ribbon com atividade AO VIVO (ícone por kind + título + detail, transição por passo, Reduce Motion ok) + ExecutionProof persistente/expansível (passos + decide c/ razão + quality colorido). Zero parsing de wire na View. Acceptance no device pendente da sessão de prints.
- [FEITO] Codex→Fable: as 4 fontes LIGADAS — fotos/arquivos/clipboard (`97c9fdc`) + câmera (`105b1ae`, CameraPicker + NSCameraUsageDescription). Todas convergem no engine único C3.
- [FEITO] Codex→Fable: WIP de U4 em RootView — era estado intermediário; `failureHeadline`/`failureHint` existem desde `a582dac` e `make build` está verde (2× exit=0). Gate destravado.
- [FEITO] Codex→Fable: where explícito nos dois cases (`.idle where … , .loading where …`) em `97c9fdc` — semântica: loading mostra estado de espera só sem conteúdo em tela.
- [FEITO] Codex→Fable: `ComposerPrefs` DELETADO em `97c9fdc`; View usa exclusivamente `model.effort`/`model.cycleEffort()`. Boundary check verde.
  **Não criar `ComposerPrefs`**: isso duplica a fonte já entregue e só contorna
  o nome do gate. Apagar esse helper, remover `@State effort`/`.onAppear` e usar
  exclusivamente `model.effort` + `model.cycleEffort()`. O boundary agora varre
  toda a camada de apresentação (não só arquivos chamados View) e fica vermelho
  enquanto rede, JSON ou storage escaparem dos models/Core.
- [FEITO] Codex→Backend: `f356bd4a1` projeta o ACP Hermes/Kimi em eventos
  provider-neutral `thinking|tool|token`, preserva o lifecycle seguro das tools,
  aceita `tool|thinking` no recorder/constraint e bloqueia resposta final com
  frame explícito de Reasoning. `d77cf5a` faz o mobile solicitar ACP e projetar
  essas tools sem parsing na View. Prova live real: `shell.started` chegou antes
  de `done`, ficou observável por mais de 5s, persistiu e reapareceu no replay.
- [FEITO em `f6fbe79`] Codex→Fable: substituir o botão que lê `UIPasteboard.general`
  diretamente por `PasteButton` nativo. No iOS 26 o fluxo atual abre “Permitir
  Colar”, bloqueia a automação e cria fricção real; o rich input Core já aceita
  o texto pelo seam existente, portanto é correção exclusivamente da casca.
- [FEITO em `f6fbe79`] Codex→Fable: `ConversationView.swift` chegou a 930 linhas (split → ConversationChrome/Cockpit + DraftThumb cacheado) (régua da
  constituição: view ~200) e `DraftThumb.body` ainda executa `UIImage(data:)`.
  O Core `3b80c72` agora entrega thumbnail ≤256px, então separar os componentes
  existentes e cachear a imagem decodificada pode ser feito só na casca, sem
  duplicar engine. Validar scroll/composer com Instruments no iPhone físico.
- [FEITO] Codex→Fable: `9af0b72` reprovou a jornada com Hermes/Kimi já
  sanitizado. O XCUITest encontrou a tool durante a execução, abriu a prova de
  9 passos e confirmou `Comando concluído` visível/tocável após o replay. O
  falso bloqueio anterior era agravado pela resposta Reasoning-only gigante;
  C8 corrigiu o conteúdo canônico. Prova física continua sendo o gate de C7/U3.

- [ABERTO · DEVICE FÍSICO] U1–U6
  implementados, gates verdes, instalados no iPhone (`ed10c81`→`105b1ae`),
  evidência estática capturada (docs/evidence/2026-07-13: dados reais, AXXXL,
  splash). A prova INTERATIVA no físico (foto→strip→envio, cockpit vivo) tem
  TODOS os canais autônomos fechados — provado nesta sessão: osascript/System
  Events → erro -1719 (Acessibilidade negada); computer-use → exige aprovação
  interativa do operador; devicectl → sem verbos de input/screenshot; simctl →
  sem injeção de toque. O alvo XCUITest C7 foi entregue em `9af0b72`/`9b92a8a` e está
  verde no Simulator com Hermes/Kimi; no iPhone físico, o preflight continua
  impedido porque o aparelho reporta `passcodeRequired=true`. Desbloquear o
  device é a única mudança externa necessária para repetir a mesma prova. Em
  `df55878`, o harness passou a detectar isso antes do Xcode, terminar com `rc=2`
  e preservar `.xcresult`/screenshots anteriores em vez de aguardar e corromper
  evidência parcial.
- [FEITO na FONTE em `9a06fd4c56` (atlas-server): checkpoint 'verify' publica diff_stats {files_touched,lines_added,lines_removed} medidos por git shortstat quando há workspace; sem workspace o campo é ausente (UI não inventa). Parser puro testado. Falta o decode AtlasCore + binding da pílula (Codex/Fable próxima rodada).] **Diff ao vivo durante a execução.** A cena da
  proposta mostra a pílula contando `+48 −12` ENQUANTO o Atlas edita. Hoje o
  diff só existe pós-turno (C15/change review); não há estatística incremental
  em nenhum evento do stream. Pedido: agregado provider-safe por trace
  (`files_touched`, `lines_added`, `lines_removed`) atualizado nos checkpoints
  reais. Sem isso a casca NÃO renderiza número — a pílula fica só com o passo
  N/M (C10), que já é honesto.

- [FEITO na FONTE em `4b2b61f974` (atlas-server): todo replan arquiva o execution_plan corrente em plan_revisions[] (revision, iteration, reason, archived_at, plano completo; cap 10; nada fabricado). PHPUnit 4/14 verdes. Falta decode AtlasCore + UI 'comparar versões'.] **Histórico/versões do plano (replanejamento).**
  `AtlasExecutionPresentationState.replanning` existe e a casca mostra a fase,
  mas a cena 02 pede "plano v1 arquivado · comparar versões": qual passo saiu,
  quais entraram e por quê. Não há contrato de revisão de plano. Pedido:
  versionar `execution_plan` (v1..vN) com o motivo público da mudança e o diff
  de passos. Até lá a casca mostra só o plano corrente + a fase Replanejando.

- [PARCIAL · C20 · substância entregue por Fable em `AutonomosView.operationDigest` (agrega delivered/backlog/taskHealth REAIS: entregas comprovadas, pendências por risco, decisões aguardando, incidente por exceção). Falta SÓ o agendamento (`next_digest_at`) e o resumo governado por janela — contrato do servidor abaixo.] **Digest agendado do Autônomos.** A missão noturna
  termina com "07:30 · resumo ao acordar" e o Command Center fala em digest por
  exceção. Não há endpoint de digest nem `next_digest_at`. Pedido: resumo
  governado por janela (entregas comprovadas, riscos, decisões pendentes) + o
  horário do próximo. Sem contrato a casca não inventa horário nem resumo.

- [FEITO na FONTE em `9a06fd4c56` (atlas-server): council persiste council_review por membro (provider, model, status, response_hash, error_code, latency_ms) no metadata do trace — posição por papel sem raciocínio privado; divergência = status distinto, jamais voto inventado. Falta decode AtlasCore + card na casca.] **Consenso/pareceres entre agentes.** `trace.jobs`
  já dá agentes reais com status (a casca renderiza) e o change review dá
  findings; mas "revisor objetou → verificador comprovou → consenso" não tem
  contrato. Pedido: quando o workflow for multi-agente, expor a posição pública
  de cada papel e o veredito final (sem raciocínio privado). Até lá a casca
  mostra agentes+status e achados, nunca uma narrativa de consenso.

- [PARCIAL · C11 · Codex→Fable] **Fila real, pronta para a cena 11 do mock
  vencedor.** O seam é `model.queuedMessages: [QueuedMessage]` (`id`, `text`,
  `createdAt`), `queue(text:)`, `promote(id:)` e `removeQueued(id:)`.
  `ConversationModel.send` chama `queue(text:)` automaticamente quando um
  turno está ativo; a casca mantém o composer usável e NÃO troca-o por um
  cartão de status. Renderizar o chip apenas quando `queuedMessages` não for
  vazio: `Fila N`; ao tocar, abrir a folha da cena 11 com texto, **Enviar
  agora** → `promote(id:)` e apagar → `removeQueued(id:)`. “Enviar agora”
  significa ser o próximo turno, nunca cancela nem substitui o ativo.

  A fonte é Foundation-only, JSON atômico por conversa, sobrevive a relaunch e
  migra `local:*` para `thread:*` quando o create devolve a thread canônica.
  O detalhe crítico já está fechado: `peek` → `InteractionOutbox` durável →
  recibo `persisted` → remoção da fila. Se o app morrer em qualquer ponto, o
  vínculo local `followUpId` reabre a outbox e reconcilia a mensagem sem perda
  nem envio duplicado. Não exibir número, fila ou confirmação inventados:
  tudo vem de `queuedMessages`. Evidence: `da25e8a` + hardening C11 desta
  sessão; `swift run AtlasCoreChecks` e `cd App && make build` verdes em
  2026-07-13. Falta somente a ligação visual Fable + prova no device.
- [FEITO] Fable→Codex: contrato U3 está estável desde `cededd4`/`bb8ecea`:
  `ChatBubble.currentActivity`, `activities`, `decisionSummary` e
  `qualitySummary`, sem parsing de wire na View. Replay live confirmou que o
  ledger real reconstrói `process_started`/`process_finished`; o decoder também
  aceita o resource atual de tool receipt (`kind` + `occurred_at`) e o legado.
  A tabela `ai_tool_events` está vazia neste ambiente, portanto comandos reais
  vêm hoje dos `stream_events`; a View deve renderizar ambos pelo mesmo array
  `activities`. U3 está desbloqueado — não aguarda outro contrato Codex.

- [ABERTO · M65 · GPT-5.5→Codex/Fable] Resposta de texto em notificação → fila — o seam `ConversationModel.queue(text:)` existe, mas as notificações de conclusão atuais não declaram categoria/action de texto nem carregam thread canônica suficiente para recriar o model com segurança no delegate único (`NightlyProposalController` já ocupa `UNUserNotificationCenterDelegate`). Sem payload `thread_id` + categoria `UNTextInputNotificationAction` + roteamento explícito, não ligar `UNTextInputNotificationResponse` para não enfileirar em conversa errada.

- [PARCIAL · C8 · Codex→Fable] **ActivityKit inteiro está ligado ao runtime**:
  `AtlasWidgets`, entitlement, token de update por Activity, token
  push-to-start por instalação, bridge `AiStreamRecorder`→APNs, contador por
  instalação, encerramento/notificação editorial e deep link
  `atlas://execution/<trace>` já existem. A casca Fable deve manter as cenas
  da Lock Screen/Dynamic Island exatamente como `fable-5.html`, sem criar um
  segundo card/estado. Falta apenas prova no iPhone físico com capability Push
  Notifications e credenciais APNs externas no cofre; até isso acontecer, não
  anunciar push remoto como validado.
- [ABERTO] Fable→Codex: **C9 — hook de conclusão de turno**: no finalize do
  ConversationModel/InteractionRun, quando `UIApplication.shared.applicationState
  != .active`, chamar `TurnNotifier.turnCompleted(threadTitle:excerpt:)` (casca
  entrega o TurnNotifier via UserNotifications — sem rede/JSON/storage).

- [PARCIAL · C10 · Codex→Fable] Fable→Codex: **C10 — plano e narração pro mock
  'Execução Viva'**: o Terminal agora publica em `a2ac1263e` seis etapas
  verificáveis no `execution_plan` (`intent`, `context`, `plan`, `provider`,
  `verify`, `evidence`) — exatamente os checkpoints já registrados pelo
  Gateway/Worker no ledger. No Native, `AtlasExecutionPlan` +
  `ChatBubble.executionPlan/executionProgress` projetam somente workflow,
  papéis, ferramentas autorizadas, gates e o último checkpoint observado;
  sobrevivem a polling/reload. A UI pode mostrar, por exemplo, `4/6 · Executar
  a solicitação` apenas com esse dado real. Em trace legado/sem checkpoint,
  `executionProgress == nil`: não renderizar número, barra ou 'agora' por
  inferência de tools. Golden checks cobrem decode, progresso e redaction; a
  narração continua vindo apenas de eventos públicos seguros classificados em
  `AtlasAgentActivity`, sem chain-of-thought.

  **Binding exato do mock:** no turno em execução, se
  `bubble.executionProgress` existir, o cabeçalho/ribbon pode mostrar somente
  `\(current)/\(total) · \(title)` e usar `executionPlan.steps` como a lista
  expandida. Se for `nil`, manter apenas a timeline de atividades reais — não
  preencher barra, passos ou porcentagem com estimativa visual. Para Live
  Activity/Lock Screen, a fase é o mesmo `executionProgress?.title`, com
  fallback honesto para `currentActivity?.title`; nunca texto de raciocínio.

- [PARCIAL · C14 · casca ligada em `06f88b5` (TurnPresence observa presence/traceId; ContentState aditivo paused/pausedDisplay; Widgets congelam ‖ m:ss; notificação só por fase terminal) — falta prova no device] **Presence é agora um contrato único, não uma
  animação.** `ConversationModel.currentExecutionPresence` entrega somente
  `phaseTitle`, `timing` (`running|paused|finished`), `isOngoing` e, para a
  pausa emitida pelo servidor, `pauseTimestamp`; a chave canônica é
  `currentExecutionPresenceTraceId`. Quando existir, o relógio vem em
  `presence.elapsedActiveMilliseconds` + `presence.runningSince`: o servidor
  acumula somente tempo ativo e persiste cada marco, portanto esse é o único
  relógio permitido após pause/resume, reconnect, relaunch ou handoff. Em trace
  legado, ambos ficam `nil`: mostrar a fase, sem fabricar duração. `TurnPresence`
  e Widgets devem observar esses seams — não `bubbles.last?.currentActivity`,
  `isSending` ou status cru — e manter a mesma Activity enquanto `isOngoing`
  for verdadeiro, mesmo se o stream da tentativa fechou em
  `awaiting_user_choice`.

  Para `paused`, o título deve ser `Aguardando decisão` ou `Aguardando sistema
  externo`, o contador de sessões continua ativo e o timer mostra exatamente
  `elapsedActiveMilliseconds`, sem contar a espera. Para `running`, contar a
  partir de `runningSince`; para `finished`, congelar o acumulado e encerrar
  com a fase pública. Nunca iniciar com `pensando…`, nunca finalizar/avisar
  “Atlas respondeu” apenas porque `isSending` virou falso. Alterar
  `AtlasTurnAttributes.ContentState`/Widgets de modo aditivo para carregar o
  acumulado e o marco de retomada necessários à Lock Screen e à Dynamic Island,
  preservando o deep link pelo trace.

- [PARCIAL · Continuidade · Codex→Fable] **Handoff entre superfícies preserva
  a mesma thread e sessão.** `ConversationModel.handoffToSurface(_:)` aceita
  somente `.mobile`, `.desktop` ou `.terminal` e publica
  `model.latestSurfaceHandoff` apenas depois de `POST
  /ai/threads/{thread}/handoff-surface`. O recibo tem `threadId`, `sessionId`,
  origem, destino e status `ready`; não inclui brief, prompt, metadata, provider
  nem conteúdo. A casca deve oferecer a ação só para uma conversa canônica e
  dizer **“pronto para abrir no destino”** apenas com o recibo. O destino abre
  a thread pelo `threadId` existente: não cria conversa, sessão, histórico ou
  timer novos. Ainda falta a ligação visual/deep link do Fable, a abertura no
  Desktop e a prova cruzada em device; portanto a cena 08 não está entregue.

- [FEITO · Continuidade · Codex] O Atlas Terminal já consome uma thread de
  outra superfície por `atlas:cli:state --thread=<threadId>`: a referência
  explícita não é mais filtrada por `surface=atlas_cli`, preserva a mesma
  sessão e não cria clone. A descoberta automática continua limitada à thread
  CLI do workspace atual. Fable ainda precisa acionar o recibo e abrir o
  destino; Desktop e prova cruzada no iPhone permanecem pendentes.

- [PARCIAL · C15 · casca ligada em `06f88b5` (ChangeReviewSheet: unavailable explícito, diff canônico c/ aviso de hash, aceite por arquivo/run pós-recibo; entrada "Revisar mudanças" na conversa) — falta prova com trace real] **Artefatos e revisão só existem quando o
  trace os prova.** A casca deve chamar
  `model.refreshChangeReview(traceId:)` apenas para o trace da bolha e renderizar
  `model.changeReviewsByTrace[traceId]`. `state == unavailable` é um estado
  explícito (com `reason`); não mostrar arquivos, checks, diff ou botões.
  `state == available` fornece os patches, controles, testes e findings já
  persistidos, todos sem `engineering_run_id`. Para abrir um diff, chamar
  `model.refreshChangeReviewDiff(traceId:patchId:)` e renderizar apenas
  `model.changeReviewDiff(traceId:patchId:)`; nunca fazer rede na View, usar a
  rota genérica de engineering ou tratar `diffURL` como autorização.

  `accept` no run agora significa **aceitar todos os arquivos capturados** e
  depois aceitar o run: chamar `model.applyChangeReview(traceId:action:note:)`
  e só atualizar depois do `reviewReceipt`. Para um arquivo, a casca deve
  renderizar somente `patch.fileReviews` e chamar
  `model.applyChangeReviewFile(traceId:patchId:filePath:action:note:)` — o
  model exige primeiro que `(trace, patch, file)` já pertença à projeção
  canônica e depois confere o mesmo triplo no recibo. O servidor persiste o
  estado atual por `(patch,file)` ligado ao `diff_hash`; o recibo é lifecycle
  `trace_change_review_file_decided`. Não criar aprovação otimista, badge
  'verificado' ou resultado de check derivado do texto. Se falhar, manter a
  projeção anterior e mostrar o erro do model.

- [FEITO · gate · Fable] A assinatura `WorkspaceView(..., freeOnly:)` está
  coerente na casca atual; `cd App && make build` passou em 2026-07-13. Nenhum
  Core/model foi alterado para contornar a integração visual.

- [PARCIAL · C13 · Codex→Fable] **Autônomos é área 24/7 própria**: o Core porta a
  superfície existente `ai/software-company-stewardship/loop` em
  `AtlasAutonomos*` (áreas, lock/live, ciclos, backlog, entregas comprovadas e
  recibo de pause/resume/kill). `AutonomosModel` é uma fonte separada de
  `ConversationModel` e já entra por `AtlasSession.autonomos`.
  `RootView.Route.autonomos` + `AutonomosView.swift` entregam a entrada própria
  “Autônomos”: áreas registradas, lease real, objetivo, sistemas, ciclos,
  backlog/inbox e controles com operador+motivo obrigatórios. A conversa não
  é usada como fonte da Frota. O estado `executando` só aparece com
  `run_state.lock.held`; a casca não exibe host, tarefa, uptime ou prova que o
  endpoint ainda não forneceu. **Fable deve renderizar `model.delivered` como
  “entregas comprovadas”: ele contém somente ciclos com `outcome=merged`,
  `merge_performed=true` e `merge_hash`, nunca backlog/plano inferido.** O Core
  agora também expõe a frota global real em `model.fleet` e seu ledger
  append-only em `model.fleetHistory`: cada agente traz `alive`, `status`,
  uptime, PIDs, gasto e estado desejado/autorizado; esses dados **não** são
  associados artificialmente à área selecionada. A casca deve criar a seção
  “Frota global” a partir desses tipos, e projetar somente campos públicos do
  histórico (não `detail` JSON cru). Remover leitura direta de `JSONObject` da
  View conforme cada tipo público do Core existir. Para placement, usar somente
  `model.live?.runtimePlacement.host/acquiredAt/leaseTTLSeconds/environment/workspace/repository/branch`
  e `area.repositoryNames`: todos são derivados no Core dos campos que o servidor
  realmente publica. Workspace, repositório e branch são rótulos do lock real,
  nunca caminho absoluto nem inferência da área/repo; se ausentes, permanecem
  desconhecidos. O contrato de início também
  é tipado: `execute` exige `operator_reason`, retorna somente o recibo
  `enqueued` e deixa a execução depender do lease real. Provas: 35 testes PHP
  / 276 asserts para os comandos HTTP do loop, 33 testes PHP / 198 asserts para
  loop+governança; `swift run AtlasCoreChecks` + `make build` verdes. Faltam
  missão, histórico completo, evidência e prova no device
  antes de chamar a vertical de completa.

- [FEITO em `06f88b5`] `AutonomosView.controls(for:)` não pode usar
  `model.live?.readOnly` para desabilitar pause/resume/encerrar: esse campo
  descreve o **GET** `/live`, enquanto os POSTs de controle existem, exigem
  operador+motivo e retornam recibo. Usar exclusivamente
  `model.canControlSelectedArea` para disponibilidade do controle. A ação
  continua a passar por `model.control`, sem chamar rede na View.

- [FEITO em `06f88b5`] Migrar os badges de área/loop de
  `runState["…"]` para `area.loopStatus.phase` e
  `model.live?.loopStatus.phase`. O Core resolve os sinais reais com a ordem
  `terminated > paused > running > idle`; a View não deve reproduzir nem
  reinterpretar essa lógica.

- [FEITO em `06f88b5` (ensaio default; executar coleta ator+motivo; recibo mostrado como "na fila · ainda não iniciado")] O novo início de ciclo passa somente por
  `await model.startRun(mode:operatorActor:operatorReason:)`. O default visual
  deve ser `dry_run`; para `execute`, coletar ator e motivo auditável antes de
  chamar o model. Depois, mostrar `model.lastStartRunReceipt` como **na fila,
  ainda não iniciado** quando `isEnqueued`; jamais promovê-lo a “executando”.
  O único sinal de execução continua sendo o lease relido em `model.live`.

- [ABERTO · C13 · Codex→Fable] A decisão de finding usa exclusivamente
  `await model.decide(_:findingHash:operatorActor:rationale:riskLevel:...)` e
  o recibo `model.lastDecisionReceipt`. Para `accept` de risco `high` ou
  `critical`, coletar justificativa antes do envio. Mesmo quando aceito,
  apresentar como **decisão registrada, execução pendente do owner** somente
  se `isRecordedDecisionOnly`; o contrato AP-724 proíbe apresentar branch,
  provider, mutação de repo ou execução como ocorridos.

- [PARCIAL · C13 · Codex→Fable] **Transferência real da mesma missão está
  contratada.** `POST /loop/{area}/transfer` exige ator, motivo e um lock vivo;
  persiste um recibo AP-790 ligado ao `run_id` fonte, pede yield somente no
  limite seguro, guarda checkpoint, enfileira o sucessor com o mesmo
  `area+focus` e o marca `target_claimed` apenas depois de ele adquirir o lock.
  O Core expõe `AtlasAutonomosTransferInput/Response/Handoff` e
  `AutonomosModel.transfer`/`refreshTransferStatus`. Fable deve oferecer a ação
  somente por `await model.transfer(operatorActor:reason:)` e projetar os
  estados `transfer_requested`/`source_released`/`successor_enqueued`/
  `target_claimed` literalmente. Não escolher, mostrar ou prometer host alvo
  antes de `target_claimed`; `model.lastTransferReceipt.handoff.checkpoint` é a
  única fonte do checkpoint. Prova Codex: TDD red→green, 4 testes PHP/29
  asserts + `swift run AtlasCoreChecks` verde. Falta renderização Fable e prova
  no iPhone.

- [FEITO · C13 · Codex] **Placement e topologia segura do runtime.** O lock
  AP-790 passa a registrar no instante da aquisição somente os rótulos
  verificados `environment`, `workspace`, `repository` e `branch`; a API
  `/live` remove recursivamente `path` e `ledger_path` antes de responder. O
  Core decodifica esses rótulos em `runtimePlacement`, sem a casca ler JSON ou
  receber caminho absoluto. Prova: TDD red→green no runner (14 asserts),
  `LoopCommandSurfaceTest` (45 asserts nos cenários live/control),
  `swift run AtlasCoreChecks` verde. Fable pode exibir somente os seis campos
  públicos de placement; ausência de branch não deve receber fallback visual.

- [FEITO · C13 · Codex] **Saúde real da fila do músculo externo.**
  `GET /agents/task-health` projeta somente contagens verificáveis da fila,
  integridade de leases, flags de incidente e uma recomendação operacional
  publicada pelo servidor. `AtlasAutonomosTaskHealthResponse` chega em
  `AutonomosModel.taskHealth` como dado global: não pertence artificialmente à
  área selecionada. O endpoint nunca devolve task packet, objetivo, prompt,
  path, intervenção ou instrução executável. Prova TDD red→green: API 26
  asserts; golden DTO; `swift run AtlasCoreChecks` e `make build` verdes.

- [FEITO em `06f88b5` (saúde da fila: contagens+leases; incidente só quando present=true, com flags+recommendedAction)] Na seção **Frota global**, a casca pode mostrar
  `model.taskHealth` somente como saúde da fila: `servableNow`, `claimed`,
  `blocked`, `completed`, `recoverable`, leases e incidente. Não chamar isso
  de lista, plano, missão, percentual de progresso ou task ledger: ainda não
  existe uma relação área→packet nem títulos públicos sanitizados. Em
  `incidents.present == false`, não criar alerta; em `true`, renderizar apenas
  `incidents.flags` e `operating.recommendedAction` publicados pelo Core.

- [PARCIAL em `06f88b5` (frota global real por model.fleet.agents: status/alive/uptime/pids/gasto/desired/authorized + fleetHistory público + placement do lock + entregas comprovadas + transferir com estados literais) — falta prova no device] A tela atual ainda não reproduz o Command Center da
  referência: `fleetSummary` conta áreas, não `model.fleet.agents`; faltam os
  cards da frota global com somente `status`, `alive`, `uptimeSeconds`, PIDs,
  gasto e estado desejado/autorizado reais, e o histórico deve vir de
  `model.fleetHistory.events` sem expor `detail` cru. Mostrar heartbeat,
  incidente, progresso, missão transferida ou digest apenas quando o endpoint
  oferecer o campo/prova correspondente. `abrir instância` ainda não tem
  contrato Server: não criar affordance decorativa; pedir contrato ao Codex
  antes. `transferir missão` tem o contrato acima; usá-lo sem inventar
  placement/host futuro.

- [ABERTO · QA real 2026-07-13 · Codex→Fable] **A casca foi exercitada contra
  o servidor de verdade no iPhone 17 Pro Simulator**: thread carregada, turno
  `Responda somente com a palavra ATLAS.`, cinco eventos vivos, resposta final
  `ATLAS`, receipt `8 passos · 10,8 s · quality 85.0` e prompt nativo de
  notificação apareceram. O mock precisa preservar estes fatos, mas há três
  correções visuais obrigatórias antes de chamar U2/U3 de polidos: (1) a faixa
  “Seguindo a execução · N eventos · tempo · Parar” não pode quebrar o título
  em duas linhas nem competir com a caixa de escrita; ela deve seguir a régua
  compacta do mock vencedor; (2) os pills `geral` e `auto` encolheram até
  sobrar apenas o ponto — nunca esconder rótulo ou criar controles sem
  significado; usar prioridade/overflow explícito em largura iPhone; (3) a
  conclusão não pode deixar um composer gigante de controles vazios quando o
  operador não está compondo. **Não alterar o fluxo Core nem trocar a
  linguagem visual do Fable por uma cópia Cursor.** Evidência local desta
  sessão: `/tmp/atlas-native-live.png` e `/tmp/atlas-native-complete.png`.

- [EM ANDAMENTO · C8 APNs real 2026-07-13 · Codex] A Live Activity deixa de
  ser uma janela local: `AtlasLiveActivityRegistrationInput` registra o token
  **rotativo por atividade** contra o `traceId` real; o bridge nativo usa
  `Activity.request(..., pushType: .token)` e espera o trace confirmado antes
  de enviá-lo. O servidor possui agora `POST /ai/live-activities` e
  `POST /ai/live-activities/{activityId}/invalidate`, tabela cifrada por token
  e `AtlasLiveActivityPushService`: cada `AiStreamRecorder` publicado projeta
  só checkpoint público para APNs (sem prompt/stdout/reasoning), com debounce
  e contador por instalação. **Fable não deve desenhar selo “remoto” nem
  mudar a régua visual:** o mesmo card/Lock Screen segue a verdade do estado;
  esta entrega só troca o transporte.

  Para fechar C8 em iPhone físico faltam duas credenciais externas que não
  podem entrar no Git: habilitar Push Notifications para
  `com.vitor.atlas.native` no Apple Developer e instalar no cofre
  `ATLAS_LIVE_ACTIVITIES_APNS_KEY_ID`, `..._TEAM_ID`,
  `..._PRIVATE_KEY`, além de `ATLAS_LIVE_ACTIVITIES_ENABLED=true`. O app já
  declara `aps-environment` e `NSSupportsLiveActivitiesFrequentUpdates`; sem
  essas credenciais o servidor é no-op honesto e a experiência permanece
  local, nunca “24/7” de mentira.

- [FEITO em `71c30b2`] Fable→casca: **PlanCard** renderiza `bubble.executionPlan`
  (workflow, passos com done/atual/pendente do checkpoint real, tools/agentes/
  gates) — antes o plano computado pelo Core era invisível. Aparece ao vivo
  (percorrido) e persistente. Sem `executionPlan` no trace, o card não existe.
- [FEITO em `71c30b2`] Fable→casca: `ExecutionStateCard` passou a renderizar
  `state.actions` para QUALQUER kind (não só `attentionRequired`), roteando por
  `onChoose(jobId, action.id)`. Assim uma falha/espera recuperável com ação
  declarada pelo servidor aparece sozinha — sem botão inventado.

- [FEITO em `0482886` · C17 · fim-a-fim] **Retomar turno após falha (cena 13).**
  Endpoint `/ai/jobs/{id}/retry` já existia; a casca agora fecha o ciclo:
  `bubble.retryableJobId` (do `trace.jobs` com status `failed`) +
  `model.retryTurn(jobId:)` (chama `retryAiJob`, relê o trace) + botão
  "Retomar" no `ExecutionStateCard` de kind `.failed`. Zero fake. Build verde.
  (Nota: o commit persistiu também seams C14/C15/continuidade do Codex que
  estavam no working tree — tree consistente e buildando.)
- [OBSOLETO — ver acima] Fable→Codex: **Retomar turno após falha (cena 13).** Hoje a
  falha é honesta (fase `Falhou` + notificação), mas não há ação manual de
  retomar. Duas formas de destravar, qualquer uma serve: (a) o servidor declara
  uma `action` (ex.: "Retomar do último checkpoint") no
  `AtlasExecutionPresentationState` de kind `.failed`/`.awaitingExternal` e
  expõe o `jobId` correspondente em `bubble.executionChoiceJobId` — a casca já
  renderiza e roteia por `resolveExecutionChoice`; OU (b) `model.retryTurn()`
  usando o `client.retryAiJob` que já existe, com `bubble.retryableJobId`
  vindo de `trace.jobs`. Prefiro (a): reaproveita todo o caminho já ligado.
  A casca não pode chamar `retryAiJob` direto (rede fora do model).

- [ABERTO · C18 · Fable→Codex] **Resumo da mudança por eixo (recibo de
  conclusão).** A `ExecutionProof` mostra passos, decide e quality, mas não os
  "eixos" nomeados (IDIOMA/MÉTRICAS/LEITURA da proposta). Isso exige o servidor
  classificar as mudanças do run em eixos rotulados. Se `AtlasTraceChangeReview`
  (ou o trace) expuser `changeAxes: [{label, summary}]`, a casca renderiza a
  grade de eixos na prova. Sem o contrato, não inferir eixos de texto.

- [ABERTO · C19 · Fable→Codex] **Digest do Autônomos (missão noturna · "resumo
  ao acordar").** A `AutonomosView` mostra frota, saúde e ciclos, mas não o
  digest agendado. Pedido: `GET /autonomos/digest` (ou campo em `/live`)
  expondo `nextDigestAt` + o último digest publicado (mudanças, riscos,
  decisões pendentes) — tudo provider-safe. A casca renderiza a seção "próximo
  resumo" e o último. Sem endpoint, nada é mostrado (nunca horário inventado).

- [ABERTO · C20 · Fable→Codex] **Consenso entre agentes na revisão (cena 07).**
  O `ChangeReviewSheet` já mostra findings; falta o painel de "pareceres +
  consenso". Se `AtlasTraceChangeReview.review` (ou o run) expuser
  `agentVerdicts: [{role, position, objection?, evidenceRef?}]` + `consensus`,
  a casca renderiza a seção. Não expor raciocínio privado — só posição,
  objeção relevante e evidência, como o contrato do mock exige.

- [ABERTO · C21 · Fable→Codex] **Histórico de plano (replanejamento · comparar
  versões, cena 02).** A fase `Replanejando` já surge no `ExecutionStateCard`;
  falta o "plano v1 arquivado · comparar versões". Se o trace expuser
  `planRevisions: [AtlasExecutionPlan]` (ou o `executionPlan` carregar
  `previousVersions`), o PlanCard oferece "ver versão anterior". Sem contrato de
  histórico, o card mostra apenas o plano corrente (já entregue).

### Grafo Governado — evolução da proposta (tela M0 de `atlas-code-mobile.html`; superfície DESKTOP removida do escopo por decisão do operador em 15/07 — foco exclusivo no app nativo)

- [FEITO · C22 · Fable→Codex/Server] **Topologia real do grafo (fase E1).**
  `GET /api/code/graph?repo=` → `nodes[] {hash, parents[], refs[], authorEmail, when}`,
  `worktrees[]` — computado de `git log --all --topo-order --parents` +
  `git worktree list` no Mac (local-first), read-only, cache incremental por
  fingerprint de refs. O servidor e o app nativo têm DTO, cliente e Canvas M0 com
  curva midpoint. Gate do simulador fechado em 2026-07-15: screenshot real com
  200 nós e prefixos de hash idênticos ao `git log --all --topo-order --parents`;
  prova anexada em `docs/evidence/atlas-code-e1/`. O aparelho físico permanece
  `device-pending`.

- [FEITO · C23 · Fable→Codex/Server] **Identidade + proveniência por commit (E2).**
  Cada nó enriquecido com `agent {fable|codex|voce|autonomo:<nome>}` + `traceRef`
  (ledger já carimba). Tocar → `GET /code/provenance/{hash}` devolve a frase de
  origem do operador (trace real) + gates. Sem trace: "sem proveniência
  registrada" — nunca inventar. Implementado com autor→agente explícito,
  correção append-only para registros inválidos, endpoint C23 e folha nativa;
  três commits reais de `atlas-native` foram conferidos contra Git e ledger.

- [FEITO · C24 · Fable→Codex/Server] **Violações do rules engine (E3).**
  `violations[] {ruleId (canon), target, since, severity, plan?: steps[]}` das
  regras do canon: main-only pétreo, allowlist de worktrees, obra→main ≤ N dias,
  branch órfã, drift de espelho. O scanner puro, endpoint, comando, DTO nativo,
  tag nativa e `App/scripts/atlas-code-sandbox.sh` estão entregues. Prova real:
  o simulador exibiu `Sinais de governança` e regras/targets vindos de
  `/api/code/violations`; a cobaia isolada criou `atlas-code-cobaia` e voltou a
  `main` sem tocar nos workspaces. A prova física permanece `device-pending`.

- [FEITO · C25 · Fable→Codex/Server] **Auto-remediação 24/7 (E4) — corrigido
  pelo canon do operador.** Violação detectada → o Atlas executa o plano
  SOZINHO (ex.: cherry-pick → branch -d → citar regra ao agente), emitindo
  `step_receipts` no ledger + push de estado. Política por regra: `observar`
  (só aponta — modo de rampa de confiança) | `curar` (alvo: autonomia total,
  ninguém no caminho). O humano NÃO aprova plumbing — tem veto retroativo:
  `undo` governado, com recibo. Canon: Autônomos trabalha 24/7 e nunca depende
  de ninguém; Forge commita até a obra completa; todos na main local, cada um
  com seus commits. O papel humano converge para usuário que abre o app e
  sente a diferença. Decisão humana continua existindo SÓ para o que é
  genuinamente dele (produto, preço, risco) — nunca para operação.

- [FEITO · C26 · Fable→Codex/Server] **Prevenção + a semana (E5).** Preflight
  consulta a Lei antes da ação, registra bloqueio quando necessário, e o card
  semanal deriva commits do Git e curas/prevenções do ledger. `observe` e
  notificações ficam desligados por padrão; o app não inventa contadores.
  A janela de duas semanas do canon é acompanhamento contínuo, não declarada
  como provada nesta noite.

**Docs do domínio Atlas Código:** spec de implementação autossuficiente (payloads,
gates, ordem — para QUALQUER IA) em `docs/atlas-codigo-evolucao.md`; plano-mestre
(inventário de todas as telas + estados + fases E0–E5 + horizontes H1–H6) em
`docs/proposals/atlas-codigo-plano.html`. A spec vence improviso; o canon vence a spec.

- [INFO · SOTA F0 · Grok→Codex/servidor] Após a poda F0 do app, estas rotas
  ficam sem chamador nativo (não mexer no atlas-server nesta missão): todo
  `/ai/telemetry/*`, `/ai/policies/*`, `/ai/providers/*`, `/ai/decisions*`,
  `/ai/quality/*`, `/ai/attachments/search`, `POST /ai/threads`,
  `GET /ai/threads/{id}/state|snapshots`, `POST /ai/threads/{id}/compact|switch-provider`.

- [ABERTO · SOTA F5.1 · Grok→operador] **Baseline Instruments no iPhone físico**
  (cold launch <400ms; 0 hitches @120Hz em streaming 40k; grafo 200 nós; upload
  20MB <60MB incrementais). Sessão CLI sem Xcode+device Instruments: registrar
  números em `docs/evidence/perf-baseline/{antes,depois}/` quando o operador
  rodar. Roteiro: Instruments templates Time Profiler + Animation Hitches +
  Allocations; app Debug no device; capturar antes (pós-F1) e depois (pós-F2).
  NUNCA declarar alvos atingidos sem medição real.

## 5A. Decisões pendentes do operador (fixo · M80)

> Espelho operacional do §B de `docs/plano-profundidade-total.md`. Atualizar
> quando uma decisão for tomada; OBRA §6 vence o plano se houver decisão mais
> nova.

| Decisão | Status | Bloqueia | Default enquanto pendente |
|---|---|---|---|
| Nome da tela de medição no código | **DECIDIDO 2026-07-17: `AtlasArena*`, rota `.arena`, título "Arena"** | M61 | — |
| Arquivar OBRA §7 pré-15/07 em `OBRA-ARCHIVE.md` | PENDENTE | M60 | não arquivar |
| Commitar docs de planejamento (`docs/plano-*`, `docs/roadmap-*`, `docs/spec-*`) | **PARCIAL 2026-07-17:** autorizado `plano-elite-agentica-24x7` + design; resto permanece default untracked | M82 | só o que o operador autorizar |
| Paisagem para telas de leitura (hoje Portrait-only deliberado) | PENDENTE | M27 | manter Portrait |
| Adotar SwiftFormat/lint como gate | PENDENTE | M41 | não adotar |
| Biometria em ações destrutivas | PENDENTE | M53 | não implementar |

## 6. Decisões registradas

- **2026-07-17 · Plano Elite Agêntica 24×7 (operador):** missão contínua
  documentada em `docs/plano-elite-agentica-24x7.md` + design
  `docs/superpowers/specs/2026-07-17-elite-agentica-24x7-design.md`.
  **Leis:** (1) zero `Route` novas (9 cases; Arena já existe — deepen only);
  (2) fora do app (Island/lock/widgets/notif/StandBy/Controls) = liberdade
  total de variantes honestas; (3) ciclo A Implementar → B Comprimir →
  C Aprofundar → D Comprimir (repete C↔D); (4) **humano fora do fluxo
  operacional** — Autonomia > aprovação; ator+motivo só no start governado;
  veto com recibo; silêncio = produto; (5) Criação ≠ Medição (Arena, nunca
  Rivals no nativo); (6) Voice/Onda9/§B SKIP intocados sem nova decisão.
  Fila §4 Elite E0–E-D. Começar por A0/A1 (honestidade P0).

- **2026-07-17 · ADR M118 App Group SD-1:** superfícies externas do app nativo
  compartilham somente o arquivo `snapshot/atlas.native.snapshot.v1.json` no
  App Group `group.com.vitor.atlas.native`. App e `AtlasWidgets` declaram o
  entitlement; widget não faz rede, falha fechado em schema diferente/arquivo
  ausente e mostra staleness >6h. O snapshot contém apenas privacy `normal`
  e campos públicos já vistos pelos models (sessões, frota, semana, fila).

- **2026-07-17 · Grok 4.5 executa Profundidade Total** (`docs/plano-profundidade-total.md`, 155 itens ativos) com autorização do operador para atravessar as lanes (casca + engine + atlas-server quando o contrato exigir) nesta missão, sem ownership permanente. Write-scope: `App/Atlas/*`, `Sources/*`, `App/UITests/*`, `App/Widgets/*`, `docs/evidence/*` (append), `OBRA.md` (append §4/§5/§6/§7), e no atlas-server os caminhos exigidos pelos contratos das ondas. Gates §2/§3 invioláveis. Baseline 2026-07-17: `swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0; ambos repos em `main`.

- **2026-07-17 · Adendo M61 Arena DESTRAVADO (operador):** nome no código `AtlasArena*`, rota `.arena`, título "Arena" (Criação≠Medição — proibido "Rivals"/"benchmark" no código da Criação; servidor pode manter namespace Rivals; API pública `arena`). Escopo pleno já em §6 (índice composto, AGORA, rodar governado, capacidades, gráficos). Spec executável: `docs/spec-arena-medicao.md` (A1–A12). Posição: após contratos/casca sprint 1 (M07–M09, M15/M62/M11), antes das Ondas 2–8. Única rota nova autorizada (+1 em RootView).

- **2026-07-16 · F6.2 Multi-host: NÃO construir (YAGNI).** Seam futuro:
  `AtlasConfig` → coleção de hosts; outbox/fila re-escopadas por conta. Um host
  local (Mac :3737) é o produto. Construir multi-host agora seria fundação-pra-depois.

- **2026-07-16 · F6.3 Metal Graph Engine (N1): NÃO agora.** Com F2.9 (`LazyVStack`)
  o grafo aguenta a vertical atual. Horizonte registrado — não código.

- **2026-07-16 · Grok 4.5 executa a spec Próximo Patamar** (`docs/spec-proximo-patamar.md`)
  com autorização do operador para atravessar as lanes (casca + engine + atlas-server
  quando o contrato exigir) nesta missão, sem assumir ownership permanente.
  Write-scope: `App/Atlas/*`, `Sources/*`, `App/UITests/*`, `docs/evidence/*` (append),
  `OBRA.md` (append §4/§5/§6/§7), e no atlas-server os caminhos listados na spec V3/V4/V5.
  Pré-requisito SOTA (S1–S34) verificado: TurnStatus/A11yID/LoadPhase/atlasCard presentes;
  baseline checks+build verdes em 2026-07-16.

- **2026-07-16 · Grok 4.5 executa a spec SOTA 10/10** (`docs/plano-sota-10-de-10.md`)
  com autorização do operador para atravessar as lanes Codex/Fable durante esta
  missão, sem assumir ownership permanente. Precedente: decisão de 2026-07-15 da
  missão E1–E5. Write-scope da missão: `Sources/*`, `App/Atlas/*`, docs de poda
  listados na spec, `OBRA.md` (append §4/§5/§6/§7). Gates e leis de honestidade
  da §2/§3 permanecem invioláveis.

- **15/07 · Canon do app (operador):** o app nativo é a ferramenta de ENGENHARIA DE
  SOFTWARE mais completa possível da era agêntica. Dois pilares: **Atlas AI** (AX —
  conversa, execução viva, presença, fila, review; desenhado e shipando) + **Source
  Manager / Atlas Código** (o GitKraken do Atlas: grafo governado, proveniência,
  radar, espelho autônomo, cura 24/7; em construção). O fluxo fecha ponta a ponta no
  nativo: intenção → execução → review → grafo → espelho/release → a semana.
  Superfície desktop REMOVIDA do escopo (commit 26757d3).

- **2026-07-15 · Missão noturna E1–E5:** por autorização explícita do operador, a
  fronteira de casca da §1 fica suspensa somente para esta missão. Codex pode tocar
  `App/Atlas` para fechar provas verticais E1–E5, registrando cada contrato e sem
  assumir ownership permanente de design system ou views fora do Atlas Código.

- **2026-07-15 · E2:** o email `vitordsny@gmail.com` projeta para `voce`, sem
  inferir Codex/Fable a partir de autoria Git compartilhada. Proveniência só
  aparece quando há registro explícito no ledger; ausência de `trace_id` continua
  ausente na API e vira texto honesto na folha. Correções de hashes transcritos
  foram append-only, nunca apagadas.


- 2026-07-13 · Fable atravessou `project.yml` ADITIVAMENTE (target AtlasWidgets)
  sob autoridade de goal direto do operador (tela bloqueada = Cursor); WIP do
  Codex preservado. C8 remanescente pro Codex: entitlement/push APNs fase 2
  (update de Live Activity além da janela de execução) + hardening do target.
- 2026-07-13 · Fable corrigiu 2 erros Swift 6 no próprio TurnPresence
  (Activity<T> não-Sendable → enumeração estática dentro da Task).
- 2026-07-13 · C8 APNs usa token por `Activity.id` + `trace_id` e
  `installation_id`, jamais `expo_push_token` ou o token de autenticação do
  Atlas. O payload remoto é a projeção mínima de `AtlasTurnAttributes`: fase
  pública, início, conclusão e sessões da mesma instalação.

- 2026-07-12 · Engine única contract-first no AtlasCore (painel 2 juízes);
  dossiê completo em `docs/rich-input-shared-core.md`.
- 2026-07-12 · Chunk 1.5MB único (mata drift RN 768KB) · resume com
  installSalt · source_hash preenchido (CryptoKit) · SEM fallback multipart ·
  text_blocks default = documento (inline é opt-in por fluxo).
- 2026-07-12 · Modo do composer (geral/operacional/…) é UI-only até existir
  campo de wire no chat — NÃO inventar contrato.
- 2026-07-12 · Sem TCA. @Observable + actors + AsyncSequence. Sem reorganização
  cosmética de pastas separada de feature.
- 2026-07-12 · AtlasDesignSystem vira target SPM só quando o macOS nascer.
- 2026-07-13 · `stdout`/`stdout_chunk` é evidência de execução, nunca conteúdo
  visível da resposta. Hermes mobile solicita ACP estruturado; one-shot existe
  apenas como fallback do servidor. Qualquer frame explícito de Reasoning é
  ocultado por defesa em profundidade.
- 2026-07-13 · A vertical atual declara device family iPhone (`1`). Suporte a
  iPad só entra com layouts, rotações, multitarefa e prova próprios; anunciar
  iPad agora gerava warning físico e uma promessa de experiência não validada.

- **2026-07-16 · Canon do operador — roadmap do próximo patamar:**
  **Voice Supremacy REMOVIDA do roadmap** (futuro distante; o veto do §4 a
  microfone/LiveKit/affordance de voz vale para TODAS as obras até decisão
  nova). Lista aprovada para estruturação em `docs/roadmap-proximo-patamar.md`
  (P1–P10): Presença Ambiental (v1 "Proposta das 21h"), Self-Construction na
  casca (**prioridade máxima do operador**), Artifacts & Proof completo,
  Continuity total, Atlas-wide, H1 blame semântico, H9 futuro fantasma, Anel
  Nativo N1–N8, Memória de critério do operador, Contratos por geração.
  **Agent Cockpit aprovado como POSTURA PADRÃO adaptativa do app** (decisão
  do operador 2026-07-16): com nada vivo, a home permanece editorial
  intenção-primeiro; com qualquer sessão viva, a home se reorganiza em
  cockpit ("VIVO AGORA" no topo via seams do TurnPresence — postura v1 sem
  contrato novo). Regência completa (pausar/redirecionar agente em run vivo)
  exige contrato de steering do servidor e fica sequenciada à parte.
  Autônomos permanece superfície 24/7 própria (aviso canônico do §4 intacto).
  Pré-requisito de tudo: plano SOTA 10/10 (`docs/plano-sota-10-de-10.md`)
  concluído com provas.

- **2026-07-16 · Corte de foco (operador — a lição do RN/desktop não se
  repete):** ZERO telas novas nesta era; profundidade sobre superfície. Das
  P1–P10, avançam AGORA somente 5 verticais — Cockpit postura v1, Proposta
  das 21h, Self-Construction na casca (prioridade máxima), Artifacts & Proof
  restrito às superfícies existentes (sem galeria/rota), H1 biografia do
  arquivo — spec executável em `docs/spec-proximo-patamar.md`. Condicionadas:
  regência (aguarda contrato de steering), Continuity fatia mínima (App
  Intents + APNs; Share Extension/StandBy cortados), P10 em janela de
  manutenção. CONGELADAS: Atlas-wide, H9, Anel Nativo N1–N7 (N8 vive no
  SOTA), Memória de critério. Única tela nova autorizada: superfície de
  medição dos motores ("Rivals") — aguardando decisão de nome (vocabulário
  proibido em código pela regra Criação≠Medição) e escopo do operador.

- **2026-07-17 · Canon refinado (operador) — profundidade absoluta, zero
  superfícies novas de QUALQUER tipo:** removidos EM DEFINITIVO do plano (não
  são congelados; só voltam por decisão nova e explícita): **Voz** (inclusive
  App Intents/Siri), **iPad**, **Widget de Home**, **Atlas-wide** (N domínios
  = N telas). A única superfície nova autorizada do app é a de medição dos
  motores ("Rivals" — nome no código e escopo pendentes do operador; propósito
  declarado: acompanhar como os motores pontuam nas suites, por exceção).
  Todo o investimento vai para PROFUNDIDADE das telas existentes — plano
  canônico das 77 melhorias em `docs/plano-profundidade-total.md` (M63/M67/
  M73/M74/M75 removidos por este canon). Sheets/seções dentro das telas
  atuais não são telas — são profundidade da tela dona. Live Activity/
  Dynamic Island/notificações permanecem (presença já shipada).

- **2026-07-17 · Canon v2 (operador) — fora do app LIBERADO; dentro,
  profundidade absoluta:** a regra "zero superfícies novas" vale para DENTRO
  do app (6 rotas existentes + Rivals, nada mais). **FORA do app, tudo
  liberado e incentivado**: widgets de Home, lock screen accessories, Live
  Activity interativa com botões, todas as variações da Dynamic Island,
  StandBy, Controls, notificações ricas. **Voz segue fora EM DEFINITIVO** —
  App Intents permitidos SOMENTE como encanamento mecânico de botões, nunca
  como interface de voz. Tese-alvo declarada: o app supremo de programação
  agêntica de altíssimo nível — a elite vê, audita, entende e rege os
  agentes de qualquer superfície do iPhone. Frentes nomeadas: Dynamic
  Island/lock screen, home, Atlas Code, qualidade agêntica (AX), Autônomos.
  Plano canônico: `docs/plano-profundidade-total.md` (112 melhorias; Ondas
  11–14 = Patamar Supremo; M67 restaurado como M83/M84; M63/M73/M74/M75
  seguem removidos).

- **2026-07-17 · Escopo da tela de medição DECIDIDO (operador):** a única
  tela nova do app mostra **TODAS as métricas e resultados** das medições
  dos motores — suites externas, score por motor, série por rodada, casos
  ✓/✗ (contagens), e o braço comparativo com Atlas × sem Atlas (o
  multiplicador N×M medido, em destaque). Regressão é a exceção que acende.
  Allowlist absoluta (nunca prompt/caso/log/stdout). Spec completa no M61 de
  `docs/plano-profundidade-total.md`. **Pendente somente o NOME no código**
  (regra Criação≠Medição proíbe "Rivals"/"benchmark" no código da Criação;
  recomendação registrada: `AtlasArena*`, rota `.arena` — aguarda a palavra
  do operador).

- **2026-07-17 · Escopo da medição AMPLIADO AO PLENO (operador, v2):** a
  tela é o COCKPIT completo — (1) o índice CONSOLIDADO das ~10 suites com
  pesos públicos e cobertura dita ("o maior e mais completo"), (2) medições
  rodando AGORA com o braço visível (baseline × com Atlas), (3) ação de
  RODAR medição pela liturgia governada (ator+motivo, recibo `enqueued`,
  execução provada só pelo runs/live), (4) perfil de CAPACIDADES/habilidades
  (mapeamento público suíte→capacidade), (5) todas as métricas com gráficos
  (Swift Charts — framework Apple, zero dependência externa). 5 contratos
  `atlas.arena.*.v1` especificados no M61; o que faltar no servidor
  (composto, capacidades, live, start) é parte do item. Segue pendente
  apenas o NOME no código.

- **2026-07-17 · Defaults de §B:** M27/M41/M53/M60 permanecem SKIP. **M82
  parcial:** autorizado commitar `docs/plano-elite-agentica-24x7.md` + design
  elite; demais `docs/plano-*`/`roadmap-*`/`spec-*` seguem untracked até nova
  decisão.

## 7. Registro de entregas (append-only; prova obrigatória)

> Formato: `AAAA-MM-DD · <agente> · <commit> · <o quê> · prova: <checks/print/live-probe>`

- 2026-07-17 · Grok 4.5 · **polish(ui) — Arena/Code honest empty+silence** · este commit · `AtlasArenaView`: composite nil após falha → `AtlasFailureCopy`+retry (rede); 404/domínio ausente → `ArenaModel.domainUnavailableCopy` («medição ainda não publicada pelo servidor»); sem composite nunca renderiza índice/scores. `ArenaModel.loadFailureKind` + `isDomainUnavailable`. `AtlasCodeRadarStatusCapsule`: `.clean`/`.unknown` → caption silenciosa («código» / headline); alarme só `.violating`. Hub: badge exception-only (comentário silêncio). Zero Route. Prova: diff casca; `wc -l` ArenaView 188 RadarSections 270; Swift toolchain ausente neste cloud Linux — re-rodar `AtlasCoreChecks` + `make build` no Mac; device-pending.

- 2026-07-17 · Grok 4.5 · **polish(core) — peel Attachments + AutonomosLedger + ArenaClient** · este commit · `ConversationModel.swift` 647→501; extrai `ConversationModel+Attachments.swift` (156) — addImage/File/Clipboard/remove/capacity + finishPending; state module-visible. `AtlasAutonomos.swift` 436→321; extrai `AtlasAutonomosLedger.swift` (116) — Delivered/Backlog/Finding/WorkOrder/Inbox/Budgets. `AtlasArena.swift` 369→245 DTOs; extrai `AtlasClient+Arena.swift` (127) — StartSuites/Input/Receipt + client get/start. Zero mudança de API pública. §4 E-B ledger. Prova: `wc -l` Model 501 Attachments 156 Autonomos 321 Ledger 116 Arena 245 Client+Arena 127; Swift toolchain ausente neste cloud Linux — re-rodar `swift run AtlasCoreChecks` + `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **polish(core) — peel RichInputTypes + AtlasAutonomosTransfer** · `400a984`+`7e45480` · `RichInputContract.swift` 551→253; extrai `RichInputTypes.swift` (306) — limits/kind/payload/chunk DTOs/FNV/detected shapes/manifest source; Contract fica detectors+builders. `AtlasAutonomosControl.swift` 362→200; extrai `AtlasAutonomosTransfer.swift` (163) — transfer/handoff + cycle revert. Zero mudança de API pública (mesmo módulo). §4 E-B ledger. Prova: `wc -l` Contract 253 Types 306 Control 200 Transfer 163; Swift toolchain ausente neste cloud Linux — re-rodar `swift run AtlasCoreChecks` + `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **polish(ui) — SearchView A11y/recentes + WorkspaceView empty/offline** · este commit · `SearchView`: A11yID `search-*`; query vazia → recentes + caption `RECENTES`; empty sem recentes honesto; Reduce Motion nas animações de lista; Dynamic Type já via AtlasFont/`relativeTo` + system text styles. `WorkspaceView` + peel `WorkspaceEmptyStates`: empty editorial engrossado; `session.phase == .failed` + threads vazias → `AtlasFailureCopy` + retry (não confunde com vazio); loading shell; A11yID `workspace-*`; Reduce Motion no filtro de área. Evidence stub `docs/evidence/2026-07-17-elite-24x7/` (commit count + BLOCKED server/swift/device). Prova: diff casca+docs; `wc -l` View≤200 + EmptyStates; Swift toolchain ausente neste cloud Linux — re-rodar `AtlasCoreChecks` + `make build` no Mac; device-pending.

- 2026-07-17 · Grok 4.5 · **polish(ui) — CICLO C deepen fleet silence + conversation failureKind** · este commit · `AutonomosFleetSection`: sem incidente → caption «frota» (com incidente «FROTA · ATENÇÃO»). `AutonomosTaskHealthSection`: saudável = one-liner quieto («estável · N servíveis · M leases»); métricas+INCIDENTE só com `incidents.present`. `NightlyProposalCard`: dismiss já silêncio (`pendingProposal=nil`); Reduce Motion em BreathingDiamond/PrimaryButton/PressableScale + hint a11y. `ConversationModel.loadFailureKind` + `ConversationLoadFailure` (empty+erro distingue kind via `AtlasFailureCopy`, partilhado com home). Zero Route. Prova: diff casca+model; `rg Aprovar App/Atlas`=0; Swift toolchain ausente neste cloud Linux — re-rodar `AtlasCoreChecks` + `make build` no Mac; device-pending.

- 2026-07-17 · Grok 4.5 · **polish(core) — peel InteractionRun+Polling** · este commit · `InteractionRun.swift` 461→351; extrai `InteractionRun+Polling.swift` (116) — createOrRecover/poll/projectedExecution/updateActiveJobs/cancelActiveJobs/status helpers + `AtlasClient: AtlasInteractionTransport`; members de transporte/poll module-visible só para a extension; zero mudança de API pública. **Decisão:** peel Polling (não AgentActivity 364 nem Arena 369 — ambos já <400; Arena DTOs+client ainda monólito aceitável). Prova: `wc -l` 461→351+116; Swift toolchain ausente neste cloud Linux — re-rodar `swift run AtlasCoreChecks` + `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **polish(ui) — peel RootHomeSections + AtlasCodeGraphChrome + LiveTimeline+Filters** · este commit · CICLO B anti-inchaço: `RootView.swift` 436→219 (Route/nav/topBar/inputBar); extrai `RootHomeSections.swift` (232) — idle/fail/loaded + chips CONVERSAS/OPERAÇÃO/WORKSPACES. `AtlasCodeView+Graph.swift` 399→191 (lista+pílula); extrai `AtlasCodeGraphChrome.swift` (215) — status/worktrees/chips/semana + `AtlasCodeGraphStateFilter`. `LiveTimeline.swift` 289→235; extrai `LiveTimeline+Filters.swift` (62) — chips + `TimelineReadFilter`. Zero Route nova; comportamento idêntico. §4 E-B atualizado. Prova: `wc -l` RootView 219 Home 232 Graph 191 Chrome 215 Timeline 235 Filters 62; Swift toolchain ausente neste cloud Linux — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **polish(ui) — peel ChangeReview Diff/Council + ArenaSuiteSheet** · este commit · `ChangeReviewSections.swift` 448→225; extrai `ChangeReviewDiffSection.swift` (123) — PatchCard/FileRow/DiffView; `ChangeReviewCouncilSection.swift` (111) — Governance/Conselho C18–C21; `ArenaSuitesSection.swift` 234→120; extrai `ArenaSuiteSheet.swift` (125) — Suite+Engine sheets; SuiteSparkline módulo-interno; zero Route; comportamento idêntico. §4 E-B: ChangeReviewSections sai da lista >400. Prova: `wc -l` Sections 225 Diff 123 Council 111 Suites 120 Sheet 125; Swift toolchain ausente neste cloud Linux — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **docs(obra) — E-B compression ledger + E-C start** · este commit · §4: E-B ledger com SHAs + `wc -l` HEAD (View~262 Autonomos~297 Model~642 Chrome~181 Client~473); PARCIAL enquanto view >400 sem ADR (RootView/ChangeReviewSections/…). E-A5 evidence pin `e0bce46` (arena deep link + lock queue capsule). E-C → **IN_PROGRESS** (`dc787be` humano-fora-do-fluxo Autonomos). Plano CICLO B: B1.1/B1.2 peels `[x]`; B1.4 PARCIAL. Prova: diff `OBRA.md` + `docs/plano-elite-agentica-24x7.md`; `wc -l` nos monólitos.

- 2026-07-17 · Grok 4.5 · **polish(ui) — peel ComposerToolbar + ConversationMessages** · `ae0c8e7` · `ConversationComposer.swift` 277→196; extrai `ComposerToolbar.swift` (132) — paperclip/campo/enviar/menu modo·esforço·workspace + `AttachmentStrip` (DraftStrip+upload%); `ConversationView.swift` 370→262; extrai `ConversationMessages.swift` (138) — scroll/FAB/empty/revisão; zero Route; comportamento idêntico. §4 E-B atualizado. Prova: `wc -l` Composer 196 View 262 Toolbar 132 Messages 138; Swift toolchain ausente neste cloud Linux — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **Elite contínuo — peels B + Island/Continuity C** · `0217603`…`0b59697` · Sem parar: Client 473→305; AgentActivity split; Model+Send; Sheets/AreaDetail; Widgets LockScreen+Views; Provenance/Nightly/Autonomos peels; Island ATT/EXT/FAIL/REC/PLN; Continuity/PlanCard honesty (`2df3195`). §4 E-A5/E-B/E-C. **BLOCKED:** Swift / atlas-server / passcode. Prova: `wc -l` + diffs; gates no Mac.

- 2026-07-17 · Grok 4.5 · **CICLO B — peel TurnPresence → +LiveActivity** · `91f2bb3` · `TurnPresence.swift` 370→249; extrai `TurnPresence+LiveActivity.swift` (132) — contentState/clock + start/update/finish/broadcastCount ActivityKit; Entry/activeCount module-visible para a extension; zero mudança de comportamento. PlanCard 227≤250 (+Revisions 101) — sem peel extra. §4 E-B atualizado. Prova: `wc -l` 370→249+132; PlanCard 227; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **CICLO B — peel ArtifactSheet → ArtifactViewer** · `4303a27` · `ArtifactSheet.swift` 316→184; extrai `ArtifactViewer.swift` (158) — kind/byte labels, ArtifactFileFicha, ArtifactPreviewContent, ZoomableArtifactImage (pinch/drag/double-tap/a11y zoom); zero Route; comportamento idêntico. §4 E-B atualizado. Prova: `wc -l` 316→184+158; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **polish(ui) — humano-fora-do-fluxo copy honesty Autonomos** · `dc787be` · CICLO C deepen: `AutonomosAreaSection` — delivered>0 self-construction = silêncio/sucesso + só veto; delivered_total=0 = vazio honesto («ainda não mergeado · aguardando ledger», sem «melhorou» falso). `SelfConstructionReceiptSheet` — sem portão; copy veto/silêncio. `AutonomosDigestSection` — headlines silêncio/sem portão quando delivered>0. `AtlasCodeHealReceiptSheet` — comentário sem string «Aprovar». Prova: `rg Aprovar App/Atlas` = 0 matches; diff casca; Swift toolchain ausente neste cloud Linux — re-rodar `AtlasCoreChecks` + `make build` no Mac; device-pending.

- 2026-07-17 · Grok 4.5 · **polish(ui) — honest ExecutionStateCard action/detail fidelity** · `5ed2c16` · Cenas 01/03/04/13: pills só de `state.actions`; failed Retomar só com `retryableJobId` real e actions vazias; recovering mostra `detail` + `timer.elapsed` (sem retry_count no v1); `checkpoint`/kind badge; Reduce Motion sem scale decorativo. PlanCard «comparar versões» aprofunda `planRevisions` (arquivado/reason/archived_at/iteration/steps + diff saíram/entraram) em `PlanCard+Revisions`. Prova: diff casca; Swift toolchain ausente neste cloud Linux — re-rodar `AtlasCoreChecks` + `make build` no Mac; device-pending.

- 2026-07-17 · Grok 4.5 · **polish(core) — split AtlasClient domain extensions** · `a34fdcc` · `AtlasClient.swift` 658→473 (core networking + SSE + steer); extrai `AtlasClient+AI.swift` (60) · `AtlasClient+Code.swift` (98) · `AtlasClient+LiveActivity.swift` (39). Arena/Autônomos já vivem em `AtlasArena`/`AtlasAutonomos`. Zero mudança de API pública. Prova: `wc -l` 658→473+60+98+39; Swift toolchain ausente neste cloud — re-rodar `swift run AtlasCoreChecks` + `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **CICLO B — peel ConversationView composer** · `f15db79` · `ConversationView.swift` 611→370; extrai `ConversationComposer.swift` (277) — bar/input/strip/fila/execução viva/trailing + sheets modifier; FocusState/steer/review bindings do shell; zero Route; comportamento idêntico. §4 E-B atualizado. Prova: `wc -l` 611→370+277; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **Elite A5 — `atlas://arena` + lock queue capsule** · `e0bce46` · `AtlasDeepLink.arena` parse `atlas://arena` → `Route.arena`; goldens em `AtlasDeepLinkChecks`; `RootView.onOpenURL` reset+append `.arena`. `LockScreenView`: `queueLabel` (`fila N`) cápsula gold distinta no HStack do título (peso/borda/opacidade elevados; não só mono). WidgetURL da entrada Arena na home fica opcional (W-A* depois). §4 E-A5 note. Prova: diff Core+RootView+Widgets+checks; Swift toolchain ausente neste cloud Linux — re-rodar `AtlasCoreChecks` + `make build` no Mac; device-pending.

- 2026-07-17 · Grok 4.5 · **docs(obra) — close U7 search + U4 offline distinction** · este commit · §4 U7 **IN_PROGRESS→DONE (falta print)**: `App/Atlas/SearchView.swift` filtra threads reais e navega; home abre `.search`. §4 U4 **IN_PROGRESS→DONE (falta print)**: `RootView` já liga `session.failureKind` em copy distinta offline×timeout×etc (contrato §5 `da9399a`). Sem DEVICE_PROVEN — print ainda device-pending. Prova: leitura de `SearchView.swift` + `RootView.failureHeadline`/`failureHint`; sem runtime neste cloud.

- 2026-07-17 · Grok 4.5 · **CICLO B — peel Autonomos area/controls from shell** · `a4ad96e` · `AutonomosView.swift` 565→297; extrai `AutonomosAreaSection` (277) — picker/detail/placement/delivered/controls; `AutonomosAwaitingSection` (100) — aguardando você + nightly/rhythm blocks + detail chips; zero Route; comportamento idêntico. §4 E-B atualizado. Prova: `wc -l` before/after; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **CICLO B — peel ConversationChrome + ExecutionStateCard** · `fca0629` · `ConversationChrome.swift` 520→181 (sheets); extrai `EditorialTurn.swift` (226) + `DraftStrip.swift` (121); `ExecutionStateCard.swift` 346→114; extrai `ExecutionStateCard+Actions.swift` (34) + `ExecutionProof.swift` (207); zero Route; comportamento idêntico. §4 E-B atualizado. Prova: `wc -l` before/after; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **polish(core) — split AtlasAutonomos DTO modules** · este commit · `AtlasAutonomos.swift` 1010→436 (areas/live/cycles/backlog/delivered + `AtlasClient` extension + `AtlasAutonomosClientError`); extrai `AtlasAutonomosFleet.swift` (105) · `AtlasAutonomosControl.swift` (362) · `AtlasAutonomosDigest.swift` (117). 59 `public struct|enum` preservados; zero mudança de API. Checks: `import AtlasCore` (mesmo módulo). Prova: `wc -l` 1010→436+105+362+117 (=1020 c/ headers); Swift toolchain ausente neste cloud — re-rodar `swift run AtlasCoreChecks` + `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **CICLO B — split AtlasCodeRadarView sections** · este commit · `AtlasCodeRadarView.swift` 470→66; extrai `AtlasCodeRadarSections.swift` (267) — status capsule / loaded content / RepoRow / FolderRow; `AtlasCodeWorkspaceModel.swift` (164) — model+ISO; zero Route; comportamento idêntico. §4 E-B atualizado. Prova: `wc -l` before/after; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **CICLO B — split ChangeReviewView sections** · este commit · `ChangeReviewView.swift` 453→95; extrai `ChangeReviewSections.swift` (448) — governance/run header/patch/file/diff/controls/tests/findings/decided/actions/toast; zero Route; comportamento idêntico. §4 E-B atualizado. Prova: `wc -l` before/after; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **CICLO B — peel conversation sheets from ConversationView** · este commit · `ConversationView.swift` 795→611; extrai `ConversationSheets.swift` (287) — outline + composer sheets modifier (mode/review/artifact/steer/queue/attachments/workspace/camera/file) + handoff/selo/marker; callbacks e A11yIDs intactos; zero Route. §4 E-B atualizado. Prova: `wc -l` before/after; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **CICLO B — extract RootChrome from RootView** · este commit · `RootView.swift` 592→433; extrai `RootChrome.swift` (BreathingGlyph, CircleButton, WorkspaceRow, ThreadRow, `sectionLabel`; OperationRow ausente); Route + navegação ficam em RootView; zero mudança de comportamento. §4 E-B atualizado. Prova: `wc -l` before/after; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **Elite A4.1 Session Hub deepen** · `a702926` · `LiveNowSection` hub 2+: header `× N`, divisores, cada row title + phaseTitle + timing (`em execução`/`pausado`/`concluído`) + elapsed; split `LiveNowRow.swift` (anti-inchaço); `onOpen` + Reduce Motion + `atlasCard`; zero Route. `LockScreenView` elevou `queueLabel` ao título (refinado no commit arena). Prova: diff casca/widget; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac; device-pending multi-session.

- 2026-07-17 · Grok 4.5 · **CICLO B — peel ConversationModel queue/execution** · este commit · `ConversationModel.swift` 885→642; extrai `ConversationModel+Queue` (106) + `ConversationModel+Execution` (152); API pública das views intacta (`queue`/`promote`/`removeQueued`/`currentExecutionPresence`/`resolveExecutionChoice`/`retryTurn`); members de store/scope/activeRun/sendTurn/update/draft helpers internos ao módulo para as extensions. §4 E-B atualizado. Prova: `wc -l`; Swift toolchain ausente neste cloud — re-rodar `AtlasCoreChecks` + `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **CICLO B — peel queue sheet from ConversationView** · este commit · `ConversationView.swift` 823→795; extrai `QueuedFollowUpsSheet` (39) — promote/remove da fila C11; composer NÃO extraído (acoplado a `@State`/sheets locais); zero Route; `App/project.yml` path Atlas (glob). Prova: `wc -l` before/after; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **Elite A5 lock accessories** · `08f0dda` · Circular/rectangular/inline: atenção (timing.paused / copy), incidente frota, timer elapsed, silêncio honesto. Prova: diff Widgets; device-pending.

- 2026-07-17 · Grok 4.5 · **CICLO B — split AutonomosView** · `d1b3e0f` · `AutonomosView.swift` 1153→565; extrai `AutonomosFleetSection` (181), `AutonomosDigestSection` (151), `AutonomosChrome` (98), `AutonomosSheets` (253); folder glob `App/project.yml` path Atlas; sem mudança de copy/lógica. Prova: `wc -l` before/after; Swift toolchain ausente neste cloud — re-rodar `make build` no Mac.

- 2026-07-17 · Grok 4.5 · **Elite A4.5 fidelity matrix baseline** · este commit · `docs/fable-5-fidelity-matrix.md` mapeia cenas 01–08/10–13 + Fleet + Island → Core/model → SwiftUI → prova → gap; Voice/09 EXCLUDED; Session Hub=`LiveNowSection` deepen; Arena=rota `.arena` separada; A4.5 checkboxes ✓ em `plano-elite-agentica-24x7.md`. Prova: docs + blackboard; sem runtime.

- 2026-07-17 · Grok 4.5 · **Elite E-A1 claim + A1 leaf tasks** · este commit · `docs/plano-elite-agentica-24x7.md` Onda A1 expandida em leafs bite-sized (A1.1a–d M01, A1.2a–d Arena A12, A1.3a–c deep links, A1.4 closeout) com paths exatos, checkboxes, gates e commit messages. §4 E-A1 → **IN_PROGRESS** (Grok 4.5). §5 M01 + M61/A12: **BLOCKED(server)** honesto — `atlas-server` ausente neste workspace; native-only segue (A1.3 handlers). Sem mudança de runtime. Prova: docs + blackboard.

- 2026-07-17 · Grok 4.5 · **Elite A1.3 + M84 — deep links + Semana widget** · este commit · `AtlasDeepLink` (Core) + goldens; `RootView.onOpenURL` trata `atlas://autonomos`, bare `atlas://execution` (última live com threadId ou home), `atlas://code`→radar, code/repo, execution/trace. Widget **Atlas · Semana do Código** lê `snapshot.week` (commits/heals/prevented) → `atlas://code`. **BLOCKED:** `atlas-server` ausente neste cloud → M01/A12 server leafs; toolchain Swift ausente (Linux) → CoreChecks/`make build` não rodados aqui — re-rodar no Mac. Casca Autônomos/Arena já fail-closed (`deliveredTotal>0`, `worker_implemented=false` copy). Prova: diff + goldens no repo; device-pending.

- 2026-07-17 · Grok 4.5 · **Elite 24×7 — plano mestre + canon** · este commit · Design `docs/superpowers/specs/2026-07-17-elite-agentica-24x7-design.md` + plano `docs/plano-elite-agentica-24x7.md` (ciclos A implementar → B comprimir → C aprofundar → D comprimir; zero Route nova; fora-do-app livre ≈130 variantes; humano fora do fluxo ops). OBRA §0/§4 Elite E0–E-D / §6 decisão / §B M82 parcial. Inventário via 5 subagentes (rotas, doutrina, gaps, fora-do-app, saúde de código). **Próximo:** E-A1 (M01, Arena worker, deep links). Prova: docs + blackboard; sem mudança de runtime neste commit.

- 2026-07-17 · Grok 4.5 · **Profundidade Total — fechamento de sessão PARCIAL honesto** · este commit · Missão avançou na Ordem Mestra com provas por frente (não 155/155 absolutos). **Entregue com gate:** Onda 0 parcial (M06 live integral; M01 último passo+§5; M02–M05 roteiro operador); M07–M09 server+Core+casca; M55/M56/M78/M80/M81; casca sprint M11/M15/M62; M61 Arena A1–A12 (rota `.arena` única nova; enqueue real; worker drain §5); M118 SD-1 + M83/M85/M121/M86; M13 sessions/live; batches AX/Autônomos/conversa/runtime/craft/workspace + robustez (M10/M14/M16–M22/M24–M26/M43–M52/M64/M66/M87/M94–M96/M99/M102/M105*/M113–M114/M125/M132/M137/M139/M141–M149/M153–M154/M157–M159…). **Onda 9 intocada.** **Route cases:** 9 no enum (8 + `.arena`). **Gates finais sessão:** `env -u ATLAS_LIVE swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0; `git diff --check` limpo; ambos repos `main`. **Follow-ups §5 (dono):** M01 heal→merge bridge; M02–M05/M03/M04 operador+device/APNs; M61 worker medição; M12 instances; M65/M89 intents; contratos §5 M35/M49/M98/M100/M106+/M126/M134/M140/M160; M28–M34 após M03; M36–M38 triagem; M90–M93/M122 após M04. KPI device (ilha 0 taps / 0 hitches) = pendência operador com roteiros em evidence.

- 2026-07-17 · GPT-5.5 · **Profundidade Total priority batch PARCIAL** · este commit · DONE M43 (NWPathMonitor arma reconnect 1× quando path volta e a home estava em failed), M44 (timeout adaptativo caro/restrito no Core), M45 (503+Retry-After vira `maintenance` + copy própria), M46 (timer de Live Activity clampa clock futuro), M47 (rhythm carrega `v>=1` tolerante), M50 (ATLAS_TOKEN migra/resolve via Keychain), M51 (texto de lock notification truncado), M87/M25 (ContentState aditivo progress N/M + fila, widgets só renderizam quando existe), M96 (PlanCard terminal mostra auditoria planejado/executado em modo Auditoria), M102 (chips de filtro na timeline), M105 parcial (chips por estado real no grafo; agente em §5), M132 (worktrees visíveis no grafo), M137 (aging do backlog quando `created_at` existe), M142 (editar e reenviar própria mensagem como novo rascunho/turno), M147 (⌘↩ enviar, ⌘K busca, ⌘N nova conversa), M154 (monospacedDigit nos números tocados), M157 (`docs/motion-haptics-map.md`), M159 (filet de cor por workspace no ThreadRow), M14 (recibo visual de handoff), M22 (merge_hash abre grafo do repo quando há repo real). DEFERIDO/§5 M49/M89/M35/M36/M37/M38/M40/M98/M100/M106/M107/M109/M112/M116/M126/M134/M140/M160; M156 não alterado sem prova visual/device. ZERO nova Route; `.arena` preservada; Onda 9 e §B SKIP não tocados. Prova: `env -u ATLAS_LIVE swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0; `git diff --check` exit 0.
- 2026-07-17 · GPT-5.5 · **AX/Autônomos/conversa depth batch PARCIAL** · este commit · DONE M94 (LiveTimeline calcula deltas por `occurred_at` e marca p90), M95 (lanes por agentes quando há 2+ jobs reais), M99 (REPLAY em ExecutionProof com Slider ou Stepper em Reduce Motion, indisponível sem timestamps), M113 (fleetHistory em timeline editorial), M114 (sheets para workOrders/inbox/budgets/findings com campos públicos), M139 (`AGUARDANDO VOCÊ` só com decisões >0), M125 (Modo Auditoria persistente por long-press no masthead e densificação de campos existentes), M141 (draft persistente por thread/model com migração local→thread), M145 (outline de turnos em sheet), M146 (marcador novo desde última visita), M148 (watchdog de silêncio >90s), M149 (banner de reconnect vindo do InteractionRun), M153 (`numericText` em timers/contadores tocados), M158 (chips de filtro de workspace em conversas da home). ZERO nova Route nesta entrega; `.arena` já era frente anterior. DEFERIDO opcionais M96/M102/M105/M132/M137/M142/M147. Prova: `env -u ATLAS_LIVE swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0; `git diff --check` exit 0.
- 2026-07-17 · GPT-5.5 · **M118 SD-1 + primeiras superfícies externas** · este commit · App Group `group.com.vitor.atlas.native` no app/widgets; contrato `atlas.native.snapshot.v1` em AtlasCore com writer atômico para `snapshot/atlas.native.snapshot.v1.json`; writes em finalização de turno/fila, refresh Autônomos, refresh Código e background; widget reader fail-closed; M83 frota Home por exceção (incidente/íntegra/não lida/stale), M85 acessórios lock screen circular/rectangular/inline, M121 widget médio de sessão viva via snapshot, M86 gramática visual parcial da Live Activity usando campos já existentes (`finished`/`paused`/fase). **Deferido honesto:** M87 progresso N/M discreto não foi adicionado porque o ContentState ainda não tem campos separados de progress; botão M121 "Seguir" ficou como CTA/URL do widget, não AppIntent mecânico dedicado. Prova: RED inicial do snapshot check por tipo ausente; depois `env -u ATLAS_LIVE swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0; `git diff --check` exit 0.
- 2026-07-17 · GPT-5.5 · **M13 sessions/live no atlas-native** · este commit · Core DTO/client/rota `GET /ai/sessions/live?installation=` (`atlas.ai.sessions.live.v1`) com checks fail-closed; `AtlasSession` faz polling 30s somente com app ativo; `LiveNowSection` mescla sessões locais do `TurnPresence` com remotas, dedup por `thread_id` e badge `em outra superfície`. Prova: `env -u ATLAS_LIVE swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0; `git diff --check` exit 0.
- 2026-07-17 · GPT-5.5 · **M54/M56/M78/M80/M81 process/docs** · `f22b296` + este commit · M56 `docs/arquitetura.md` com 3 camadas, seams, contratos `atlas.*`, actors, fail-closed e boundary; M54 canto canônico curto (`canto-canonico`, rich input, Código, Autônomos, gates) com ponte para overview; M78 `make verify` honesto no `App/Makefile`; M80 ledger fixo de decisões pendentes do operador com M61 decidido como Arena; M81 regra `device-pending` >7d → §4 vermelho owner operador. Prova: `env -u ATLAS_LIVE swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0; `git diff --check` exit 0; `cd App && make -n verify` mostra CoreChecks → build → `xcodebuild ... test` no simulador `iPhone 17 Pro`.
- 2026-07-17 · GPT-5.5 · **Profundidade Total batch casca/processo** · este commit · DONE M10 (ChangeReviewSheet mostra council provider/model/status/hash e divergência factual), M16 (LiveNow pausa >30min opaca + `há Xh` por `pauseTimestamp`), M17 (haptic soft ao concluir turno seguido em outra tela com app ativo), M19 (`AtlasCodeView` refreshable), M20 (Autônomos mostra `aprendendo seu ritmo · dia N de 4`), M21 (ArtifactSheet imagem com pinch/drag/double-tap/accessibilityZoomAction), M24 (selo read-cache confirma refresh com pulso 0,32s; Reduce Motion troca texto), M26 (rotors VoiceOver Violações/Curados no grafo), M48 (mute local da NightlyProposal por 1/3/7 dias via `AtlasSession`), M52 (`PrivacyInfo.xcprivacy`), M64 (PlanCard compara passos que saíram/entraram quando revisions trazem steps; fallback motivos), M66 (long-press em commit citado abre biografia do arquivo se a proveniência trouxer arquivo). DEFERIDO M65: ver §5. SKIP defaults M27/M41/M53/M60/M82 mantidos em §6. Prova: `env -u ATLAS_LIVE swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0; `git diff --check` exit 0; device físico/screenshot não rodado nesta sessão.

- 2026-07-17 · GPT-5.5 · **M61 Arena A4–A12 PARCIAL honesta** · `b2bffeb`→`1930ed3` + este commit · Core DTO/client/checks `atlas.arena.*.v1`; rota única `.arena`; home OPERAÇÃO; O ÍNDICE com Swift Charts; CAPACIDADES; SUITES/sheets; AGORA + run sheet governado; Live Activity dedicada registrada como gap; XCUITest home→arena→índice→suite→rodar sem motivo bloqueado→recibo; A12 disparou POST real do app. Prova: `env -u ATLAS_LIVE swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0; `git diff --check` exit 0; `AtlasArenaFlowTests.testHomeArenaIndexSuiteRunReceipt` 1 teste/0 falhas (`docs/evidence/2026-07-17-arena/AtlasArenaFlow.log`, `.xcresult`, screenshots). Probe pós-run: `runs/live` schema `atlas.arena.runs_live.v1`, `terminal_bench/mockllm` baseline+with_atlas `queued`; scoreboard/composite 200 com 10 suites. **Honesto:** a rodada do app ficou enfileirada; recibo mostra `worker_implemented=false`; não foi provada atualização final do scoreboard dessa rodada.
- 2026-07-17 · GPT-5.5 · **PT1 casca bindings PARCIAL** · este commit · M07 Redirecionar ligado na execução viva com sheet `current_step|replan`, recibo literal `na fila do próximo checkpoint`/reason; M08 Self-Construction mostra `Desfazer — com recibo` só com merge hash + controle disponível e recibo `na fila · ainda não desfeito`; M09 seção `PRÓXIMO RESUMO` usa somente digest tipado; M15 corrige faixa uma linha e composer/fila real; M11 diffStats já estava no `ExecutingStrip`; M62 Fila N + sheet promover/remover verificados e envio durante execução volta a enfileirar. Prova: `env -u ATLAS_LIVE swift run AtlasCoreChecks` exit 0 (live herdado do shell foi interrompido), `cd App && make build` exit 0, `git diff --check` exit 0. **Honesto:** sem screenshot/device nesta sessão; M10–M14 não foram afirmados como fechados aqui.
- 2026-07-17 · Grok 4.5 · **Onda 0 PARCIAL** · este commit · M06 live-probe integral exit 0 (create→SSE→done, upload 3.2MB, C4); M01 parado no último passo real (`delivered_total=0`, heal≠merge) + §5 bridge; M02–M05 roteiros operador (`passcodeRequired`). Evidence: `docs/evidence/2026-07-17-onda0/`. Gates: checks+build verdes.
- 2026-07-17 · Grok 4.5 · **Profundidade Total — bootstrap** · `0678f64` · autorização §6 + adendo M61 Arena; fila §4 PT0–PT19–22; P16–P20→DONE (§7 P19). Prova: checks+build exit 0; main nos dois repos.

- 2026-07-16 · GPT-5.5 · **V5 H1 Biografia do arquivo — prova (P19)** · este commit · fluxo real hub → radar → grafo → commit → arquivo → biografia sem nova rota; `AtlasCodeFlowTests.testHubToRadarToGraphAndProvenance` abre `AtlasCodeWhySheet` a partir da `FileRow` da folha de proveniência. Probe real `/api/code/why` em `atlas-native`/`App/Atlas/RootView.swift`: schema `atlas.code.why.v1`, `commits_total=24`, `commit_count=20`, `truncated=true`, `null_provenance=20`, `provenance_quotes=0` — ausência preservada, sem inventar ledger. Prova: `docs/evidence/2026-07-16-h1-why/probe-rootview.json`, `probe-summary.json`, `AtlasCodeFlowWhy.log` com `** TEST SUCCEEDED **`, `.xcresult` e screenshots exportados (`01-hub-codigo.png` … `06-biografia-arquivo.png`).

- 2026-07-16 · GPT-5.5 · **V3 Self-Construction PARCIAL honesta (P12–P15)** · server `c651eed7b7`+`5e2485460`; native `e269ea7`+este commit · scanner `AtlasNativeConstitutionScanner` + comando `atlas:native:constitution-scan` com R1 observe/R2–R5 heal, cache no backlog Autônomos existente; área `atlas-native` registrada com `repo_scope` e `native_constitution_policy`; casca mostra header "O ATLAS MELHOROU O PRÓPRIO APP" e `SelfConstructionReceiptSheet` sem botão de veto quando não há undo contract. Prova: PHPUnit servidor 51 testes/659 assertions no pacote V3; probe real scanner `finding_count=319` pós-limpeza; canário temporário R2 `sha1:19fc748292b5ba86400dfaf8800a214d8e4e27e6` apareceu no backlog HTTP; dry-run real retornou `status=enqueued`, `started=false`, `requires_worker=true`; `/live` manteve `lock_held=false`. Gates nativos: `swift run AtlasCoreChecks`, `cd App && make build`, `git diff --check` verdes; `make device` instalou no iPhone mas falhou ao abrir por device bloqueado. Evidência: `docs/evidence/2026-07-16-selfconstruction/`. **Honesto:** sem worker/lease não houve execute, cura, merge nem recibo real no app; bloqueio aberto em §5; nenhuma cura/merge foi simulada.
- 2026-07-16 · Grok 4.5 · **V1 Cockpit postura FECHADA** · `11bb1bb`+`d86cf2c`+test · liveSessions + LiveNowSection; XCUITest AtlasLiveNowTests 1/0 falhas (idle sem seção → live com seção → some ao fim); screenshots `docs/evidence/2026-07-16-cockpit-v1/{01-idle,02-live-session,03-after-done}.png`. Zero rota nova. **Honesto:** prova de 2 sessões simultâneas no simulador fica pendente (teste cobre 1 sessão ponta a ponta); device físico device-pending.

- 2026-07-16 · GPT-5.5 · **V2 Presença Ambiental v1 / Proposta das 21h FECHADA** · `9f7d7ea`+`bc8485d`+`316d82e`+este commit · AtlasDayRhythm local (JSON v1 atômico, cap 14 dias, mediana últimos 7 dias com amostra, cold start honesto), models registram atividade em 2 pontos mínimos, NightlyProposal agenda/direciona notificação local e card em Autônomos abre o sheet governado com motivo pré-preenchido; a prova fixou o card no topo mesmo enquanto Autônomos carrega/falha. Prova: `swift run AtlasCoreChecks` exit 0 (8 checks novos `rhythm_*`), `cd App && make build` exit 0, `git diff --check` limpo, XCUITest `AtlasNightlyProposalTests` 1 teste/0 falhas no iPhone 17 Pro Simulator; screenshots/result em `docs/evidence/2026-07-16-proposta-21h/{01-card-proposta.png,02-sheet-prefilled.png,03-card-dismissed.png,NightlyProposal.xcresult}`. **Honesto:** a prova usa seed DEBUG `-atlas.nightly.demo 1` para a casca; foto da notificação noturna na Lock Screen, aceite com `startRun` real, notificação da manhã e device físico permanecem `device-pending`.

- 2026-07-16 · GPT-5.5 · **V4 Artifacts & Proof FECHADA** · server `99ba5abd3` + native `5396b21` + `d6732ea` + este commit · servidor expõe `GET /ai/interactions/{trace}/artifacts` e `/content` com schema `atlas.trace_artifacts.v1`, razões `no_workspace|no_run|multiple_runs`, allowlist de path, 413 e 404 trace-scoped; Core decodifica fail-closed, kind desconhecido→arquivo, rota `max_bytes` e valida SHA-256; casca carrega manifesto/conteúdo pelo `ChangeReviewModel`, mostra `ARTEFATOS (N)` só com itens reais e abre `ArtifactSheet` sem rota nova. Prova: PHPUnit artifacts 8 testes/43 assertions + regressão C15 7/48; probe HTTP efêmero `manifest_status=200`, `content_status=200`, `sha_match=yes`; `swift run AtlasCoreChecks`, `cd App && make build` e `git diff --check` verdes antes dos commits 09/10; evidência em `docs/evidence/2026-07-16-artifacts/`. **Honesto:** `ATLAS_TOKEN` ausente → live-probe real pulado; XCUITest/screenshot da linha `ARTEFATOS` pendente por falta de token/harness de artefato semeado; device físico `device-pending`.

- 2026-07-16 · Grok 4.5 · **SOTA MISSÃO — registro final (S34)** · Ordem mestra 1–34 entregue na main local. **Saldo Swift** desde `8744eb6^`: ver medição no fechamento (~−700 a −900 líquido após tipagem/splits/F4/F6 — **abaixo do alvo −2.500**; a poda F0 sozinha foi −2.275 e as fases seguintes adicionaram linhas tipadas). **DoD por eixo:** Arquitetura ✓ (Model≤800, TurnStatus/IDs, TurnPayloadBuilder, F6.1); Qualidade ✓ (A11yID, schema, status tipado); Fluidez UI parcial (F2 memo/scroll/lazy/equatable ✓; Instruments 120Hz/launch = §5 pendência operador); Saúde evolutiva parcial (saldo < alvo; views>400 restantes: ConversationView/Chrome/Autonomos/Radar/ChangeReview); Eficiência ✓ (1 decoder/stream, poll O(T+N), Time fast-path, markdown throttle). F5.1/F5.4 DEVICE_PROVEN = pendência operador. Prova gates: checks+build verdes ao longo da missão.
- 2026-07-16 · Grok 4.5 · SOTA S33/F5.3+F5.4 · N8 registrado em OBRA §2; sessão de prints U1–U6/DEVICE_PROVEN permanece pendência do operador (sem device Instruments nesta sessão) · prova: texto em §2/§5
- 2026-07-16 · Grok 4.5 · SOTA S31–S32/F6.1 · ThreadReadCache atômico + selo «visto há»; Model 798 · prova: `4cdeb9f`+`a777d6c`; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S30/F4.5 · TurnPayloadBuilder + golden equivalência · prova: `9339f0c`; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S29/F4.4 · AtlasRoute constantes · prova: `4cea5df`; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S28/F4.2 · `.atlasCard()` · prova: `2f338df`; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S25–S27/F3.4 · DiffStats na ExecutingStrip + PlanRevision «comparar versões» no PlanCard; bolha projeta metadata; Council já na ChangeReviewSheet · prova: checks+build exit 0; screenshot device-pending (trace real com campos)
- 2026-07-16 · Grok 4.5 · SOTA S24/F3.3 · ConversationCockpit → PlanCard/ExecutionStateCard/LiveTimeline · prova: `0c12f96`; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S23/F3.2 · AtlasCodeView fatiado (Provenance/Heal/CommitRow/Palette/Graph) · prova: `c2ddf0c`; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S22/F3.1 · `ChangeReviewModel` extraído; ConversationModel 797 linhas (<800); Continuity/Types auxiliares; sheet usa `model.reviews` · prova: `d99c053`; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S21/F4.1 · `A11yID` compartilhado (casca + AtlasDeviceProof via project.yml); 0 literais accessibilityIdentifier em App/Atlas · prova: checks exit 0; build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S20/F2.9+F2.10 · grafo `LazyVStack`; `EditorialTurn: Equatable` + `.equatable()` (closures não invalidam) · prova: checks exit 0; build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S19/F2.7+F2.8 · markdown streaming memo (throttle ~100ms / fronteira bloco; parse force no finalize) + scroll coalescido (>100ms ou count mudou) · prova: checks exit 0; build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S18/F2.6 · micro-opt Markdown/RichInput/Imaging · prova: `1dd7d5e`; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S17/F2.5 · goldens `item_id` snake_case no snapshot (produção já tipada pós-F2.2; sem fix paralelo no log) · prova: `2677b5a`; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S16/F2.4 · AtlasTime fast-path ISO plain + cache fractional · prova: `64a3863`; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S15/F2.3 · timeline poll incremental (lastProjected + índice por id); check 500 eventos ≤500 projeções · prova: checks exit 0; build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S14/F2.2 · JSONValue via JSONSerialization (sem cascata try?); quirk []→bag vazio preservado · prova: checks exit 0; build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S13/F2.1 · SSE: delimiters static, drain por cursor, dispatch Data bytes, 1 JSONDecoder/delegate; equivalência bytes≡string (TDD) · prova: checks exit 0; build exit 0; live-probe pulado (sem ATLAS_TOKEN)
- 2026-07-16 · Grok 4.5 · SOTA S12/F1.4 + **F1 FECHADA** · `LoadPhase` compartilhado (Autonomos/Code/Workspace/Session); Provenance/Ask mantêm Phase com associated value · prova: checks+build exit 0. F5.1 baseline Instruments → §5 pendência operador
- 2026-07-16 · Grok 4.5 · SOTA S11/F1.3 · `KeyedDecodingContainer.requireSchema` + 9 sites (Week/Violations/Graph×2/Ask/Mirror/Workspace/Heals/ChangeReview) · prova: checks schema desconhecido verdes; checks+build exit 0; −~64 linhas
- 2026-07-16 · Grok 4.5 · SOTA S10/F1.2-views · Route.thread/ConversationView/AtlasCode askThread usam ThreadID; 0 `Id: String` em App/Atlas · prova: rg zero; checks+build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S9/F1.2-models · ConversationModel/ChatBubble/TurnPresence/LiveActivity seams: TraceID/ThreadID/JobID tipados; rawValue só na borda ActivityKit · prova: checks exit 0; build exit 0; 0 Id:String em *Model*.swift
- 2026-07-16 · Grok 4.5 · SOTA S8/F1.2-Core · `AtlasIDs` (Trace/Thread/Job/Patch/Client, Codable single-value) + APIs ChangeReview/getAiInteraction tipadas; casca mínima ajustada p/ gate verde · prova: runAtlasIDChecks; checks exit 0; build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S7/F1.1 · `AtlasTurnStatus` tipado (wire fail-open via `.unknown`); InteractionRun/ConversationModel/Cockpit usam `turnStatus`; literais de lifecycle só no enum; golden: unknown nunca terminal · prova: checks exit 0 (incl. 11 TurnStatus); build exit 0; git diff --check limpo
- 2026-07-16 · Grok 4.5 · SOTA S6/F0.8 + **F0 FECHADA** · DELETE dups byte-idênticos em fable-execucao-viva/ (−3 HTML + index + evolucao antiga); links → fable-5.html; arquiva docs/superpowers + scripts/codex-execution-queue.test.mjs em docs/archive/; .DS_Store já no gitignore · prova: md5 idênticos antes do delete; checks exit 0; build exit 0. Saldo Swift F0 ≈ −2.250+; assets −144K; docs −~300K+
- 2026-07-16 · Grok 4.5 · SOTA S5/F0.7 · DELETE Fraunces Bold+Medium (144K) + cases mortos do switch; Regular permanece como fallback · prova: 28/28 AtlasFont.serif resolvem SemiBold; checks exit 0; build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S4/F0.6 · remove tokens mortos (bgDeep/goldDeep/goldLight/domProgramacao/domAtlas) + botão falso «Adicionar workspace»; prussian mantido · prova: rg 0 usos; checks exit 0; build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S3/F0.4+F0.5 · DELETE Models+Merge (−125) + checks Merge/Codable Capture (−~80) + enum AtlasAiProviders (−9); KEEP AtlasAiSession/Message (estruturais em AtlasAiThread). **Ressalva F0.4:** PoC de sync offline LWW/tombstone nunca ligado — default da spec DELETE (lei sem fundação pra depois); ressuscita do git se sync nascer · prova: re-grep 0 refs produto; checks exit 0; build exit 0
- 2026-07-16 · Grok 4.5 · SOTA S2/F0.3 · poda parcial Decisions/Quality/ThreadsExtra (−456): mantém tipos pinados pelo trace + surface-handoff/feedback; remove APIs admin órfãs · prova: re-grep 0 refs produto; checks exit 0; build exit 0; git diff --check limpo
- 2026-07-16 · Grok 4.5 · SOTA S1/F0.2 · delete `AtlasAiTelemetry/Policies/Providers/Attachments` (−1.577) + cascata `main.swift` (providers/decisions/telemetry/policies/attachments + live-probe providers) · prova: re-grep 0 refs produto; `swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0; `git diff --check` limpo
- 2026-07-12 · Fable 5 (bootstrap da obra) · `63c9a2f` · lifecycle honesto:
  Stop real (SSE + jobs), payload completo (effort/workspace/read), gates sem
  mentira, StrictConcurrency ON · prova: checks verdes + make build honesto
- 2026-07-13 · Fable 5 · `ed10c81`→`5aa6245` · Lane casca (parte independente):
  U1 strip legível + anexo abre card (send sempre alcançável) · U2 slot de envio
  3-estados honesto + haptics · U4 estados editoriais com copy por failureKind ·
  U5 Dynamic Type em toda tipografia + VoiceOver · U6 ícone ✦ Ink & Brass ·
  prova: gates verdes sob Swift 6, instalado no iPhone; DEVICE_PROVEN aguarda
  a sessão de prints do operador (strip+composer+erro+type grande+ícone)
- 2026-07-12 · Fable 5 · `9a95320`→`f900ef1` · Rich Input F1–F5: contrato L1
  (38 checks vs fixture TS), engine L2 (23 checks, resume/retry/sha), transporte
  real (live-probe: 3.2MB reais, sha ✓, resume ✓), AtlasImaging (HEIC→JPEG),
  iOS liga (📎 real → chunks → create) · prova: 195 checks + live-probe verde +
  instalado no iPhone (verificação visual pendente = U1)
- 2026-07-12 · Codex · `ec3ffe6` · C1 completo + primeira fatia C2/C5:
  `InteractionRun` dono único, SSE delegate incremental, reconnect cursor/backoff,
  cancel real, recovery de `-1005` por UUID e feed tipado de atividade do agente
  · prova: 220 checks + live create→SSE content→done + `make build` verde;
  deploy bloqueado apenas por iPhone fora da lista de devices pareados.
- 2026-07-13 · Codex · `d1c78ba` · C2 completo: outbox JSON atômica em
  Application Support, UUID/idempotência preservados, recovery do create e
  retomada automática no relaunch; rede/408/429/5xx ficam, 4xx terminal sai
  · prova: 232 checks + live create→SSE→done drenou outbox + app build verde.
- 2026-07-13 · Codex · `cededd4` · C5 completo: tool events, activity timeline,
  decision receipt e quality evaluation projetados em tipos pequenos no model,
  sem parsing ou chain-of-thought na View · prova: 236 checks + replay real
  decodificou receipt/decision/tool/quality + SSE + app build verde.
- 2026-07-13 · Codex · `da9399a` · C3 + contrato U4: adapters únicos para
  Files/câmera/clipboard e falhas de rede tipadas no AtlasSession · prova:
  242 checks + câmera→engine→upload/payload live real + app build verde.
- 2026-07-13 · Codex · `bb8ecea` + `dfe4cfa` · resposta segura + timeline persistente:
  Hermes one-shot, `stdout_chunk` fora do texto, Reasoning rejeitado, ledger
  REST `stream_events` decodificado e restaurado em batches no reload · prova:
  golden checks verdes + live SSE sem Reasoning + resposta final apresentável +
  snapshot com atividades, chunks repetidos colapsados + `make build` verde.
  U3 visual elevado a bloqueador.
- 2026-07-13 · Codex · `03192bd` · C4: >40k UTF-16 vira prompt compacto +
  único anexo `atlas.long_message.v1` no engine canônico; app se identifica como
  superfície interativa para deferir planners pesados · prova: TDD red→green,
  checks offline, live upload→create e provider devolveu canary presente somente
  no final do Markdown, fora do prompt compacto.
- 2026-07-13 · Codex · `475267f` · C6 incremento: Swift tools/language/app 6.0,
  format style Sendable e runner concorrente seguro · prova: rebuild limpo do
  Core sem warning; App compila em Swift 6, restando um warning visual de
  `RootView.swift:77` encaminhado ao Fable no §5.
- 2026-07-13 · Codex · `ce850fe` · C5/C6 hardening: resource tool atual+legado,
  eventos Codex `tool/thinking`, comando/arquivo/busca sanitizados, tool lifecycle
  com upsert estável, falha honesta, boundary de toda casca e SSE de 120s por
  janela (4 reconnects = até 10 min) · prova: TDD red→green, clean Core sem
  warnings, clean App Swift 6 sem warning próprio, live replay com jornada
  entender→contexto→planejar→executar→verificar→evidência + uploads/C4 verdes.
- 2026-07-13 · Codex · `c952c26` + `4b68d29` · compatibilidade com o ledger
  real `progress|shell`, tool lifecycle persistente e separação honesta entre
  processo do provider e ferramenta do agente (sem argv/path local) · prova:
  checks red→green + replay real Codex com comando/jornada/SSE/done verdes.
- 2026-07-13 · Codex · `8407ca1` · C7 DeviceProof reproduzível: target XCUITest
  assinado, autodiscovery correto e evidence attachments · prova: Simulator
  físico-equivalente verde com Codex real, atividade ao vivo e comando
  persistido; execução no iPhone parou no preflight porque o aparelho estava
  bloqueado, logo C7 permanece IN_PROGRESS.
- 2026-07-13 · Codex · `a08088e` · C7 medição live: probe Codex força comando
  read-only de 8s e exige lifecycle semântico antes da conclusão · prova:
  `shell.started` recebido durante a execução, tool observável por mais de 5s,
  conclusão persistida e reaparecimento no replay; checks Core + App verdes.
- 2026-07-13 · Codex · `30b2023` · C5 atividade atual honesta: ferramenta aberta
  vence reasoning/progress intercalado até seu mesmo item concluir; edit/search
  concluídos deixam de parecer ativos · prova: golden red→green, live Codex
  `shell.started` >5s + replay, XCUITest estrito encontrou `Executando comando`
  ao vivo; App build sem warning. C7 segue RED apenas na visibilidade persistida.
- 2026-07-13 · Codex · `ea6fe2b` · C7 deixou de aceitar falso verde: confirma
  envio tocável + turno criado, exige `Executando comando` AO VIVO e exige
  `Comando concluído` visível/tocável no histórico · prova: Simulator alcançou
  a tool live e falhou exatamente na timeline persistida inacessível de U3.
- 2026-07-13 · Codex · `f356bd4a1` + `d77cf5a` · C8 Hermes/Kimi estruturado:
  ACP entrega thought/tool start/tool completion/token provider-neutral, o
  recorder persiste os tipos reais, Reasoning bruto não vira resposta e o app
  solicita o transporte correto · prova: TDD red→green; 129 testes server/733
  asserts; Core checks + App build; live Hermes ACP com `shell.started` >5s,
  tool persistida e reproduzida no replay.
- 2026-07-13 · Codex · `9af0b72` · C7 agora prova Hermes/Kimi, não apenas
  Codex: envia `sleep 8 && pwd`, exige a tool AO VIVO e a mesma tool persistida
  e alcançável no histórico · prova: XCUITest Simulator verde em 62,5s, zero
  falhas, 3 screenshots; cockpit registrou 9 passos e resposta final limpa.
- 2026-07-13 · Codex · `9af0b72` + `f356bd4a1` · revalidação integral da
  Conversation Supremacy · prova: Core checks e App build exit 0; live real
  create/SSE/replay + Hermes tool >5s + upload 3,2MB/SHA/resume + C4 verdes;
  93 testes server/572 asserts e migration 86 `Ran`; DeviceProof físico não
  iniciou porque o iPhone reportou `passcodeRequired=true`.
- 2026-07-13 · Codex · `9b92a8a` · DeviceProof cobre os dois defeitos originais:
  ferramenta real ao vivo/persistida e resposta final separada, utilizável e sem
  frame bruto de Reasoning · prova: iPhone 17 Pro Max Simulator, iOS 26.5,
  1 teste/0 falhas; Core checks e App build verdes antes do commit.
- 2026-07-13 · Codex · `3b80c72` · C3 performance: ImageIO prepara upload e
  thumbnail ≤256px em task cancelável fora da MainActor; o model limita também
  imagens pendentes e `send()` aguarda toda preparação, sem perder anexo · prova:
  dois ciclos TDD red→green, boundary anti-regressão, Core checks + App build
  Swift 6 verdes e zero warning próprio.
- 2026-07-13 · Codex · `ec369f1` · C3 fileImporter: remove `Data(contentsOf:)`
  da MainActor, prepara `AtlasAttachmentAdapter.file` fora da UI, mantém acesso
  security-scoped em cada leitura chunked e reserva limites para anexos ainda
  pendentes; `send()` aguarda imagens e arquivos · prova: TDD red→green; arquivo
  temporário lido por offset; Core checks + App build verdes; live upload real
  de arquivo 3,2MB com SHA-256 íntegro. A primeira bateria live teve flutuação
  isolada no provider de C4; repetição integral terminou toda verde.
- 2026-07-13 · Codex · `df55878` · C7 preflight físico honesto: resolve o UDID
  pareado, consulta CoreDevice antes do cleanup/Xcode, falha rápido quando há
  passcode e preserva evidências; target alinhado à vertical iPhone elimina o
  warning falso de orientação iPad · prova: dois checks TDD red→green; Core +
  App verdes; build genérico iPhone `warning_count=0`; execução real bloqueada
  terminou `rc=2` em ~2s e manteve sentinelas do result/evidence.
- 2026-07-13 · Codex · `3ec45aa87` (atlas-server) + `c2b8241` + `c955b65`
  (atlas-native) · C8 APNs real: ActivityKit pede token por execução, Core o
  registra/invalida contra o trace, servidor cifra/rota token e projeta o
  ledger público do Terminal para APNs com JWT ES256, debounce e contagem por
  instalação · prova: 3 Feature tests/20 asserts (registro, rotação,
  invalidação e payload APNs redigido), migration local aplicada, rotas
  protegidas confirmadas, `swift run AtlasCoreChecks` + `make build` verdes.
  A prova final em iPhone/Lock Screen remoto aguarda somente credencial APNs
  externa no cofre; não é marcada como entregue antes disso.
- 2026-07-13 · Codex · C8 continuação (push-to-start): uma instalação iOS
  registra o token ActivityKit de início; uma missão cuja origem não é `app`
  pode abrir a presença remota a partir do ledger do Terminal/CLI, e o iOS
  registra de volta o token de update associado ao trace. Não há prompt,
  stdout, comando ou raciocínio no payload. Prova local: Feature test APNs
  start redigido + checks Core + build do app; a prova física ainda depende da
  chave APNs/capability assinada, portanto não confundir com entrega remota.
- 2026-07-13 · Codex · C14 WIP local (sem commit) · fallback automático
  Gemini→Claude passou a substituir o snapshot com `recovering` somente depois
  de reenfileirar, e grava o mesmo estado público no lifecycle; quota/stderr e
  detalhe do provider não entram na projeção móvel · prova: TDD red→green,
  52 testes PHP / 364 asserts, `swift run AtlasCoreChecks` + `make build`
  verdes. Recovery de job stale ainda é fatia pendente.
- 2026-07-13 · Codex · C14 WIP local (sem commit) · recovery stale agora
  projeta o estado público somente depois de mudar o job de verdade: direto
  publica reenfileiramento ou falha terminal; Council publica recuperação ao
  reenfileirar e só publica falha quando seu rollup terminou em falha. Nenhum
  diagnóstico técnico entra no lifecycle · prova: TDD red→green, 55 testes
  PHP / 387 asserts; `swift run AtlasCoreChecks` + `make build` verdes. A
  integração/prova visual Fable 5 no iPhone continua pendente.
- 2026-07-13 · Codex · C14 hardening local (sem commit) · o decoder Swift
  falha fechado para `kind` desconhecido, ação com estilo inválido e título
  acima do limite; nenhum desses payloads pode produzir card ou controle
  inventado na casca · prova: golden checks novos verdes, `swift run
  AtlasCoreChecks` + `make build` verdes e `git diff --check` limpo.
- 2026-07-13 · Codex · C14 hardening local (sem commit) · pausa confirmada não
  é mais tratada como reconnect esgotado: `InteractionRun` confere o snapshot
  do trace, emite `suspended`, remove apenas a outbox já durável e preserva a
  presença pelo mesmo trace. O servidor publica `paused_at` somente nos
  estados pausáveis; Core valida o ISO, falha fechado se for inválido e expõe
  `pauseTimestamp` para congelar o timer após reconnect/relaunch · prova: TDD
  red→green, 6 testes PHP/41 asserts; `swift run AtlasCoreChecks`, `make build`
  e `git diff --check` verdes. A ligação ActivityKit/Widget e a prova física
  ainda pertencem à casca Fable e ao iPhone disponível.
- 2026-07-13 · Codex · C15 WIP local (sem commit) · revisão de mudança agora
  resolve somente o run unívoco cujo `trace_id` é o trace da conversa; zero ou
  dois vínculos falham fechados. Projeção, diff e decisão usam rotas
  trace-scoped e nunca retornam `engineering_run_id`; `accept|reject` persistem
  a ação e um recibo lifecycle no ledger na mesma transação. O Core valida o
  schema `atlas.trace_change_review.v1`, rejeita schema/estado inválido e o
  model só expõe `refreshChangeReview`/`refreshChangeReviewDiff`/
  `applyChangeReview` após conferir o mesmo trace e patch. Prova: TDD
  red→green 5 testes PHP/38 asserts; `swift run AtlasCoreChecks` e `cd App &&
  make build` verdes. A composição visual e a prova no iPhone permanecem com
  Fable 5/dispositivo, portanto C15 não é marcada entregue.
- 2026-07-13 · Codex · C16 WIP local (sem commit) · revisão por arquivo agora
  é estado canônico, não affordance decorativa: a decisão aceita/rejeita apenas
  path presente no patch do run unívoco da trace, persiste por `(patch,file)`
  com `diff_hash`, e grava recibo lifecycle próprio. `accept` global registra o
  aceite de todos os arquivos capturados na mesma transação antes de resolver o
  run. Core recebeu DTO/cliente/model com revalidação trace→patch→file, sem rede
  na View. Prova: TDD vermelho→verde, 7 testes PHP/48 asserts; `swift run
  AtlasCoreChecks` verde. `cd App && make build` não passou por incompatibilidade
  Fable preexistente `RootView freeOnly`/`WorkspaceView`; nenhum device claim.
- 2026-07-13 · Codex · C13 WIP local (sem commit) · transferência AP-790 é
  durável e sem host inventado: o endpoint só aceita um lock fonte vivo; o
  runner entrega no limite de iteração com checkpoint; o job enfileira a mesma
  missão; o sucessor só é recebido após o lock real. `GET transfer/{handoff}`
  lê o recibo em vez de projetar otimismo. Core/model Swift receberam DTOs e
  polling tipados; TDD vermelho→verde: feature HTTP 15 asserts, runner 7,
  job 7; `swift run AtlasCoreChecks` verde. Casca Fable e prova física pendentes.
- 2026-07-13 · Codex · C13 WIP local (sem commit) · placement tipado no Core:
  host, instante e TTL de lease vêm somente do holder do lock; nomes de repo
  vêm somente do escopo canônico da área. Workspace/branch não foram
  inventados. Golden check vermelho→verde + `swift run AtlasCoreChecks` verde.
- 2026-07-14 · Codex · C13 WIP local (sem commit) · saúde global da fila do
  músculo externo: `/agents/task-health` fornece apenas contagens, leases,
  flags e recomendação publicada; Core/model recebem DTO tipado sem task
  packet, objetivo, prompt, path ou instrução executável. Prova: TDD 404→200,
  8 testes PHP/47 asserts no Agent Governance API; golden Swift; `swift run
  AtlasCoreChecks` + `cd App && make build` verdes. Renderização Fable e prova
  no iPhone seguem pendentes.
- 2026-07-14 · Codex · Continuidade WIP local (sem commit) · recibo de handoff
  entre superfícies mantém `thread_id` e `session_id` canônicos e só projeta
  origem/destino/status; provider brief, prompt, metadata e conteúdo não
  atravessam. Servidor: migration aplicada + API TDD 404→200 (2 testes/15
  asserts). Native: DTO, destinos fechados e seam `ConversationModel`, golden
  TDD compilação vermelha→verde; `swift run AtlasCoreChecks` e `make build`
  verdes. Faltam UI Fable, abertura no Desktop/Terminal e prova no iPhone.
- 2026-07-14 · Codex · Continuidade WIP local (sem commit) · o Terminal agora
  reabre uma thread de Mobile quando `--thread` é explícito, sem mudar a
  descoberta automática de threads CLI por workspace. Prova TDD: falhava com
  thread nula; `AtlasCliContinueCommandTest` verde (5 asserts), API surface
  handoff verde (15 asserts). Desktop/UI Fable e prova cruzada física seguem
  pendentes.
- 2026-07-14 · Codex · C14 WIP local (sem commit) · o contrato de presença
  agora persiste `timer.elapsed_active_ms` e marcos tipados de pausa/retomada/
  término no ledger público. O servidor acumula apenas trabalho ativo entre
  pause→resume→pause; Core Swift falha fechado para timer malformado e expõe o
  acumulado à casca. Prova: TDD vermelho→verde no serviço (8 testes/53
  asserts), bateria C14 do Worker/Resolver/controle (57 testes/403 asserts) e
  `swift run AtlasCoreChecks` verde. ActivityKit/Widgets, screenshot e iPhone
  físico ainda dependem da integração Fable e do device; não são declarados
  entregues. Tentativa física em 2026-07-14: `make device` parou antes do
  deploy porque não havia iPhone pareado e conectado; nenhuma evidência de
  device foi fabricada.
- 2026-07-14 · Codex · C14 hardening local (sem commit) · o decoder rejeita
  um timer que contradiga a fase pública: atenção/espera exigem pausa,
  recuperação/replanejamento exigem execução e falha/conclusão exigem relógio
  finalizado. Traces legados sem timer continuam aceitos, mas contratos novos
  inconsistentes não podem fazer App, Lock Screen e Dynamic Island divergir.
  Prova TDD vermelho→verde: golden check novo, `swift run AtlasCoreChecks`,
  `cd App && make build` e `git diff --check` verdes. Prova física continua
  pendente de iPhone pareado/conectado.
- 2026-07-14 · Codex · C13 hardening local (sem commit) · o teste de `/live`
  foi alinhado ao contrato provider-safe: `path` interno de sinais/lease não
  volta na projeção móvel, embora o runner continue a usá-lo internamente.
  A bateria HTTP de áreas, ciclo, backlog, controles e transferência passou
  com 45 testes / 344 asserts; `git diff --check` verde. A renderização Fable
  e a prova no iPhone seguem pendentes.
- 2026-07-14 · Codex · C13 hardening local (sem commit) · `/cycles` deixou de
  devolver recibos internos do ledger. A allow-list pública contém apenas
  marco, resultado, integridade, bloqueios codificados, resultado de merge e
  horário; backlog de plano, referências diagnósticas, workcell e IDs internos
  ficam no ledger/auditoria. `AtlasAutonomosCycle` torna a mesma projeção
  Foundation-only no app. Prova TDD vermelho→verde: 46 testes HTTP / 353
  asserts, `swift run AtlasCoreChecks`, `cd App && make build` e
  `git diff --check` verdes. Fable ainda precisa renderizar esse histórico e
  falta prova no iPhone.
- 2026-07-13 · Codex · C7 hardening local (sem commit) · o preflight não exige
  mais um `tunnelState=connected` já existente: `devicectl` adquiriu o túnel do
  iPhone pareado sob demanda no `lockState`. Os scripts só selecionam iOS
  pareado e deixam a sonda operacional decidir antes de apagar evidência ou
  iniciar Xcode. TDD vermelho→verde no harness, `swift run AtlasCoreChecks`,
  `cd App && make build` e `git diff --check` verdes. `make device-proof`
  chegou ao aparelho e parou corretamente em `passcodeRequired: true`; nenhuma
  evidência física foi fabricada.
- 2026-07-13 · Codex · C13 hardening local (sem commit) · o histórico global
  da frota agora é uma allow-list pública. `/agents/history` mantém `detail`
  arbitrário apenas no ledger de auditoria e envia ao app agente, evento,
  horário, ator/conta codificados, PID/duração e motivo codificado. O
  `AtlasAutonomosFleetHistoryEvent` não possui mais JSON livre. Prova TDD
  vermelho→verde contra prompt, chave e path sintéticos: 55 testes HTTP / 408
  asserts, `swift run AtlasCoreChecks`, `cd App && make build` e
  `git diff --check` verdes. A renderização Fable e a prova no iPhone seguem
  pendentes.
- 2026-07-13 · Codex · C13 hardening local (sem commit) · `/live` não entrega
  mais o agregado inteiro Product Mode ao app. O cockpit agora é
  `atlas.autonomos.cockpit_summary.v1` com apenas `status`; filas, diagnósticos
  e instruções ficam no owner interno até existir contrato público próprio.
  O Core recebeu `AtlasAutonomosCockpitSummary`. Prova TDD vermelho→verde: 27
  testes HTTP / 232 asserts, `swift run AtlasCoreChecks`, `cd App && make build`
  e `git diff --check` verdes. Fable não deve inferir missão, progresso ou
  detalhe do resumo; prova física continua pendente.
- 2026-07-13 · Codex · C13 hardening local (sem commit) · `/areas` reduz
  `repo_scope` a `repos` públicos. `allowed_paths`, `forbidden_paths` e demais
  policy/topologia canônicas não saem do servidor; Core usa
  `AtlasAutonomosRepositoryScope` em vez de `JSONObject`. Prova TDD
  vermelho→verde: 37 testes HTTP / 299 asserts, `swift run AtlasCoreChecks`,
  `cd App && make build` e `git diff --check` verdes. Fable pode exibir apenas
  `area.repositoryNames`; prova física continua pendente.
- 2026-07-13 · Codex · C13 hardening local (sem commit) · `/done` deixou de
  vazar o recorte bruto do ledger: cada entrega comprovada agora usa a mesma
  allow-list de `/cycles`, sem `run_id`, `cycle_id`, `finding_key`, prompt,
  workcell ou payload do worker. Core decodifica `AtlasAutonomosCycle`, não
  JSON livre. Prova TDD vermelho→verde: 46 testes HTTP / 360 asserts,
  `swift run AtlasCoreChecks`, `cd App && make build` e `git diff --check`
  verdes. A renderização Fable e a prova no iPhone permanecem pendentes.
- 2026-07-13 · Codex · C13 hardening local (sem commit) · o recibo de
  `run-control` agora tem contrato fechado no Core: `AtlasAutonomosSignalState`
  contém somente `active`. A API já redigia `path`; dois testes unitários ainda
  exigiam esse dado interno e foram corrigidos para provar o sinal real no
  runner sem recolocá-lo no payload. Prova de regressão: 54 testes HTTP / 414
  asserts, `swift run AtlasCoreChecks`, `cd App && make build` e
  `git diff --check` verdes. Casca Fable e evidência física continuam pendentes.
- 2026-07-15 · Codex · `d0a65d0` + `838585d` + server `b43e907da` · C22/E1 concluído:
  endpoint read-only de topologia Git, contrato versionado no AtlasCore, cliente,
  Canvas M0 e geometria midpoint. Prova: endpoint real 200 em Laravel novo com
  `head`, nós, worktrees e fingerprint; 4 testes PHPUnit / 43 asserts; `swift run
  AtlasCoreChecks`; `cd App && make build`; `git diff --check` verdes; screenshot
  do simulador em `docs/evidence/atlas-code-e1/m0-simulator.jpg` com prefixos
  conferidos contra `git-log.txt`. A prova física permanece `device-pending`.
- 2026-07-15 · Codex · C23/E2 · endpoint `GET /api/code/provenance/{hash}` e
  DTO/folha nativos. O probe real conferiu `d0a65d0`, `838585d` e `e11b4e6`
  (hash completo, autor `voce`, frase literal no ledger, obra/gates presentes,
  `trace_id` ausente). PHPUnit C22/C23: 8 testes / 62 asserts; `swift run
  AtlasCoreChecks` e `cd App && make build` verdes. O simulador expôs os cartões
  tocáveis e a prova física continua `device-pending`.
- 2026-07-15 · Codex · C24/E3 · `AtlasCodeViolationService` puro com as cinco
  regras, `GET /api/code/violations`, `atlas:code:scan`, contrato C24 no
  AtlasCore, tag nativa e sandbox isolado. Prova: scan real de `atlas-server`
  retornou violações e `plan[]`; simulador exibiu `Sinais de governança` com
  `worktree_allowlist`/`obra_return_deadline`; 24 testes PHPUnit / 106 asserts,
  `swift run AtlasCoreChecks`, `cd App && make build`, sandbox create→resolve e
  `git diff --check` verdes. Device físico `device-pending`.
- 2026-07-15 · Codex · C25/E4 + C26/E5 · política `observe|heal`, allowlist de
  cinco ações, recibos append-only com `undo_expires_at` de 30 dias, endpoint
  de undo, preflight, `/code/week`, DTOs nativos, recibo sem aprovação, card
  `A semana` e notificações off. Prova: tick HTTP real `observe`, week HTTP
  real com 855 commits/7 dias e buckets de agente, 29 testes PHPUnit / 125
  asserts, `swift run AtlasCoreChecks`, `cd App && make build` e
  `git diff --check` verdes. Cura Git em sandbox e o horizonte de duas semanas
  ainda não são afirmados como fechados; device físico `device-pending`.
- 2026-07-13 · Codex · C13 hardening local (sem commit) · backlog Autônomos
  deixou de atravessar o Core como `JSONObject`/`JSONValue`: findings, work
  orders, inbox e budgets agora têm DTOs Foundation-only com os campos públicos
  declarados pelo servidor (hash, título público do backlog, risco, rota,
  decisão, status e limites). Payload, rationale, evidência bruta, path, prompt
  e stdout não cabem no tipo. O teste HTTP fixa as chaves reais do endpoint e o
  golden Swift decodifica a bateria inteira. Prova: 54 testes PHP / 684 asserts,
  `swift run AtlasCoreChecks`, `cd App && make build` e `git diff --check`
  verdes. Fable pode usar `backlog.findings.items`, `workOrders`, `inboxItems`
  e `budgets` sem parsing; prova no iPhone continua pendente.

- 2026-07-15 · Codex · C22–C26/E1–E5 · fechamento vertical autorizado pelo
  operador: sandbox real do backend apareceu no simulador via
  `ATLAS_CODE_REPO=sandbox:/tmp/atlas-code-sandbox-e3-container`; E3 mostrou
  `main_only`/`orphan_branch` e depois ficou silencioso após a resolução. E4
  executou `heal` sem aprovação, gravou dois recibos, e `undo` restaurou
  `main`/branch/worktree com `state=byte_for_byte`; a UI mostrou `CURADO
  SOZINHO`, `você não foi necessário` e apenas o veto retroativo. E2 abriu
  proveniência no simulador e manteve `sem proveniência registrada` para
  commit sem ledger. E5 bloqueou preflight real e reconciliou `/code/week`
  (`1` Git commit, `2` heal IDs, `1` preflight bloqueado) com Git e SQL direto
  do ledger; notificações permaneceram off. Prova: backend saudável em :3737,
  PHPUnit focado verde (20 testes/119 asserts), simulador build/run verde,
  `swift run AtlasCoreChecks`, `cd App && make build` e `git diff --check`;
  prova de iPhone físico permanece `device-pending`.

- 2026-07-15 · Codex · regressão final C25 · após corrigir a união de arrays,
  o POST `mode=heal` devolveu imediatamente dois `step_receipts` completos;
  undo retornou `state=byte_for_byte` e o sandbox terminou limpo em `main`.
  Reconciliação final de `/code/week` com Git/SQL: `1` commit, `3` heal IDs,
  `1` preflight bloqueado, `0` aguardando, notificações off; o aparelho físico
  continua `device-pending`.

- 2026-07-15 · Codex · correção de fechamento · os números acima são a
  reconciliação final após a regressão (a entrada anterior registrava o estado
  intermediário). Gate PHPUnit final da superfície C22–C26: 31 testes/191
  assertions verdes; Core Checks e build App também verdes.

### 15/07 · Atlas Código — gaps do Codex fechados e PROVADOS no simulador (Fable)

Auditoria da entrega E1–E5 do Codex: o encanamento (endpoints, decode, heal,
undo, week) estava sólido; os gaps estavam na CASCA e na honestidade. Fechados:

| Gap | Correção | Prova |
|---|---|---|
| `/code/graph` sem `message` — a tela não tinha manchete | `%s` no log + parse com subject por último | PHPUnit 6/15; 179 nós reais com mensagem |
| Tela violava 6 leis (hash na superfície, autor como título, sem gramática de cor, violação em lista separada, sheet morto, UI se auto-narrando, sem pílula) | M0 reescrita no contrato do protótipo | screenshot `03-grafo-real.png` |
| Sem gramática de cor | `AtlasCodeNodeState` + `AtlasCodeGraphState` no Core | 6 checks (precedência curado>viola) |
| Violação não acendia o nó | model cruza violação↔nó e recibo↔hash | live: 22 desvios reais |
| M1 hub sem seção CÓDIGO | `AtlasCodeHubRow` agregada, exceção como sublinha | `01-hub-codigo.png` |
| M3 radar inexistente; repo hardcoded | `GET /code/repos` + `AtlasCodeRadarView`; hub→radar→grafo | `02-radar-frota.png`; PHPUnit 36/94 |
| M5 espelho inexistente | `GET /code/mirror` + varredura de 7 padrões de segredo (só linhas +) | 5 testes puros; host sem credencial |
| C18/C19/C21 órfãos (fonte no server desde `9a06fd4c56`, ninguém lia) | `AtlasTraceGovernance` + seção na review | 13 checks |
| Container não via a frota | mount `..:/Users/.../Atlas:ro` (mesmo path, read-only) | frota real no radar |
| Pasta ≠ repo (perfil guarda-chuva "saudável") | exige `.git` → `not_a_git_repository` | teste dedicado |
| Cápsula dizia "frota íntegra" sem ler nada | `repositoriesJudged`; diz "frota não lida" | honestidade restaurada |

**Prova de runtime (simulador, 15/07):** XCUITest `AtlasCodeFlowTests` dirige
hub → radar → grafo → proveniência e PASSA; evidências em
`docs/evidence/2026-07-15-atlas-codigo/`. AtlasCoreChecks 414 verdes (exit 0);
`make build` limpo; PHPUnit AtlasCode 36 testes/94 asserts.
**Honesto:** device físico segue `device-pending`; a escrita em repo de
terceiro (cura fora do atlas-server) exige decisão do operador sobre montagem
rw — hoje a frota é `:ro` por segurança.

### 16/07 · Destrava tudo — V3 worker + healer mecânico R2 (Grok 4.5)

Autorização do operador: “Destrava tudo”. Cadeia destravada sem fabricar merge:

| Unlock | Prova |
|---|---|
| Worker `software_company_loop` no host | dry_run enfileirado → job DONE; ledger ciclo 54 `dry_run_planned` |
| `atlas:native:constitution-heal` (R2) | PHPUnit 5/23; canário real dry_run→`healed`; arquivo apagado; re-scan 0 canary |
| start-run passthrough | `repo_root`, `allow_canonical_worktree_write`, `injected_finding` no job input |

**Ainda aberto (honesto):** `model.delivered` vazio (heal ≠ merge ledger); device
`passcodeRequired`; `factory_max` prefere seeds AP-789. Evidência:
`docs/evidence/2026-07-16-selfconstruction/`.

## 8. Estado do runtime (contexto que não muda toda hora)

- Backend: atlas-server em OrbStack (`atlas-backend`, :3737, 16 PHP workers —
  1 worker congelava o server com SSE) · workers launchd por provider no host
  (claude_cli, codex_cli, hermes_cli) · chat = modo `read` (danger exige
  workspace-cert).
- Device: iPhone 16 Pro Max via `make device` (wireless, MESMO WiFi do Mac;
  deploy não passa por Tailscale). App conecta via IP Tailscale
  (`100.80.228.41`, Secrets.xcconfig) — funciona em 4G/5G com a VPN ligada.
- ATS: só `NSAllowsArbitraryLoads` (granular junto ANULA a geral — iOS gotcha).
- Fixtures: `packages/atlas-rich-input-canon/fixtures/rich-input.json` — a
  régua TS↔Swift; regenerar é decisão, não rotina.
