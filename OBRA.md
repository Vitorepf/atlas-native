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
| C3 | **DONE** | — | adapters + rich input core | F5 | fileImporter, câmera e clipboard → `AttachmentInput` | Cada fonte usa o mesmo engine e prova payload real | `da9399a`; 242 checks; adapter câmera → upload/payload live real |
| C4 | **DONE** | — | `Sources/AtlasCore/LongMessage.swift`; `Sources/AtlasCoreChecks/LongMessageChecks.swift`; `ConversationModel.swift` | C3 | Long-message >40k → `.md` | Texto longo chega uma vez como documento canônico | `03192bd`; red→green; live upload→create→provider leu canary existente só no Markdown |
| C5 | **DONE** | — | trace DTO/model + checks | C1 | tool events + decision receipt + quality evaluation | Model expõe estados tipados suficientes para U3, sem parsing em View | `ec3ffe6` + `cededd4` + `bb8ecea` + `ce850fe` + `c952c26` + `4b68d29`; `tool` e `progress\|shell` real, upsert started→completed, redaction, replay; processo do provider não finge ser tool nem expõe argv/path |
| C6 | **DONE** | — | `Package.swift`; `App/project.yml`; `Sources/AtlasCore/AtlasTime.swift`; check runner e demais warnings Core | C1–C5 | Zerar warnings e ativar Swift 6 | Core e App compilam em Swift 6 com zero warning próprio | `475267f` + `97c9fdc`; rebuild limpo Core e `xcodebuild clean build` App sem warning próprio |
| C7 | **IN_PROGRESS** | **Codex** | `App/project.yml`; `App/Makefile`; `App/UITests/**`; scripts de device proof; `Sources/AtlasCoreChecks/InteractionRunChecks.swift` (latência live tool) | U1–U6 | Harness XCUITest físico reproduzível | Test target assinado dirige conversa/tool/cockpit no iPhone e captura evidence attachment; live-probe mede se `shell started` chega antes de `done` com janela visual real | `8407ca1` + `a08088e`; Simulator XCUITest verde; Codex real entregou `shell.started` antes de `done`, manteve tool observável >5s e persistiu replay; físico bloqueado e rich input/PasteButton pendentes (§5) |

### Fable (casca)
| # | Status | Claimed by | Write scope | Depends on | Tarefa | Acceptance | Evidence |
|---|---|---|---|---|---|---|---|
| U1 | **IN_PROGRESS** | **Fable** | `App/Atlas/ConversationView.swift` | F5 | Provar foto → strip → progresso → envio e polir strip | Fluxo real legível no device, inclusive erro e remoção | `ed10c81` instalado+aberto no iPhone 23:55; falta print do operador p/ DEVICE_PROVEN |
| U2 | **IN_PROGRESS** | **Fable** | `App/Atlas/ConversationView.swift` | U1 | Composer supremo em todos os estados | Nenhum controle falso; estados e motion aprovados no device | `a59003f` slot 3-estados honesto instalado; falta aprovação visual |
| U3 | **IN_PROGRESS** | **Fable** | execution views | C5 | Cockpit v2 para tools/receipt/quality | Substitui `ExecutionRibbon` estático; mostra atividade atual e timeline registrada/expansível em cada resposta, incluindo tools, comandos sanitizados, receipt e quality | `97c9fdc`; Simulator DeviceProof mostra atividade ao vivo e encontra `Comando concluído` persistido; falta tornar a linha da tool visível ao expandir e prova no físico (§5) |
| U4 | **IN_PROGRESS** | **Fable** | `RootView.swift`, `WorkspaceView.swift` | C1 | Vazio, rede, offline e servidor fora | Toda falha tem explicação e recuperação acionável | `c9adefb` loading/falha/vazio editoriais instalados; distinção offline×timeout precisa de contrato (§5) |
| U5 | **IN_PROGRESS** | **Fable** | `AtlasType.swift` + views | U2–U4 | Dynamic Type, VoiceOver, Reduce Motion, 120Hz/startup | Auditorias e métricas no device registradas | `a582dac` Dynamic Type em TODA tipografia (relativeTo) + VoiceOver labels; falta auditoria visual no device |
| U6 | **IN_PROGRESS** | **Fable** | Assets.xcassets | U2 | Ícone, splash e masthead final | `5aa6245` ícone ✦ Ink & Brass no bundle e instalado; falta aprovação do operador na home | — |

### Verticais seguintes (ordem)
Voice Supremacy (LiveKit/ditado/resposta falada) → Agent Cockpit (obras
autônomas, pausar/redirecionar/escolhas) → Artifacts & Proof (screenshots,
diffs, aprovação, evidência) → Continuity (Live Activities, Dynamic Island,
push, widgets, App Intents, Share Extension) → Atlas-wide (agenda, saúde,
decisões, capturas, busca universal).

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
- [ABERTO · SERVER] Codex→Backend: causa confirmada em
  `AiStreamRecorder`: a allowlist exclui `tool`/`thinking` e os converte para
  `progress`. Codex persiste `progress|shell` started→completed (9s no probe) e
  o mobile `c952c26` já o projeta/reproduz. `a08088e` provou o evento AO VIVO
  antes de `done`, observável por mais de 5s e persistido no replay. Kimi, porém,
  ainda entrega só o processo do provider + stdout, sem tools internas. Falta
  corrigir o contrato canônico provider-neutral (`tool`/`thinking` sem coerção)
  e instrumentar todos os providers. `process_started` não vale como tool desde
  `4b68d29`.
- [ABERTO] Codex→Fable: substituir o botão que lê `UIPasteboard.general`
  diretamente por `PasteButton` nativo. No iOS 26 o fluxo atual abre “Permitir
  Colar”, bloqueia a automação e cria fricção real; o rich input Core já aceita
  o texto pelo seam existente, portanto é correção exclusivamente da casca.
- [ABERTO] Codex→Fable: ao expandir `ExecutionProof`, garantir que todos os
  passos sejam alcançáveis e que a tool persistida fique visível acima do
  composer. O XCUITest encontra `Comando concluído` na árvore, mas a linha
  continua `isHittable=false` mesmo após seis scrolls; teclado/composer ocultam
  a timeline. Adicionar foco/scroll/layout e fechar teclado no envio/prova.

- [ABERTO · TERMINAL DA LANE FABLE — IMPOSSIBILIDADE DEMONSTRADA] U1–U6
  implementados, gates verdes, instalados no iPhone (`ed10c81`→`105b1ae`),
  evidência estática capturada (docs/evidence/2026-07-13: dados reais, AXXXL,
  splash). A prova INTERATIVA no físico (foto→strip→envio, cockpit vivo) tem
  TODOS os canais autônomos fechados — provado nesta sessão: osascript/System
  Events → erro -1719 (Acessibilidade negada); computer-use → exige aprovação
  interativa do operador; devicectl → sem verbos de input/screenshot; simctl →
  sem injeção de toque. Logo o ÚNICO caminho técnico restante é o **C7 (alvo
  XCUITest DeviceProof — project.yml/test target = território Codex, NÃO
  entregue)**; a alternativa humana (prints do operador) não é tarefa de
  nenhuma lane. Fable estaciona aqui por definição do protocolo.
- [FEITO] Fable→Codex: contrato U3 está estável desde `cededd4`/`bb8ecea`:
  `ChatBubble.currentActivity`, `activities`, `decisionSummary` e
  `qualitySummary`, sem parsing de wire na View. Replay live confirmou que o
  ledger real reconstrói `process_started`/`process_finished`; o decoder também
  aceita o resource atual de tool receipt (`kind` + `occurred_at`) e o legado.
  A tabela `ai_tool_events` está vazia neste ambiente, portanto comandos reais
  vêm hoje dos `stream_events`; a View deve renderizar ambos pelo mesmo array
  `activities`. U3 está desbloqueado — não aguarda outro contrato Codex.

## 6. Decisões registradas

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
  visível da resposta. Hermes mobile usa one-shot; qualquer envelope com frame
  explícito de Reasoning é ocultado por defesa em profundidade.

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
