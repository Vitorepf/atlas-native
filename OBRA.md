# OBRA — Atlas AI Mobile Max (atlas-native)

> **O blackboard único.** Fable 5 (casca) e GPT 5.6/Codex (funciona) leem este
> arquivo ANTES de qualquer trabalho e o atualizam DEPOIS de cada entrega.
> Formato de cooperação: fronteiras → gates → fila → pedidos → registro.

## 0. Missão e a lição que não se repete

**Missão:** o melhor sistema móvel de inteligência, execução e coordenação de
agentes possível — Conversation Supremacy → Voice Supremacy → Agent Cockpit →
Artifacts & Proof → Continuity → Atlas-wide Intelligence. Ambição máxima de
produto; zero cerimônia arquitetural que o operador não vê.

**A lição (o app RN morreu disso):** grande demais, nada funcionava, código
inchado e bagunçado. O antídoto NÃO é prudência tímida — é disciplina:
verticais completas e demonstráveis no device, gates que não mentem,
fronteiras executáveis por check, deletar > adicionar. O atlas-server já é
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

### Codex (funciona)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance | Evidence |
|---|---|---|---|---|---|---|---|
| C1 | **DONE** | — | `Sources/AtlasCore/{AtlasClient,InteractionRun}.swift`; checks; `ConversationModel.swift` | `f900ef1` | Reconnect SSE (`after=` + backoff, max 4) + `InteractionRun` | Retoma de `lastSequence` sem duplicar; create/stream/poll/cancel têm um único dono; cancel encerra transporte, polling e job | `ec3ffe6`; 220 checks; live create→SSE content→done; app build verde |
| C2 | **DONE** | — | core + model persistence | C1 | Outbox durável: clientId estável, recovery e `shouldKeep` | Rede/408/429 sobrevivem a relaunch; erros terminais não criam loop | `d1c78ba`; JSON atômico + relaunch/recovery; 232 checks; live outbox drenada no done |
| C3 | **DONE** | — | `Sources/AtlasCore/{RichInputEngine,AttachmentAdapters}.swift`; boundary checks; `App/Atlas/ConversationModel.swift` | F5 | engine único para imagens/arquivos/câmera/clipboard; hardening: fileImporter off-main e FileByteSource security-scoped | Arquivo grande não é materializado na MainActor; leitura continua chunked e válida depois do picker; send aguarda preparações | `da9399a` + `3b80c72` + `ec369f1`; TDD red→green; arquivo real lê por offset; live upload 3,2MB preserva SHA-256; Core + App verdes |
| C4 | **DONE** | — | `Sources/AtlasCore/LongMessage.swift`; `Sources/AtlasCoreChecks/LongMessageChecks.swift`; `ConversationModel.swift` | C3 | Long-message >40k → `.md` | Texto longo chega uma vez como documento canônico | `03192bd`; red→green; live upload→create→provider leu canary existente só no Markdown |
| C5 | **DONE** | — | trace DTO/model + checks | C1 | tool events + decisão/quality + atividade atual honesta | Reasoning/progress intercalado não substitui tool aberta; completion libera o slot; View sem parsing | evidência anterior + `30b2023`; TDD red→green, live `shell.started` >5s/replay, XCUITest encontrou `Executando comando` ao vivo |
| C6 | **DONE** | — | `Package.swift`; `App/project.yml`; `Sources/AtlasCore/AtlasTime.swift`; check runner e demais warnings Core | C1–C5 | Zerar warnings e ativar Swift 6 | Core e App compilam em Swift 6 com zero warning próprio | `475267f` + `97c9fdc`; rebuild limpo Core e `xcodebuild clean build` App sem warning próprio |
| C7 | **IN_PROGRESS** | **Codex** | `App/project.yml`; `App/Makefile`; `App/UITests/**`; scripts de device proof; `Sources/AtlasCoreChecks/{InteractionRun,DeviceProofHarness}Checks.swift` | U1–U6 | Harness só fica verde com envio confirmado, tool exata ao vivo e tool persistida visível/tocável | XCUITest dirige conversa/tool/cockpit e captura evidence attachment no iPhone real | `9af0b72` + `9b92a8a` + `df55878`; Simulator Hermes/Kimi: 1 teste/0 falhas; físico chega ao destino correto, mas preflight confirma `Unlock iPhone de Vitor to Continue`; harness agora falha rápido e preserva evidência |
| C8 | **DONE** | — | `../atlas-server/app/Services/Ai/{AtlasFinalResponseSanitizer,HermesCliProvider}.php`; `../atlas-server/app/Services/Ai/Hermes/Acp/{HermesAcpProtocol,AtlasHermesAcpRuntime}.php`; testes correspondentes; `Sources/AtlasCore/AtlasAssistantPresentation.swift`; checks | C5 | Hermes/Kimi provider-neutral: ACP projeta thought/tool start/tool completion; Reasoning-only nunca vira sucesso/apresentação; mobile solicita transporte estruturado | Ferramenta real chega live, persiste no ledger e reaparece no replay; reasoning fica somente como atividade sanitizada; resposta final utilizável ou falha honesta | `f356bd4a1` + `d77cf5a`; migration aplicada; 129 testes/733 asserts no server; Core checks + App build; live Hermes ACP com `shell.started` >5s, persistência e replay |

### Fable (casca)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance | Evidence |
|---|---|---|---|---|---|---|---|
| U1 | **IN_PROGRESS** | **Fable** | `App/Atlas/ConversationView.swift` | F5 | Provar foto → strip → progresso → envio e polir strip | Fluxo real legível no device, inclusive erro e remoção | `ed10c81` instalado+aberto no iPhone 23:55; falta print do operador p/ DEVICE_PROVEN |
| U2 | **IN_PROGRESS** | **Fable** | `App/Atlas/ConversationView.swift` | U1 | Composer supremo em todos os estados | Nenhum controle falso; estados e motion aprovados no device | `a59003f` slot 3-estados honesto instalado; falta aprovação visual |
| U3 | **IN_PROGRESS** | **Fable** | execution views | C5 | Cockpit v2 para tools/receipt/quality | Substitui `ExecutionRibbon` estático; mostra atividade atual e timeline registrada/expansível em cada resposta, incluindo tools, comandos sanitizados, receipt e quality | `97c9fdc` + C8; Simulator Hermes/Kimi mostra tool live e timeline persistida de 9 passos alcançável; falta aprovação/prova no físico |
| U4 | **IN_PROGRESS** | **Fable** | `RootView.swift`, `WorkspaceView.swift` | C1 | Vazio, rede, offline e servidor fora | Toda falha tem explicação e recuperação acionável | `c9adefb` loading/falha/vazio editoriais instalados; distinção offline×timeout precisa de contrato (§5) |
| U5 | **IN_PROGRESS** | **Fable** | `AtlasType.swift` + views | U2–U4 | Dynamic Type, VoiceOver, Reduce Motion, 120Hz/startup | Auditorias e métricas no device registradas | `a582dac` Dynamic Type em TODA tipografia (relativeTo) + VoiceOver labels; falta auditoria visual no device |
| U6 | **IN_PROGRESS** | **Fable** | Assets.xcassets | U2 | Ícone, splash e masthead final | `5aa6245` ícone ✦ Ink & Brass no bundle e instalado; falta aprovação do operador na home | — |

### Fable · Experience Max (goal do operador 2026-07-13: notificações + tela
### bloqueada como o Cursor + polimento extraordinário)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance |
|---|---|---|---|---|---|---|
| U7 | **IN_PROGRESS** | **Fable** | RootView/SearchView (casca) | — | Busca REAL na home (o botão hoje é morto — viola constituição) | busca filtra threads reais e navega |
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
- [ABERTO] Codex→Fable: substituir o botão que lê `UIPasteboard.general`
  diretamente por `PasteButton` nativo. No iOS 26 o fluxo atual abre “Permitir
  Colar”, bloqueia a automação e cria fricção real; o rich input Core já aceita
  o texto pelo seam existente, portanto é correção exclusivamente da casca.
- [ABERTO] Codex→Fable: `ConversationView.swift` chegou a 930 linhas (régua da
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
- [PARCIAL · C11 · Codex→Fable] Fable→Codex: fila de mensagens durante a execução
  (paridade Cursor, exigência direta do operador com screenshots). O model
  precisa expor: `queuedMessages: [QueuedMessage]` (`id` + `text`),
  `queue(text:)` (chamado pelo send quando `isSending`), `promote(id:)`
  (enviar agora → cancela? NÃO: envia como próximo, sem matar o turno),
  `removeQueued(id:)`, e auto-drenagem FIFO quando o turno conclui (cada
  item vira um turno novo na ordem). Persistência mínima: a fila vive no
  model (sobrevive a navegar para fora e voltar). A casca já tem o desenho
  pronto (chip `Fila N` na linha de chips + folha com enviar-agora/apagar —
  cena 11 da proposta, commit `79e7eb9`); ligo a UI no mesmo dia em que a
  API existir. Sem a API não shipo UI falsa.
  **Entrega Core 2026-07-13 (WIP não commitado):**
  `Sources/AtlasCore/AtlasQueuedFollowUp.swift`,
  `Sources/AtlasCoreChecks/AtlasQueuedFollowUpChecks.swift` e
  `App/Atlas/ConversationModel.swift` agora expõem `queuedMessages`,
  `queue(text:)`, `promote(id:)`, `removeQueued(id:)` e drenagem FIFO após
  sucesso. A store é Foundation-only, JSON atômico por conversa, sobrevive a
  relaunch e migra `local:*` para `thread:*` quando o create devolve a thread
  canônica. `promote` só muda o próximo turno; não cancela o ativo. Checks
  cobrem vazio, FIFO, promover, relaunch, dequeue, remoção e migração; Core
  checks + `App/make build` verdes em 2026-07-13. Falta Fable ligar a cena 11
  existente aos métodos e provar a jornada no device.
- [FEITO] Fable→Codex: contrato U3 está estável desde `cededd4`/`bb8ecea`:
  `ChatBubble.currentActivity`, `activities`, `decisionSummary` e
  `qualitySummary`, sem parsing de wire na View. Replay live confirmou que o
  ledger real reconstrói `process_started`/`process_finished`; o decoder também
  aceita o resource atual de tool receipt (`kind` + `occurred_at`) e o legado.
  A tabela `ai_tool_events` está vazia neste ambiente, portanto comandos reais
  vêm hoje dos `stream_events`; a View deve renderizar ambos pelo mesmo array
  `activities`. U3 está desbloqueado — não aguarda outro contrato Codex.

- [ABERTO] Fable→Codex: **C8 — Widget Extension target (ActivityKit)** no
  project.yml + entitlement de push/Live Activities: preciso do alvo pra UI de
  Live Activity (lock screen + Dynamic Island, paridade Cursor). Eu entrego
  toda a UI/attributes; você o target/build. Depois: vertical APNs real
  (server envia push no trace concluído — cross-repo atlas-server).
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

## 6. Decisões registradas

- 2026-07-13 · Fable atravessou `project.yml` ADITIVAMENTE (target AtlasWidgets)
  sob autoridade de goal direto do operador (tela bloqueada = Cursor); WIP do
  Codex preservado. C8 remanescente pro Codex: entitlement/push APNs fase 2
  (update de Live Activity além da janela de execução) + hardening do target.
- 2026-07-13 · Fable corrigiu 2 erros Swift 6 no próprio TurnPresence
  (Activity<T> não-Sendable → enumeração estática dentro da Task).

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

## 7. Registro de entregas (append-only; prova obrigatória)

> Formato: `AAAA-MM-DD · <agente> · <commit> · <o quê> · prova: <checks/print/live-probe>`

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
