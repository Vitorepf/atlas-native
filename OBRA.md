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
| # | Tarefa | Notas |
|---|---|---|
| C1 | **Reconnect do stream** (`after=` + backoff, maxReconnects=4 como o .ts) + extrair `InteractionRun` | A extração é dirigida por ESTA feature — create/stream/poll/reconnect/cancel num tipo; ConversationModel fica só apresentação |
| C2 | **Outbox durável** (PendingSubmission: clientId estável, shouldKeep no core — rede/408/429 mantém, 4xx e 5xx-com-anexo descartam; recovery ≥8s ≤2min) | Paridade com o RN que hoje não perde mensagem |
| C3 | Adapters restantes: **fileImporter (PDF/arquivos), câmera, clipboard** → `AttachmentInput` | ~30-60 linhas cada sobre o MESMO engine; PDFs exigem create timeout 120s (já no client) |
| C4 | Long-message >40k chars → anexo `.md` | Paridade RN (prepareLongMessageForAtlas) |
| C5 | Plumbing de `tool_events` + `decision_receipt` + `quality_evaluation` (trace → model) | Expor no ChatBubble/ExecAgent pro Fable renderizar |
| C6 | Zerar warnings StrictConcurrency → bump modo Swift 6 | |

### Fable (casca)
| # | Tarefa | Notas |
|---|---|---|
| U1 | **Verificar anexo no device** (foto → strip → progresso → envio) e polir a strip | primeira prova visual do rich input |
| U2 | **Composer supremo**: estados (vazio/rascunho/anexos/subindo/erro), motion editorial, haptics calibrados | melhor que Cursor é o requisito, identidade própria |
| U3 | **Cockpit de execução v2**: tool_events stream ("rodou git status"), decision receipt inline (tap → "considerou X,Y → escolheu W" + hash), quality gate | consome o plumbing do C5; é O diferencial vs Cursor |
| U4 | Estados editoriais: vazio, erro de rede, offline, servidor fora | falha bonita > spinner infinito |
| U5 | Acessibilidade (Dynamic Type, VoiceOver, Reduce Motion já respeitado) + auditoria 120Hz/startup no device | performance é feature |
| U6 | Ícone do app + splash + polish do masthead | |

### Verticais seguintes (ordem)
Voice Supremacy (LiveKit/ditado/resposta falada) → Agent Cockpit (obras
autônomas, pausar/redirecionar/escolhas) → Artifacts & Proof (screenshots,
diffs, aprovação, evidência) → Continuity (Live Activities, Dynamic Island,
push, widgets, App Intents, Share Extension) → Atlas-wide (agenda, saúde,
decisões, capturas, busca universal).

## 5. Pedidos de contrato (Fable ⇄ Codex)

> Formato: `- [ABERTO|FEITO] <quem pede>→<quem entrega>: <o que> — <por quê>`

- (vazio)

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

## 7. Registro de entregas (append-only; prova obrigatória)

> Formato: `AAAA-MM-DD · <agente> · <commit> · <o quê> · prova: <checks/print/live-probe>`

- 2026-07-12 · Fable 5 (bootstrap da obra) · `63c9a2f` · lifecycle honesto:
  Stop real (SSE + jobs), payload completo (effort/workspace/read), gates sem
  mentira, StrictConcurrency ON · prova: checks verdes + make build honesto
- 2026-07-12 · Fable 5 · `9a95320`→`f900ef1` · Rich Input F1–F5: contrato L1
  (38 checks vs fixture TS), engine L2 (23 checks, resume/retry/sha), transporte
  real (live-probe: 3.2MB reais, sha ✓, resume ✓), AtlasImaging (HEIC→JPEG),
  iOS liga (📎 real → chunks → create) · prova: 195 checks + live-probe verde +
  instalado no iPhone (verificação visual pendente = U1)

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
