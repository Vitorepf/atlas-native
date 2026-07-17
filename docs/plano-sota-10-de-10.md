# SPEC SOTA 10/10 — plano completo de transformação do atlas-native

> **Para a IA implementadora (Grok 4.5 ou qualquer executor sem contexto prévio).**
> Esta spec é autossuficiente: contém o protocolo da obra, as kill-lists
> verificadas, receitas por tarefa com assinaturas de código, comandos literais
> de gate e a definição objetiva de "pronto". Hierarquia de autoridade:
> **canon do operador > esta spec > improviso.** Se a spec conflitar com o
> estado real do repo (HEAD avança), o repo vence — re-verifique com grep antes
> de cada deleção.
>
> Gerado em 2026-07-16 a partir de 5 auditorias + 2 inventários de eliminação,
> todos baseados em grep/leitura real do código (excluindo `.build/`,
> `App/build*/`, `.claude/worktrees/`).

## Objetivo

Levar **todos os eixos a 10/10** — arquitetura, qualidade Swift, fluidez UI
(120Hz), eficiência systems-level, saúde evolutiva — **eliminando o máximo de
código**. Placar atual → alvo:

| Eixo | Hoje | Alvo | Fase que fecha |
|---|---|---|---|
| Arquitetura & abstração | 8.5 | 10 | F1, F3, F6 |
| Qualidade Swift | 7.5 | 10 | F1, F4 |
| Fluidez UI | 7.0 | 10 | F2-casca, F5 |
| Saúde evolutiva | 7.0 | 10 | F0, F3, F4 |
| Eficiência systems | 6.0 | 10 | F2-core, F5 |

**Saldo projetado: ≥ −2.500 linhas Swift líquidas** + ~700K de docs/fontes.
O repo termina MENOR, mais rápido e mais forte. Nenhuma nota sobe por
afirmação — sobe por prova (seção "Definition of Done").

---

## §A · BOOTSTRAP OBRIGATÓRIO (antes de qualquer edição)

1. **Leia `OBRA.md` INTEIRO.** É o blackboard único: fronteiras (§1), gates
   (§2), constituição anti-inchaço (§3), fila (§4), pedidos (§5), decisões
   (§6), registro append-only (§7).
2. **Fronteiras**: `Sources/*` + lógica dos models = lane Codex;
   `App/Atlas/*View*` + design system = lane Fable. Esta spec atravessa as
   duas lanes: **registre em OBRA.md §6 uma decisão datada** citando a
   autorização do operador para esta transformação (precedente: decisão de
   2026-07-15 "Missão noturna E1–E5" que suspendeu a fronteira para uma missão
   específica). Sem esse registro, não toque território alheio.
3. **Branch main local APENAS.** Zero branch de obra, zero merge. Antes de
   commitar: `git branch --show-current` == `main`. Stage explícito
   (`git add -- <arquivos>`), nunca `git add -A`.
4. **Protocolo da main compartilhada** (OBRA §2): marque a linha da tarefa na
   fila com IN_PROGRESS + seu nome + write-scope antes de começar; use o lock
   `.atlas-mobile-plan.lock` para editar OBRA.md; releia `git status --short`
   antes de aplicar patch; preserve arquivos fora do seu escopo.
5. **NÃO edite**: `CLAUDE.md`/`AGENTS.md` (projeções geradas), OBRA §5/§7
   existentes (append-only — só adicione), `docs/evidence/` (trilha de prova),
   nada em `../atlas-server` salvo pedido explícito.
6. **Leis de honestidade (invioláveis, valem para TODO o plano):** zero dado
   inventado; ausência ≠ zero; nenhum botão sem ação real; decode fail-closed
   em contrato versionado permanece fail-closed; nenhuma prova declarada sem
   evidência; `device-pending` nunca vira prova.

### Gates (antes de TODO commit — sem exceção, sem `|| true`)

```bash
swift run AtlasCoreChecks          # exit 0 obrigatório
cd App && make build               # exit 0 obrigatório
git diff --check                   # sem whitespace errors
```

- Tocou wire/contrato → live-probe: `ATLAS_LIVE=1 ATLAS_TOKEN=… swift run AtlasCoreChecks`
- Tocou visual → `cd App && make device` + screenshot; XCUITest:
  `xcodebuild test -project App/Atlas.xcodeproj -scheme Atlas -only-testing:AtlasDeviceProof/AtlasCodeFlowTests` (simulador)
- Prova física → `cd App && make device-proof` (preflight aborta com rc=2 se o
  iPhone estiver bloqueado — isso é comportamento correto, não falha sua).

### Formato de commit

- Prefixos: `fix(core)|feat(core)` (Sources), `polish(ui)|feat(ui)` (casca),
  `docs(obra)` (blackboard). Mensagem em português, primeira linha < 72 chars,
  dizendo O QUE e POR QUÊ (estilo do repo: "o radar não dá alta à frota que
  ele não varreu").
- Ao concluir cada fase: atualizar OBRA.md §7 (registro com PROVA) e a fila §4.

---

## F0 · A GRANDE PODA — kill-list verificada (≈2.270 linhas Swift + ~700K docs)

> Regra de execução: para CADA item, rode o grep de re-verificação indicado
> ANTES de deletar (o HEAD pode ter avançado desde este inventário). Grep
> sempre excluindo `.build`, `App/build*`, `.claude/worktrees`:
> `rg -g '!*.build*' -g '!*worktrees*' "<símbolo>" App/ Sources/`
> DELETE só se 0 refs em App/ E 0 refs em Sources/AtlasCore fora do próprio
> arquivo (refs em Sources/AtlasCoreChecks NÃO contam como vida).
> Commits pequenos: um arquivo/cluster por commit, gates verdes entre cada um.

### F0.1 · Fato estrutural que governa a poda (LEIA PRIMEIRO)

`AtlasAiTrace` (em `Sources/AtlasCore/AtlasAiModels.swift:80-111`, **VIVO**)
tem propriedades cujos tipos moram nos arquivos suspeitos. Esses tipos são
estruturais para um decode consumido e **NÃO podem morrer**:

| Propriedade do trace | Tipo | Arquivo |
|---|---|---|
| `jobs` (:97) | `[AtlasAiJob]?` | AtlasAiJobs.swift |
| `atlasDecideExecution` (:98) | `AtlasAiExecutionState?` | AtlasAiJobs.swift |
| `routerDecision`/`atlasDecision`/`decisionReceipt` (:99-101) | 3 structs | AtlasAiDecisions.swift |
| `qualityEvaluation`/`qualityActions` (:102-103) | 2 structs | AtlasAiQuality.swift |
| `streamEvents` (:107) | `[AtlasAiStreamEvent]?` | AtlasAiStream.swift |

**INTOCÁVEIS:** `AtlasAiModels.swift` (núcleo da conversa), `AtlasAiStream.swift`
(motor SSE), `AtlasAiJobs.swift` (jobs do trace + retry/cancel/resume vivos).
Também intocáveis em TODO o repo: sub-structs de respostas Codable (são
acessadas via propriedade, nunca pelo nome — 0 refs por nome NÃO significa
morte), `AccentColor.colorset` (amarrado a build setting; deletar gera
warning), `docs/evidence/`.

### F0.2 · Deletar arquivos INTEIROS (commit 1)

| Arquivo | Linhas | Verificação prévia |
|---|---|---|
| `Sources/AtlasCore/AtlasAiTelemetry.swift` | 587 | todos os 34 tipos + 9 métodos = 0/0 refs |
| `Sources/AtlasCore/AtlasAiPolicies.swift` | 460 | 19 tipos + 5 métodos = 0/0 |
| `Sources/AtlasCore/AtlasAiProviders.swift` | 402 | 22 tipos + 3 métodos = 0/0 (a ref `AtlasAiExecutionState` em :200 é one-way, morre junto) |
| `Sources/AtlasCore/AtlasAiAttachments.swift` | 128 | 5 tipos + 1 método = 0/0 |

Cascata obrigatória em `Sources/AtlasCoreChecks/main.swift` (mesmo commit,
senão não compila): remover as chamadas `runProvidersChecks(check)` (linha
~220), `runDecisionsChecks(check)` (~229), `runTelemetryChecks(check)` (~230),
`runPoliciesChecks(check)` (~231), `runAttachmentsChecks(check)` (~233) e o
bloco live-probe de `getAiProvidersStatus()` (~283-288). As funções
`run*Checks` em si moram DENTRO dos arquivos deletados — morrem junto. Nenhum
arquivo `*Checks.swift` fica órfão (verificado).

### F0.3 · Podas PARCIAIS por faixa de linha (commit 2)

**`Sources/AtlasCore/AtlasAiDecisions.swift`** — manter linhas 1–76
(`AtlasAiRouterDecision`, `AtlasAiDecisionReceipt`, `AtlasAiDecision` — pinados
pelo trace). **Deletar 77–221**: `AiDecisionsResponse`, `AiDecisionPreviewResponse`,
`PreviewAiDecisionInput`, `listAiDecisions`, `previewAiDecision`,
`runDecisionsChecks`.

**`Sources/AtlasCore/AtlasAiQuality.swift`** — manter `AtlasAiQualityEvaluation`
(:15), `AtlasAiQualityAction` (:38) e `runQualityChecks` (:103, testa só os
tipos mantidos). **Deletar 59–96**: `AiQualityActionsResponse`,
`AiQualityActionResponse`, `listAiQualityActions`, `runAiQualityAction`.

**`Sources/AtlasCore/AtlasAiThreadsExtra.swift`** — manter:
`AtlasAiSurfaceHandoff` (:111), `AiSurfaceHandoffResponse` (:124),
`AtlasAiSurfaceDestination` (:197), `HandoffAiThreadSurfaceInput` (:203),
`FeedbackAiInteractionInput` (:211), `handoffAiThreadSurface` (:256),
`feedbackAiInteraction` (:269) — consumidos por `ConversationModel` (:87, :142,
:219, :226-227, :662). **Deletar** (≈248 linhas): blocos 13–97 (SessionState/
Compaction/ProviderHandoff/ContextSnapshot), 101–108 (4 envelopes), 130–196
(3 inputs), 230–252 + 261–266 (createAiThread, getAiThreadState,
compactAiThread, switchAiThreadProvider, listAiThreadSnapshots) e 284–343
(metade do `runThreadsExtraChecks` que testa o que morreu — manter os blocos
de surface-handoff 345–373). Atualizar o comentário de cabeçalho (1–11) que
cita métodos deletados.

### F0.4 · Cadeia Models+Merge — DECISÃO DO OPERADOR (commit 3, se aprovado)

`Sources/AtlasCore/Models.swift` (49) + `Sources/AtlasCore/Merge.swift` (76):
`AtlasCapture`/`AtlasCheckin`/`ClientMergeable`/`Merge.byClientId` têm **0
consumidores de produto** (a única "ref" em App é um comentário em
`AtlasCodeView.swift:809`). É o merge core LWW/tombstone portado do RN —
correto, testado, **nunca ligado**. Deletar também exige remover de
`main.swift`: helper `cap()` (29–33), seção "Merge core" (54–111), seção
Codable `AtlasCapture` (113–129) — ≈80 linhas.
**Ressalva registrável:** é o PoC do sync offline futuro. Se o operador
confirmar que sync local não está no roadmap próximo → DELETE (125 + 80
linhas). Senão → mover para um único arquivo `MergePoC.swift` com comentário
`ponytail:` explicando o ceiling. **Pergunte via OBRA §5 se não houver
resposta do operador; default desta spec: DELETE** (a lei é "sem fundação pra
depois"; ressuscita do git quando o sync nascer).

### F0.5 · Trio VERIFICAR em AtlasAiModels.swift (commit 3)

Inventário indica `AtlasAiProviders` (enum), `AtlasAiSession`, `AtlasAiMessage`
(`AtlasAiModels.swift:15-55`, 41 linhas) com 0 refs fora das declarações.
**Confirme com grep** (podem ser usados por envelopes de resposta no mesmo
arquivo — `AiThreadResponse`/`AiInteractionsResponse`). Se 0/0 real → DELETE.
Se estruturais → KEEP com nota.

### F0.6 · Tokens de tema e affordance morta (commit 4 — casca)

- `App/Atlas/AtlasTheme.swift`: deletar `bgDeep` (:12), `goldDeep` (:26),
  `goldLight` (:27), `domProgramacao` (:33), `domAtlas` (:35) — 0 usos
  confirmados. **`prussian` (:29) FICA** — 1 uso vivo em
  `AtlasMarkdownView.swift:143`.
- `App/Atlas/RootView.swift:214-216`: remover o botão "Adicionar workspace"
  (closure vazia — viola "zero botão falso"). Quando existir contrato de
  criação de workspace, ele volta com ação real.

### F0.7 · Fontes inalcançáveis (commit 5 — casca)

`AtlasFont.serif` (`App/Atlas/AtlasType.swift`) tem default `.semibold`;
TODAS as 28 chamadas resolvem para SemiBold (20 explícitas + 8 default).
Os cases `.bold/.medium` do switch são código inalcançável comprovado:
- **DELETE** `App/Atlas/Fonts/Fraunces_700Bold.ttf` (72K) e
  `Fraunces_500Medium.ttf` (72K) + as 2 linhas correspondentes em
  `App/Atlas/Info.plist` (UIAppFonts) + os cases mortos do switch em
  `AtlasType.swift` (mantendo `default → "Fraunces-Regular"`).
- **MANTER** `Fraunces_400Regular.ttf` (é o fallback do `default` do switch —
  deletar quebraria o fallback), `Fraunces_600SemiBold`, `Fraunces_400Regular_Italic`,
  os 2 JetBrainsMono.
- **Prova:** app renderiza idêntico (screenshot antes/depois no simulador).

### F0.8 · Docs: duplicatas e arquivamento (commit 6 — docs)

- `docs/proposals/fable-execucao-viva/`: os 3 HTMLs `atlas-code-mobile.html`,
  `atlas-codigo-plano.html`, `atlas-nova-era.html` são **byte-idênticos (md5)**
  às cópias da raiz de proposals — DELETE (132K). O `index.html` do bundle é
  quase-idêntico a `../fable-5.html`: DELETE também, mas ANTES reponte os 2
  links externos que apontam para ele:
  `docs/proposals/codex-execucao-viva/index.html:163` e
  `docs/proposals/codex-autonomos-command-center/index.html:25`
  (`../fable-execucao-viva/index.html` → `../fable-5.html`).
  O `atlas-codigo-evolucao.md` do bundle é variante ANTIGA do canônico
  `docs/atlas-codigo-evolucao.md` — DELETE (o canônico fica).
- `docs/superpowers/` (72K, planos/specs one-shot de 2026-07-13 já executados):
  mover para `docs/archive/superpowers/` (ARQUIVAR, não deletar — registro do
  porquê).
- `scripts/codex-execution-queue.test.mjs` (testa JS de um mockup, sem runner
  no repo): mover junto para `docs/archive/`.
- `.DS_Store` (6 arquivos, untracked): deletar e adicionar `.DS_Store` ao
  `.gitignore` se ainda não estiver.
- **Proposta ao operador (não executar sem OK):** extrair registros §7 do
  OBRA.md anteriores a 2026-07-15 para `docs/OBRA-ARCHIVE.md` (o arquivo tem
  86K; append-only respeitado — histórico realocado, não apagado).

### F0.9 · Rotas HTTP órfãs (informativo para o servidor)

Após a poda, estas rotas ficam sem chamador no app (registrar em OBRA §5 como
informação ao Codex/servidor; NÃO mexer no atlas-server): todo
`/ai/telemetry/*`, `/ai/policies/*`, `/ai/providers/*`, `/ai/decisions*`,
`/ai/quality/*`, `/ai/attachments/search`, `POST /ai/threads`,
`GET /ai/threads/{id}/state|snapshots`, `POST /ai/threads/{id}/compact|switch-provider`.
Opcionais de trim no app: `getAiJob` (0 chamadores) e `listAiJobs` (só
live-probe) em `AtlasAiJobs.swift` — pode deletar `getAiJob`; manter
`listAiJobs` (o live-probe o usa).

---

## F1 · O COMPILADOR ASSUME (estados e IDs tipados)

### F1.1 `AtlasTurnStatus` (commit 7)

Hoje: lifecycle em `String` comparado a literais em 14 pontos de 4 arquivos
(`InteractionRun.swift:399-405`, `ConversationModel.swift:650,953,971`,
`ConversationCockpit.swift`), com `["succeeded","failed","cancelled"]`
duplicado. Criar em `Sources/AtlasCore/`:

```swift
/// Lifecycle público do turno. Wire-tolerante: valor desconhecido não quebra
/// decode (fail-open no bag), mas nunca é tratado como terminal.
public enum AtlasTurnStatus: Sendable, Equatable {
    case queued, processing, awaitingUserChoice, awaitingExternal
    case succeeded, failed, cancelled
    case unknown(String)

    public init(rawValue: String) { /* switch com default .unknown */ }
    public var isTerminal: Bool { /* succeeded/failed/cancelled */ }
    public var isSuspension: Bool { /* awaiting* */ }
}
```

Substituir as 14 comparações; `AtlasAiTrace.status`/`job.status` continuam
`String` no wire (fail-open), com `var turnStatus: AtlasTurnStatus` computado.
Golden check do mapeamento (incluindo `.unknown` nunca terminal).
**Prova:** `rg '"succeeded"|"cancelled"|"awaiting_user_choice"' Sources/ App/`
→ só dentro do enum e dos checks.

### F1.2 IDs tipados (commits 8–10: Core → models → views)

161 declarações de `traceId/threadId/jobId/patchId/clientId: String`;
`changeReviewDiff(traceId:patchId:)` aceita argumentos trocados. Criar:

```swift
public struct TraceID: RawRepresentable, Hashable, Codable, Sendable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
}
// Idem: ThreadID, JobID, PatchID, ClientID (5 structs, 1 arquivo AtlasIDs.swift)
```

Migração mecânica em 3 commits (Core, depois models, depois views) — o
compilador é o guia: não compila = migração incompleta. As validações de
runtime redundantes em `ConversationModel:676-780` que virarem comparação de
tipo podem ser simplificadas (não removidas: a revalidação trace↔patch↔file é
lei do C15/C16).

### F1.3 `requireSchema()` (commit 11)

9 blocos idênticos de schema-guard (~100 linhas) em
`AtlasCodeWeek/Violations/Graph(×2)/Ask/Mirror/Workspace/Heals` +
`AtlasChangeReview`:

```swift
extension KeyedDecodingContainer {
    /// Fail-closed: schema desconhecido derruba o decode inteiro (lei do repo).
    func requireSchema(_ expected: String, forKey key: Key) throws { … }
}
```

**Prova:** checks de "schema desconhecido falha fechado" continuam verdes.

### F1.4 `LoadPhase` (commit 12)

Fase triplicada em `AutonomosModel.swift:10-19`, `AtlasCodeModel.swift:7-13`,
`AtlasCodeAskModel.swift:17-24` (rule of three cumprido):

```swift
enum LoadPhase: Equatable { case idle, loading, loaded, failed(String) }
```

Extrair para arquivo compartilhado da casca (é estado de apresentação — pode
viver em `App/Atlas/LoadPhase.swift`). `ConversationModel` fica FORA
(estado mais rico, não force-fit).

---

## F2 · HOT PATH SOTA

### F2-core (Sources/)

**F2.1 SSE sem gordura (commit 13)** — `AtlasClient.swift`:
- Delimitadores como `static let` (hoje `Data("\n\n".utf8)` alocado por
  chamada em `firstDelimiter`, :509-518).
- Drain por cursor de índice: substituir `buffer.removeSubrange` por frame
  (:489-495) por um offset consumido, compactando o buffer uma vez por
  `didReceive` — mata o O(M²) de burst/replay de reconnect.
- Fatiar `Data` direto (achar a linha `data:` nos bytes) e alimentar a fatia
  no decoder — eliminar o round-trip Data→String→components→trim→join→Data
  (:504-507 + `AtlasAiStream.swift:104-105`).
- **Um** `JSONDecoder` reutilizado como propriedade do delegate (hoje um novo
  por frame).
- **TDD obrigatório:** ANTES de trocar a implementação, escrever um check de
  equivalência bytes-vs-string sobre o corpus de frames dos checks existentes
  (red→green). Os golden checks de framing são a rede de segurança.

**F2.2 `JSONValue` sem cascata de erros (commit 14)** — `JSONValue.swift:16-26`:
a cascata `try?` bool→double→string→array→object aloca e descarta até 4
`DecodingError` por nó de objeto. Trocar por ponte `JSONSerialization`
(parse C único) preservando a API pública e o comportamento (incluindo o
quirk `[]`-como-bag-vazio do Laravel em `JSONObject`). Checks byte-a-byte
existentes devem continuar verdes.

**F2.3 Poll incremental (commit 15)** — `InteractionRun.swift:368-385` +
`AtlasAgentActivity.swift:191-223`: o poll de 1.3s re-decodifica o ledger
inteiro e crescente e `atlasAgentTimeline` reconstrói O(E²). Corrigir:
(a) cachear a timeline projetada e mergear só eventos com
`sequence > lastProjected`; (b) índice `[String: Int]` por id no merge em vez
de `firstIndex(where:)`. Check novo: ledger sintético de 500 eventos com
contagem de projeções ≤ bound determinístico.

**F2.4 Datas rápidas (commit 16)** — `AtlasTime.swift:21-31` +
`Merge.swift:53,69-73` (se Merge sobreviver a F0.4): fast-path de parse epoch
manual para ISO plain (sem fração) antes do `FormatStyle`, eliminando o erro
lançado+capturado por timestamp. Se F0.4 deletar Merge, aplicar só no
`AtlasTime` (que continua usado por decodes).

**F2.5 Metadata verbatim + bug snake/camel (commit 17)** — `AtlasJSON.swift:48-51`:
a estratégia snake→camel também converte chaves de `[String: JSONValue]`
(bags), custando CPU e criando divergência com o caminho SSE (que decoda puro):
`metadata["item_id"]` pode retornar nil em replay/snapshot
(`AtlasAgentActivity.swift:55,107,149`). **ATENÇÃO: existe uma sessão paralela
já trabalhando neste fix (task "Verificar divergência snake/camel").** Antes
de implementar: `git log --oneline -20` e grep por um check com `item_id` em
snapshot — se o fix já entrou, pule; senão, implemente: decode de `JSONObject`
com chaves verbatim + golden check (snapshot com `item_id` → projeção da tool
encontrada).

**F2.6 Miudezas de uma linha (commit 18):**
- `AtlasMarkdown.swift:203`: `isBlockStart` compila regex por linha — reusar o
  `headingRE` estático (:119).
- `AtlasMarkdown.swift:125-131`: `s as NSString` por chamada — fazer uma vez.
- `RichInputEngine.swift:53-60` (`FileByteSource`): um `FileHandle` aberto por
  upload em vez de open/seek/close por chunk.
- `AtlasImaging.swift:112-136` (`preview`): downscale do `CGImage` já
  decodificado em vez de segundo `CGImageSourceCreateWithData`.

### F2-casca (App/Atlas/)

**F2.7 Markdown sem O(n²) no streaming (commit 19)** —
`AtlasMarkdownView.swift:11-14` re-parseia o texto acumulado INTEIRO a cada
token (`blocks` é computed no body). Política: enquanto `bubble.streaming`,
memoizar `blocks` por `(bubble.id, text.count)` com throttle (re-parse no
máximo a cada ~100ms ou em fronteira de bloco); parse completo único no
finalize. É a correção de fluidez mais importante do app.

**F2.8 Scroll coalescido (commit 19, mesmo)** — `ConversationView.swift:232-234`
dispara `withAnimation(scrollTo)` a cada mutação de `bubbles` (= cada token).
Coalescer: só reanimar se >100ms desde a última ou se `bubbles.count` mudou.

**F2.9 Grafo lazy (commit 20)** — `AtlasCodeView.swift:211-216`: `VStack` →
`LazyVStack` (mata a materialização de ~200 rows + as ~200 animações
simultâneas do dim em :225,497-498). Uma palavra, ganho enorme.

**F2.10 Bolha viva estável (commit 20)** — `ConversationView.swift:163-192`:
`EditorialTurn` vira `Equatable` (+ `.equatable()`), closures estáveis —
o subtree da bolha em streaming re-difa só o que muda.

---

## F3 · FATIAR OS MONOLITOS

> Pré-requisito: F4.1 (A11yID) ANTES dos splits — os XCUITests dependem de
> identifiers que não podem quebrar em silêncio.

**F3.1 `ChangeReviewModel` (commit 22)** — extrair de `ConversationModel`
(1.094 linhas) o domínio review+governança (~300 linhas: `changeReviewsByTrace`,
`governanceByTrace`, `changeReviewDiffsByKey`, refresh/apply/applyFile, e o
`refreshGovernance`) para `App/Atlas/ChangeReviewModel.swift` — mesmo padrão
@Observable do domínio Código (um model por preocupação). `ConversationModel`
mantém só o gatilho de abertura. Meta: ConversationModel < 800 linhas.

**F3.2 Splitar `AtlasCodeView.swift` (1.038 linhas, commit 23)** — extrair
para arquivos próprios: `AtlasCodeProvenanceSheet` (~280),
`AtlasCodeHealReceiptSheet` (~85), `AtlasCodeCommitRow` (~100),
`AtlasCodePalette`+helpers. **Meta: nenhum arquivo > 400, nenhuma struct
View > ~200** (não repetir o erro do split anterior que criou um Cockpit de 706).

**F3.3 Splitar `ConversationCockpit.swift` (706, commit 24)** — `PlanCard.swift`,
`ExecutionStateCard.swift` (+Proof), `LiveTimeline.swift`. Mesma régua.

**F3.4 Ligar os seams órfãos (commits 25–27)** — `AtlasTraceGovernance.swift`
tem C18/C19/C21 decodificados e testados com **0 refs na casca** (órfãos):
- `DiffStats` → pílula `+N −M` no cockpit durante execução (OBRA §5 já define:
  sem workspace o campo é ausente e a UI NÃO inventa número).
- `PlanRevision` → "comparar versões" no PlanCard (plano v1 arquivado, motivo
  público da mudança).
- `CouncilMember`/`councilDiverged` → painel "pareceres" na ChangeReviewSheet
  (posição pública por papel; divergência é FATO derivado de hashes, nunca
  veredito inventado).
Cada card só existe quando a fonte existe. Prova: screenshot simulador +
device com trace real que contenha os campos.

---

## F4 · ACABAMENTO DE ELITE

**F4.1 `A11yID` compartilhado (commit 21 — ANTES de F3)** — identifiers
duplicados cru entre app e UITests (`"topbar-code"`, `"code-status"`,
`"code-ask-pill"`, `"code-ask-clear"`, `"conversation-input"`, `"radar-repo-*"`…).
Criar `App/Atlas/A11yID.swift`:

```swift
enum A11yID {
    static let topbarCode = "topbar-code"
    static let codeStatus = "code-status"
    // … todos os identifiers usados por App/UITests (grep accessibilityIdentifier)
}
```

Adicionar o arquivo também ao target de UITests (via `App/project.yml`,
sources do target AtlasDeviceProof) para os testes usarem as MESMAS constantes.
`make generate` após editar project.yml.

**F4.2 `.atlasCard()` (commit 28)** — 46 `RoundedRectangle(cornerRadius:)` de
chrome de card inline. Criar ViewModifier no design system:

```swift
extension View {
    /// Chrome canônico de card: surface + borda separator + cantos 14.
    func atlasCard(cornerRadius: CGFloat = 14) -> some View { … }
}
```

Migrar os casos que são de fato o mesmo card (não forçar os divergentes).

**F4.3 Idioma (contínuo)** — comentários unificados em **português** (decisão:
o repo é soberania pessoal; commits/OBRA já são PT). Regra prática: corrija ao
tocar o arquivo, sem commit dedicado de tradução.

**F4.4 Rotas como constantes (commit 29)** — as ~40 rotas sobreviventes das
extensões do client viram `enum AtlasRoute` (ou constantes por domínio) —
melhora grep e refactor; baixo risco.

**F4.5 `TurnPayloadBuilder` (commit 30)** — `ConversationModel.swift:563-607`
monta `[String: JSONValue]` à mão (último JSON cru da casca). Criar builder
tipado no Core espelhando o `RichInputPayloadBuilder`, com golden check de
equivalência com o payload atual (fixture do payload de hoje ANTES do
refactor — red→green).

---

## F5 · N8 AGORA: PERFORMANCE COMO LEI

> Sem F5, os 10 de UI/systems são opinião. F5 roda DUAS vezes: baseline
> "antes" (logo após F0/F1, antes de F2) e prova "depois" (após F2).

**F5.1 Baselines Instruments no iPhone físico** (o preflight de device passa
desde `8f97230`): cold launch (**alvo < 400ms**), scroll da conversa durante
streaming de resposta de 40k chars (**alvo: 0 frames perdidos @120Hz** —
Instruments template "Animation Hitches"), load do grafo com 200 nós, pico de
memória durante upload de 20MB (**< 60MB incrementais**). Salvar números e
screenshots em `docs/evidence/perf-baseline/{antes,depois}/` e registrar em
OBRA §7.

**F5.2 Checks determinísticos de CONTAGEM (não de tempo — tempo flakeia):**
- parses de markdown por N tokens simulados ≤ bound;
- projeções de timeline por poll ≤ bound (F2.3);
- decoders alocados por stream == 1 (F2.1).
Instrumentar por contador injetável nos checks, nunca `Date()`.

**F5.3 Registrar N8 como gate em OBRA §2** (append): "mudança que regride um
baseline de F5.1 não commita".

**F5.4 Fechar provas físicas pendentes** — sessão de prints U1–U6/U8–U10 no
iPhone (DEVICE_PROVEN na fila §4).

---

## F6 · FUNDAÇÕES DE ESCALA (mínimo honesto)

**F6.1 Read-cache stale-while-revalidate (commits 31–32)** — hoje toda leitura
é fetch-on-appear (offline = tela vazia). Mínimo: snapshot da última leitura
por thread em Application Support (mesmo padrão atômico da outbox); ao abrir,
renderizar o snapshot COM selo de idade visível ("visto há 2h" — dado real,
lei da honestidade) e revalidar por rede. Não é sync — é cache de leitura.

**F6.2 Multi-host: NÃO construir.** Registrar em OBRA §6 a decisão e o seam
futuro (`AtlasConfig` → coleção; outbox/fila re-escopadas por conta). YAGNI.

**F6.3 Metal Graph Engine (N1): NÃO agora.** Com F2.9 (lazy) o grafo aguenta a
vertical atual. Registrar como horizonte.

---

## ORDEM MESTRA DOS COMMITS

```
 1. F0.2  poda: 4 arquivos inteiros + cascata main.swift        (−1.577 + −6 calls)
 2. F0.3  poda parcial: Decisions/Quality/ThreadsExtra          (−431)
 3. F0.4+F0.5  Models+Merge (se OK) + trio VERIFICAR            (−205 + −41)
 4. F0.6  tema morto + botão morto                              (−~10)
 5. F0.7  fontes inalcançáveis + Info.plist + cases mortos      (−144K assets)
 6. F0.8  docs: dups deletadas, links repontados, arquivamento  (−~700K docs)
 7. F1.1  AtlasTurnStatus
 8–10. F1.2  IDs tipados (Core → models → views)
11. F1.3  requireSchema()                                       (−~80)
12. F1.4  LoadPhase                                             (−~30)
    ── F5.1 BASELINE "ANTES" (registrar) ──
13. F2.1  SSE (TDD red→green)
14. F2.2  JSONValue via JSONSerialization
15. F2.3  poll incremental + check de contagem
16. F2.4  AtlasTime fast-path
17. F2.5  metadata verbatim (VERIFICAR sessão paralela primeiro)
18. F2.6  miudezas (regex/NSString/FileHandle/preview)
19. F2.7+F2.8  markdown streaming + scroll coalescido
20. F2.9+F2.10 grafo lazy + bolha equatable
    ── F5.1 PROVA "DEPOIS" (comparar; regressão = não avança) ──
21. F4.1  A11yID compartilhado (pré-requisito dos splits)
22. F3.1  ChangeReviewModel
23. F3.2  split AtlasCodeView
24. F3.3  split ConversationCockpit
25–27. F3.4  ligar DiffStats / PlanRevision / Council na casca
28. F4.2  .atlasCard()
29. F4.4  rotas constantes
30. F4.5  TurnPayloadBuilder (golden de equivalência primeiro)
31–32. F6.1  read-cache stale-while-revalidate
33. F5.3+F5.4  N8 em OBRA §2 + sessão de prints DEVICE_PROVEN
34. docs(obra): registro final §7 com todas as provas
```

Cada commit: gates verdes (§A) + linha no OBRA §7 quando fechar fase.

## DEFINITION OF DONE — o que "10/10" significa

| Eixo | Prova objetiva |
|---|---|
| Arquitetura | ConversationModel < 800; TurnStatus/IDs tipados; zero JSON cru na casca (grep `JSONValue` em App/Atlas fora dos models = 0); F6.1 entregue |
| Qualidade | 0 literais de status fora do enum; 0 schema-guard duplicado; A11yID único; nenhum `Id: String` em assinatura pública |
| Fluidez UI | 0 hitches @120Hz no streaming de 40k (Instruments, device, evidência salva); launch < 400ms |
| Saúde evolutiva | Saldo ≤ −2.500 linhas Swift; nenhum arquivo de view > 400; 0 símbolos públicos 0/0 (fora contratos §4 ativos); 0 affordance sem ação |
| Eficiência | 1 decoder por stream; poll O(T+N) com check de contagem; 0 regex compilada em loop; drain SSE por cursor |

**Fechamento:** re-executar as 5 auditorias (arquitetura, qualidade, UI,
systems, evolução) com os mesmos critérios — as notas precisam sair 10 com
evidência, não por gentileza do auditor.

## RISCOS E PLAYBOOK

1. **Deletar algo vivo** → re-grep antes de cada deleção (o HEAD avança);
   commits atômicos por cluster; gates entre cada um; `git revert` é barato.
2. **F1.2 largo** → 3 commits guiados pelo compilador; nunca "meio migrado".
3. **F2.1 quebrar SSE** → check de equivalência ANTES (red→green); live-probe
   `ATLAS_LIVE=1` após, com create→SSE→done real.
4. **Splits quebrarem XCUITest** → F4.1 primeiro; rodar `AtlasCodeFlowTests`
   após cada split.
5. **Colisão com outras sessões/lanes** → protocolo da main (§A.4); a task
   snake/camel roda em sessão paralela — verificar antes de F2.5.
6. **Instruments indisponível em CLI** → F5.1 exige Xcode + device; se
   impossível na sua sessão, registrar em OBRA §5 como pendência do operador
   com o roteiro exato — NUNCA declarar os alvos como atingidos sem medição.
