# SPEC — Próximo Patamar: as 5 verticais aprovadas (v2 — ultra-detalhada)

> **Para a IA implementadora (Grok 4.5 ou qualquer executor sem contexto prévio).**
> Autossuficiente. Hierarquia: **canon do operador > esta spec > OBRA.md
> operacional > improviso.** O repo evolui (o HEAD avança): referências por
> SÍMBOLO valem mais que número de linha — re-verifique com `rg` antes de
> editar. Pré-requisito duro: `docs/plano-sota-10-de-10.md` concluído com
> gates verdes (repo podado, IDs/status tipados, `LoadPhase` e `A11yID`
> existentes). Se algo do SOTA estiver pendente e for necessário aqui, crie
> o mínimo citando a tarefa SOTA correspondente.
>
> **Lei-mestre desta era (decisão do operador 2026-07-16):** ZERO telas
> novas. As 5 verticais APROFUNDAM superfícies existentes. Rota nova no
> `enum Route` = implementação errada (exceção única: nenhuma nesta spec —
> a tela "Rivals" aguarda decisão do operador e NÃO está aqui).
>
> **PROIBIDO implementar (congeladas/removidas):** Voice (nem microfone,
> nem contrato, nem tela "em breve"), Atlas-wide, H9 futuro fantasma, Anel
> Nativo N1–N7, Memória de critério, Share Extension, StandBy, galeria de
> artefatos, endpoint de "sessões vivas do servidor".

---

## ÍNDICE

- §A Bootstrap e protocolo (nativo + servidor)
- §B Glossário do repo (leia — o vocabulário é lei)
- §C Design system — valores canônicos para toda UI desta spec
- §D Mapa-resumo: tudo que esta spec cria/toca
- V1 Cockpit postura v1
- V2 Presença Ambiental v1 ("Proposta das 21h")
- V3 Self-Construction na casca ⭐
- V4 Artifacts & Proof (com régua)
- V5 H1 Biografia do arquivo
- §E Ordem mestra de commits · §F Definition of Done · §G Riscos

---

## §A · BOOTSTRAP E PROTOCOLO

### A.1 Antes de qualquer edição (nesta ordem)
1. Ler `OBRA.md` INTEIRO (raiz do atlas-native).
2. Ler esta spec INTEIRA.
3. Baseline verde: `git branch --show-current` == `main`;
   `swift run AtlasCoreChecks` exit 0; `cd App && make build` exit 0.
   Baseline vermelho → PARAR, registrar em OBRA §5, não construir sobre vermelho.
4. Registrar em OBRA §6 (lock `.atlas-mobile-plan.lock`: criar → editar →
   remover): "AAAA-MM-DD · Grok 4.5 executa docs/spec-proximo-patamar.md
   com autorização do operador para atravessar as lanes nesta missão."
5. Marcar a tarefa na fila §4 (IN_PROGRESS + agente + write scope).

### A.2 Gates (antes de TODO commit — sem exceção, sem `|| true`)
```bash
swift run AtlasCoreChecks && (cd App && make build) && git diff --check
```
- Wire/contrato tocado → `ATLAS_LIVE=1 ATLAS_TOKEN=… swift run AtlasCoreChecks`
- Visual tocado → screenshot simulador + XCUITest:
  `cd App && xcodebuild test -project Atlas.xcodeproj -scheme Atlas -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:AtlasDeviceProof/AtlasCodeFlowTests`
- Prova física → `cd App && make device` / `make device-proof` (rc=2 com
  iPhone bloqueado é comportamento correto do preflight, não falha sua).

### A.3 Convenções de commit e registro
- Prefixos: `feat(core)|fix(core)` (Sources) · `feat(ui)|polish(ui)` (casca)
  · `test(ios)` · `docs(obra)`. Português, 1ª linha < 72 chars, o QUÊ + POR QUÊ.
- Stage explícito `git add -- <arquivos>`; NUNCA `git add -A`; sem branch, sem merge.
- Cada vertical fechada → OBRA §7 (append) com PROVA + fila §4 → DONE.
- NÃO editar: `CLAUDE.md`/`AGENTS.md` (gerados), entradas EXISTENTES de
  §5/§7, `docs/evidence/` (só adicionar).

### A.4 Protocolo do lado servidor (`../atlas-server` — V3, V4, V5)
- Branch local `main` APENAS lá também (regra pétrea do repo-pai).
- Antes de criar endpoint/serviço: `php artisan atlas:ai:place-feature "<feature>" --json`
  (ou emular lendo os owner docs) — docs canônicos em
  `atlas-server/docs/engineering-knowledge-base/` governam.
- TDD PHPUnit red→green no padrão `tests/Feature/Ai/...`.
- Após docs/código: `atlas engineering knowledge sync --prune` e
  `atlas engineering knowledge index-code --prune`.
- Backend real: OrbStack `atlas-backend` porta 3737. Probe real contra
  instância local = prova de contrato (padrão MISSION-LOG; se 3737 servir
  versão velha, subir instância nova em porta livre e provar nela).
- **Toda resposta ao app é allowlist provider-safe:** nunca prompt, stdout,
  path absoluto, id interno de engenharia, raciocínio. Schema versionado
  `atlas.*.v1` validado fail-closed no Core.

### A.5 Leis de honestidade (valem para cada linha)
Zero dado inventado · ausência ≠ zero · nenhum botão sem ação real ·
fail-closed permanece fail-closed · notificação só com conteúdo real ·
previsão nunca vestida de fato · prova só com evidência · `device-pending`
nunca vira prova.

---

## §B · GLOSSÁRIO DO REPO (vocabulário obrigatório)

| Termo | Significado exato |
|---|---|
| **casca** | Camada SwiftUI (`App/Atlas`). Renderiza SÓ o que os models expõem. Proibido: rede, JSON, storage (o boundary check varre e falha o gate). |
| **seam** | A fronteira tipada casca⇄engine: models `@Observable` + structs públicas do AtlasCore. |
| **model** | Classe `@MainActor @Observable` (ex.: `ConversationModel`, `AutonomosModel`). Único lugar da casca autorizado a chamar o `AtlasClient`. |
| **golden check** | Asserção no executável `AtlasCoreChecks` (`check("nome", condição)`). Sai exit 1 se falhar. Toda lógica não-trivial nova DEVE deixar checks. |
| **boundary check** | Check que varre o texto-fonte da casca proibindo `URLSession/JSONDecoder/FileManager/UserDefaults/...` fora dos models donos. |
| **live-probe** | Check opt-in (`ATLAS_LIVE=1`) contra o atlas-server real. |
| **trace** | A execução de um turno no servidor (`AtlasAiTrace`); tudo do turno resolve por `traceId`. |
| **presença** | `AtlasExecutionPresence` — projeção tipada {fase pública, timing running/paused/finished, `elapsedActiveMilliseconds`, `runningSince`}. O ÚNICO relógio permitido em qualquer superfície. |
| **provider-safe** | Sanitizado por allowlist no servidor: sem prompt/stdout/path/raciocínio/ids internos. |
| **fail-closed** | Contrato versionado com schema desconhecido/inválido → decode retorna nil/erro; a UI mostra ausência, nunca um palpite. |
| **recibo** | Registro imutável de um ato (heal, decisão, transferência) que a UI apresenta como fato; a UI só muda estado APÓS o recibo. |
| **entrega comprovada** | Ciclo Autônomos com `outcome=merged` + `merge_performed=true` + `merge_hash`. Nada menos que isso vira "entrega". |
| **estado por exceção** | Saudável = silêncio absoluto. Seções/badges só materializam quando há sinal real. |

---

## §C · DESIGN SYSTEM — valores canônicos (use EXATAMENTE estes)

Fontes da verdade: `App/Atlas/AtlasTheme.swift`, `AtlasType.swift`,
`AtlasMotion.swift`. NÃO criar cor/tamanho/curva fora deles.

**Cores (`AtlasTheme.`):** `bg #1D2B34` (canvas) · `bgRecessed #15212A` ·
`surface #243743` (cards) · `surfaceHi #2D4351` · `separator #313F47` ·
`separatorSoft #27353E` · `textPrimary #D6DDE2` · `textSecondary #95A3AC` ·
`textTertiary #677482` · `accent #D4A85A` (atlas gold) · `goldVeil` (gold
@0.10) · `goldBorder` (gold @0.34) · `prussian #7FA7C4` ·
`domOperacional #9B7A3F` · `domAutonomos #6FA06A`. Dark-only. Cores do
domínio Código: `AtlasCodePalette` (`onMain`=accent · `alert #E08C8C` ·
`healed #83B46D` · `history #647682`) — cor codifica ESTADO, nunca autor.

**Tipografia (`AtlasFont.`):** `serif(size, .semibold)` = Fraunces (títulos,
manchetes) · `serifItalic(size)` = voz do sistema/citações (a frase do
operador SEMPRE em serifItalic) · `mono(size)` = hash/recibo/meta
(JetBrains Mono) · corpo/listas = SF via `.font(.system(...))`. Escala
típica: masthead 24 · manchete 22 · métrica 21 · seção 18 · corpo 15-16 ·
citação 13-16 italic · meta/hash 9-12 mono. Headers de seção da home: mono
pequeno, tracking largo, `textTertiary`, MAIÚSCULAS. Dynamic Type é
automático via `relativeTo` embutido — nunca use `Font.custom` direto.

**Motion (`AtlasMotion.`):** `editorial` (timingCurve 0.22,1,0.36,1 ·
0.32s) = transição padrão · `arrival` (spring response 0.42, damping 0.82)
= entrada de card · `breath()` = respiração de streaming ·
`BreathingDiamond` = losango gold pulsante (já respeita Reduce Motion) ·
`PressableScale` = ButtonStyle de tato. **TODA animação nova**: ler
`@Environment(\.accessibilityReduceMotion)` e passar
`reduceMotion ? nil : animação`.

**Haptics:** `.soft` navegação · `.medium` ação de peso ·
`UINotificationFeedbackGenerator().notificationOccurred(.success)` fecha
ciclo. **Acessibilidade:** todo card composto =
`accessibilityElement(children: .combine)` + label honesto; decorativo =
`accessibilityHidden(true)`; todo elemento dirigível por teste = id no
`enum A11yID` (compartilhado com UITests — criado na SOTA F4.1).

**Régua de arquivo:** view nova < 250 linhas por arquivo, uma
responsabilidade. Estados vazio/erro/carregando são feature, não
afterthought — todo componente novo desta spec DECLARA os três.

---

## §D · MAPA-RESUMO — tudo que esta spec cria ou toca

### Arquivos NOVOS
| Arquivo | Vertical | Camada | Régua |
|---|---|---|---|
| `App/Atlas/LiveNowSection.swift` | V1 | casca | <200 ln |
| `Sources/AtlasCore/AtlasDayRhythm.swift` | V2 | core | ~150 ln |
| `Sources/AtlasCoreChecks/AtlasDayRhythmChecks.swift` | V2 | checks | — |
| `App/Atlas/NightlyProposal.swift` | V2 | casca | <250 ln |
| `Sources/AtlasCore/AtlasTraceArtifacts.swift` | V4 | core | ~180 ln |
| `Sources/AtlasCoreChecks/AtlasTraceArtifactsChecks.swift` | V4 | checks | — |
| `App/Atlas/ArtifactSheet.swift` | V4 | casca | <250 ln |
| `App/Atlas/SelfConstructionReceiptSheet.swift` | V3 | casca | <250 ln |
| `Sources/AtlasCore/AtlasCodeWhy.swift` | V5 | core | ~120 ln |
| `Sources/AtlasCoreChecks/AtlasCodeWhyChecks.swift` | V5 | checks | — |
| `App/Atlas/AtlasCodeWhySheet.swift` | V5 | casca | <250 ln |
| (server) `app/Console/Commands/AtlasNativeConstitutionScan.php` + service + testes | V3 | server | — |
| (server) rotas/controllers artifacts + why + testes | V4/V5 | server | — |

### Arquivos EXISTENTES tocados
| Arquivo | Vertical | Mudança |
|---|---|---|
| `App/Atlas/TurnPresence.swift` | V1 | + `LiveSessionSnapshot` + `liveSessions` (leitura de seams; zero lógica de model) |
| `App/Atlas/RootView.swift` | V1 | + `LiveNowSection()` acima de CONVERSAS (1 linha + import) |
| `App/Atlas/ConversationView.swift` | V1 | `watch(...)` passa `threadId` |
| `App/Atlas/AtlasSession.swift` + `ConversationModel.swift` | V2 | +1 linha cada: `recordActivity` (autorizado §6) |
| `App/Atlas/AtlasApp.swift` | V2 | delegate de notificação (roteia tap) |
| `App/Atlas/AutonomosView.swift` | V2, V3 | card da proposta noturna · seção self-construction |
| `App/Atlas/ConversationCockpit.swift` (ExecutionProof) | V4 | linha "ARTEFATOS (N)" |
| `App/Atlas/ConversationModel.swift` (ou ChangeReviewModel pós-SOTA) | V4 | `artifactsByTrace` + refresh/content |
| `App/Atlas/AtlasCodeView.swift` (ProvenanceSheet/FileRow — pós-split SOTA) | V5 | toque no arquivo → WhySheet |
| `App/Atlas/A11yID.swift` | todas | novos identifiers |
| `Sources/AtlasCoreChecks/main.swift` | V2,V4,V5 | chamadas dos novos checks |

### Contratos novos de servidor (visão única)
| Endpoint | Schema | Vertical |
|---|---|---|
| `GET /ai/interactions/{trace}/artifacts` | `atlas.trace_artifacts.v1` | V4 |
| `GET /ai/interactions/{trace}/artifacts/{id}/content` | bytes + headers | V4 |
| `GET /api/code/why` | `atlas.code.why.v1` | V5 |
| `php artisan atlas:native:constitution-scan` (+ findings no backlog existente) | reusa contratos Autônomos | V3 |

Ordem de execução: **V1 → V2 → V4 → V3 → V5** (V4 antes de V3: o recibo de
auto-construção reusa a renderização de artefato/diff de V4).

---

# V1 · COCKPIT POSTURA v1 — a home que se reorganiza

## V1.0 Ficha
- **Tese:** o cockpit não é tela — é o que a home VIRA quando há trabalho
  vivo. **Camadas:** casca pura. **Contratos novos:** ZERO. **Tamanho:** P.
- **Dependências:** nenhuma. **Prova:** simulador + device + XCUITest.

## V1.1 Leis da vertical
1. Nada vivo → home **byte-igual** à atual (prova: screenshot antes/depois
   idênticos no estado ocioso).
2. "VIVO AGORA" só materializa com ≥1 sessão viva; some com a última.
3. Relógio: SÓ `elapsedActiveMilliseconds`/`runningSince`/`timing` da
   presença tipada (regra idêntica ao Widget: paused congela `‖ m:ss`;
   espera não conta tempo). PROIBIDO `Timer` local contando sozinho.
4. v1 mostra o que o app SABE: sessões seguidas pelo `TurnPresence` neste
   processo. Sessão iniciada noutra superfície e nunca aberta aqui NÃO
   aparece — honestidade, não bug (não criar endpoint).

## V1.2 Estado atual (verifique com rg antes de editar)
- `TurnPresence` (`App/Atlas/TurnPresence.swift`): singleton
  `@Observable @MainActor`; `watch(_:threadTitle:)` chamado no `onAppear`
  da ConversationView; entries com weak model; observa via
  `withObservationTracking` os seams `currentExecutionPresenceTraceId`,
  `phaseTitle`, `timing` (re-armado a cada mudança); publica
  `runningTitles: Set<String>` (usado pelo ◆ da `ThreadRow`); dispara
  notificação local em fase terminal; dirige Live Activities.
- `RootView`: `NavigationStack(path:)` + `enum Route`; seções da home:
  CONVERSAS → OPERAÇÃO (Autônomos) → WORKSPACES; deep link
  `atlas://execution/<trace>` já resolve trace→thread.

## V1.3 Máquina de estados da linha viva
```
(entry criada no watch)               timing==.finished
  running ── phase muda ──> running' ────────────────> finished (linha vira
     │                                                  "✓ concluído")
     │ timing==.paused                                       │ TurnPresence
     v                                                       │ remove entry
  paused (relógio congelado ‖ m:ss)                          v
     │ timing==.running                                   (linha sai —
     └────────────> running                                animação editorial)
```
A linha NUNCA decide sozinha sair: ela espelha as entries do TurnPresence
(que já implementa a regra C14 de fim só por fase terminal pública).

## V1.4 Mudança no TurnPresence (T1.1)
Adicionar (sem tocar na lógica existente de Activities/notificação):
```swift
struct LiveSessionSnapshot: Identifiable, Equatable {
    let id: String            // traceId corrente (estável por execução)
    let threadId: String?     // para Route.thread; nil se conversa nova local
    let title: String         // threadTitle já recebido no watch
    let phaseTitle: String    // fase pública tipada
    let timing: AtlasExecutionPresence.Timing
    let elapsedActiveMs: Int?
    let runningSince: Date?
    let startedAt: Date       // 1ª observação local (só para ORDENAÇÃO — nunca exibido como duração)
}
private(set) var liveSessions: [LiveSessionSnapshot] = []   // ordenada por startedAt
```
- `watch(_ model:, threadTitle:, threadId:)` ganha o parâmetro `threadId`
  (ConversationView já o conhece; conversa nova → nil até a thread canônica
  existir — quando o model migrar `local:`→`thread:`, o snapshot atualiza).
- O closure de observação existente passa a TAMBÉM reconstruir o snapshot da
  entry e publicar `liveSessions` (mutação em `@MainActor`, é o notify do
  @Observable). Entry removida → snapshot sai do array.
- `runningTitles` continua idêntico (o ◆ não muda).

## V1.5 LiveNowSection (T1.2) — wireframe e spec
```
┌─────────────────────────────────────────────┐
│ VIVO AGORA                                  │  mono 11, tracking largo,
│                                             │  textTertiary, MAIÚSCULAS
│ ◆ Refatorar o parser SSE                    │  ◆=BreathingDiamond (anima só
│   Executando comando · 2:41                 │   se timing==.running e
│                                             │   !reduceMotion)
│ ◆ Auditoria do radar                        │  título: serif(16,.semibold)
│   Aguardando decisão · ‖ 0:58               │  fase+relógio: serifItalic(13)
└─────────────────────────────────────────────┘   textSecondary
```
- Container: `.atlasCard()` (modifier da SOTA F4.2; se não existir, criar
  citando F4.2: surface + borda separator + cantos 14).
- Relógio: `timing==.running` → `elapsedActiveMs` + (now − runningSince)
  renderizado por `TimelineView(.periodic(by: 1))` LOCAL À LINHA (1 Hz só
  enquanto a seção existe — mesmo padrão do cronômetro do cockpit);
  `paused` → `‖` + acumulado congelado (sem TimelineView); `finished` → "✓
  concluído" sem relógio.
- Tap → haptic `.soft` + `path.append(Route.thread(id:title:))`; sem
  `threadId` → linha não-navegável (sem chevron, sem ação — botão falso é
  proibido).
- Transições: inserção/remoção com `AtlasMotion.arrival`/`editorial`,
  `reduceMotion ? nil : ...`.
- A11y: `A11yID.liveNowSection`, `A11yID.liveNowRow(index:)`; cada linha
  `.combine` com label "<título>, <fase>, em execução há <m:ss>" (paused:
  "pausado em <m:ss>"; finished: "concluído").
- Estados: a seção NÃO tem estado vazio/erro — ela simplesmente não existe
  sem sessões (lei 2).

## V1.6 Integração na home (T1.2)
Em `RootView`, acima da seção CONVERSAS:
```swift
if !TurnPresence.shared.liveSessions.isEmpty {
    LiveNowSection(sessions: TurnPresence.shared.liveSessions,
                   onOpen: { path.append(Route.thread(id: $0, title: $1)) })
}
```

## V1.7 Edge cases (todos devem ser tratados/decididos)
| Caso | Comportamento |
|---|---|
| Mesma thread aberta 2× | Uma entry por conversa observada; dedup por `id` (traceId) no array |
| Sessão pausada horas | Linha permanece com ‖ congelado (isOngoing inclui paused — regra C14) |
| App relançado com turno vivo no servidor | v1 NÃO mostra até a conversa ser aberta (lei 4) — sem exceção |
| Conversa nova (thread ainda local) | título provisório; sem navegação até threadId canônico |
| 5+ sessões | lista cresce; sem cap na v1 (LazyVStack da home já é lazy) |
| Reduce Motion | diamond estático; transições nil |
| Dynamic Type AXXXL | linhas quebram em 2; relógio nunca trunca o título (layout priority no título) |

## V1.8 Prova (T1.3)
1. **XCUITest** (`AtlasDeviceProofTests` estilo): enviar turno real
   (`hermes_cli`, comando `sleep 8 && pwd` — padrão DeviceProof), voltar à
   home, exigir `A11yID.liveNowSection` visível com fase não-vazia; esperar
   conclusão; exigir seção AUSENTE. `XCTFail` explícito se a seção existir
   sem sessão (nunca guard-return silencioso).
2. **Screenshots**: home ociosa (comparar com screenshot pré-mudança —
   idênticos) + home com 2 sessões (2 conversas com turnos simultâneos) →
   `docs/evidence/<data>-cockpit-v1/01-idle.png, 02-live-2-sessions.png`.
3. Gates + boundary check verdes. Device físico: `make device` + prints.

Commits V1: `feat(ui): a home vira cockpit quando há trabalho vivo` ·
`test(ios): a home só mostra o que está vivo — e prova` · registro §7.

---

# V2 · PRESENÇA AMBIENTAL v1 — "A Proposta das 21h"

## V2.0 Ficha
- **Tese:** o app aprende on-device o ritmo do operador e propõe pôr a
  frota para trabalhar à noite sobre o que ele tocou hoje; a manhã convida
  a ver o resultado. **Camadas:** core (rhythm) + casca (proposta). **Contratos
  novos de servidor:** ZERO (aceite usa `startRun` existente). **Tamanho:** P/M.

## V2.1 Leis da vertical
1. Sinal físico NUNCA sai do aparelho (nem em log). O servidor só recebe a
   missão aceita pelo contrato existente.
2. Proposta é proposta: nada roda sem toque; aceite → fluxo governado
   existente (`AutonomosReasonSheet` com ator+motivo; `dry_run` default).
3. UMA notificação por noite; ignorada = silêncio total até a próxima janela.
4. Sem atividade hoje OU < 4 dias de amostra → proposta NÃO existe.
5. Manhã só após noite ACEITA, e a notificação da manhã NÃO carrega números
   (o app não sabe offline o que a frota produziu) — convida a abrir a
   superfície que carrega dados reais. Quando o servidor entregar C19
   (digest), a manhã cita o headline real; até lá, não inventa.

## V2.2 AtlasDayRhythm (T2.1) — Core, espec completa
Por que no Core: boundary check proíbe FileManager na casca; e a lógica de
janela é pura/testável → golden checks.
```swift
public actor AtlasDayRhythm {
    public struct Windows: Sendable, Equatable {
        public let dayEnd: DateComponents?     // hour+minute medianos (últimos 7 dias com amostra)
        public let dayStart: DateComponents?
        public let sampleDays: Int             // dias distintos com amostra na janela de 14 dias
    }
    public struct DaySummary: Sendable, Equatable {
        public let workspaces: [String]        // tocados HOJE (nomes já provider-safe: lastPathComponent)
    }
    public init(storeURL: URL? = nil)          // default: Application Support/AtlasNative/day-rhythm.v1.json
    public func recordActivity(workspace: String?, now: Date = .init()) async
    public func windows(minimumDays: Int = 4, now: Date = .init()) async -> Windows
    public func todaySummary(now: Date = .init()) async -> DaySummary
    public func reset() async                  // para testes/seed
}
```
**Regras internas (cada uma vira golden check):**
- Persistência: JSON atômico (padrão `InteractionOutbox`), schema
  `{"v":1,"days":[{"date":"2026-07-16","first":"08:12","last":"21:03","workspaces":["atlas-native"]}]}`,
  cap de 14 dias (poda no persist).
- `recordActivity`: atualiza first/last do dia LOCAL (`Calendar.current`),
  agrega workspace (dedup).
- Mediana: sobre os `min(sampleDays,7)` dias mais recentes com amostra;
  minutos-desde-meia-noite; empate par → média dos centrais.
- Cold start: `sampleDays < minimumDays` → `dayEnd/dayStart = nil`.
- Fuso: tudo em hora local corrente; mudança de fuso não lança (check).

**Golden checks (`AtlasDayRhythmChecks.swift`, registrar em `main.swift`):**
`rhythm_median_7days` · `rhythm_cold_start_nil` · `rhythm_ignores_empty_days`
· `rhythm_today_workspaces_dedup` · `rhythm_persistence_roundtrip` ·
`rhythm_cap_14_days` · `rhythm_timezone_change_safe` ·
`rhythm_windows_minutes_to_components`.

## V2.3 Pontos de registro (T2.2 — models, 1 linha cada, autorizado §6)
- `AtlasSession.loadThreads()` (sucesso) →
  `Task { await Self.rhythm.recordActivity(workspace: nil) }`
- `ConversationModel.send(...)` (após aceitar o envio) →
  `Task { await AtlasSession.rhythm.recordActivity(workspace: self.workspace) }`
- `AtlasSession` ganha `static let rhythm = AtlasDayRhythm()` (instância única).
Nenhuma outra lógica entra nos models.

## V2.4 NightlyProposal (T2.3) — casca, espec completa
`App/Atlas/NightlyProposal.swift` — `@MainActor @Observable final class
NightlyProposalController` (singleton `.shared`, padrão TurnPresence) +
`NightlyProposalCard: View`.

**Agendamento (dirigido por `scenePhase`):** `AtlasApp` observa
`\.scenePhase`; ao entrar `.background`:
1. `windows(minimumDays: 4)`; `dayEnd == nil` → remove pendentes
   (`removePendingNotificationRequests(withIdentifiers: ["atlas.nightly","atlas.morning"])`) e sai.
2. `todaySummary()`; `workspaces.isEmpty` → remove "atlas.nightly" e sai (lei 4).
3. Agenda `UNCalendarNotificationTrigger(dateMatching: dayEnd, repeats: false)`
   id `"atlas.nightly"` (substitui a anterior — 1/noite):
   - title: `"A frota pode trabalhar esta noite"`
   - body: `"Hoje você mexeu em <join(workspaces, ", ")>. Quer pôr os Autônomos nisso enquanto descansa?"`
   - userInfo: `["atlas.route": "autonomos-nightly"]`
   - Se a janela de hoje já passou (app foi pra background depois de 21h) →
     agendar para AGORA + 60s apenas se ainda não disparou hoje (flag local
     no controller); senão, próxima noite.
4. Permissão: reusar o padrão do TurnPresence (pedida no 1º turno concluído);
   sem permissão → não agenda, não insiste.

**Roteamento do tap:** `AtlasApp` instala
`UNUserNotificationCenter.current().delegate = NightlyProposalController.shared`;
`didReceive response` com `atlas.route == "autonomos-nightly"` →
`pendingProposal = ProposalPayload(workspaces:)` + navegar `Route.autonomos`
(via callback registrado pelo RootView no `onAppear` — mesmo mecanismo do
deep link existente).

**Card na AutonomosView (topo, só com `pendingProposal != nil`):**
```
┌─────────────────────────────────────────────┐
│ MISSÃO NOTURNA · proposta das 21h           │ mono 11 tracking textTertiary
│ Hoje você trabalhou em atlas-native.        │ serif(16)
│ A frota pode continuar enquanto você        │ serifItalic(14) textSecondary
│ descansa.                                   │
│ [ Preparar missão noturna ]      [ hoje não ]│ accent capsule · textTertiary
└─────────────────────────────────────────────┘
```
- "Preparar missão noturna" → abre o `AutonomosReasonSheet` EXISTENTE com
  motivo pré-preenchido `"missão noturna proposta às <HH:mm real> — foco: <workspaces>"`,
  ator vazio (operador preenche — lei do fluxo), default visual `dry_run`.
  Aceite segue `model.startRun(...)` existente; recibo `enqueued` = "na
  fila · ainda não iniciado" (componente existente). Após aceite → agendar
  manhã (abaixo) + `pendingProposal = nil`.
- "hoje não" → `pendingProposal = nil`, sem re-alerta (lei 3).
- A11y: `A11yID.nightlyProposalCard/Accept/Dismiss`.

**Manhã:** no aceite, agendar id `"atlas.morning"` para `dayStart` do dia
seguinte: title `"A frota trabalhou esta noite"`, body
`"Veja as entregas comprovadas."` (SEM números — lei 5), route
`"autonomos"`. Tap → `Route.autonomos` (a tela carrega `model.delivered`
real). Sem aceite → nunca agendar.

## V2.5 Edge cases
| Caso | Comportamento |
|---|---|
| < 4 dias de amostra | silêncio (sem proposta) |
| Dia sem atividade | silêncio |
| Permissão de notificação negada | nada agendado; sem prompt repetido |
| Background após a janela | dispara 1× com atraso OU adia p/ amanhã (flag "já propôs hoje") |
| 2 backgrounds na mesma noite | id fixo substitui — continua 1 proposta |
| Aceite mas `startRun` falha | erro do model exibido (padrão publicMessage); manhã NÃO agendada |
| Mudança de fuso | janelas recalculadas em hora local (check do Core) |
| App morto à noite | notificação local dispara mesmo assim (UNCalendar é do SO) |

## V2.6 Prova (T2.4)
1. Golden checks do rhythm verdes (offline).
2. Simulador: semear o arquivo do rhythm (via `storeURL` de teste +
   pequeno harness nos checks OU seed manual documentado) → screenshot do
   card, do sheet pré-preenchido, do recibo "na fila".
3. Device físico: seed com horários reais do operador (documentar o seed em
   §7 — seed é conveniência de TESTE; o conteúdo continua derivado de
   atividade real) → foto da notificação na Lock Screen, do card, e da
   manhã. `docs/evidence/<data>-nightly/01..04.png`.
4. XCUITest: com `pendingProposal` injetado (launch argument
   `-atlas.nightly.demo 1` lido SÓ em DEBUG), o card existe, o aceite abre
   o sheet com motivo pré-preenchido, o dismiss silencia. (Launch argument
   de demo é aceitável para teste de UI; NUNCA em release build —
   `#if DEBUG`.)

Commits V2: `feat(core): o app aprende o ritmo do dia — mediana local,
cold start honesto` · `feat(core): models registram atividade (1 linha,
missão §6)` · `feat(ui): a proposta das 21h — a noite trabalha, você
descansa` · `test(ios)+docs(obra)`.

---

# V3 · SELF-CONSTRUCTION NA CASCA ⭐ — o app que melhora o próprio app

## V3.0 Ficha
- **Tese:** apontar o motor 24/7 existente (scanner→backlog→loop→gates→
  recibo→veto) para o PRÓPRIO atlas-native. v1: a constituição do OBRA §3
  vira scanner executável; agentes curam; o app exibe "o Atlas melhorou o
  próprio app" com recibo. **Camadas:** server (scanner+área) + casca
  (superfície). **Tamanho:** M. **Depende de:** V4 (renderização de diff/artefato
  no recibo) e contratos Autônomos existentes (areas/backlog/cycles/delivered/decide).

## V3.1 Leis da vertical
1. Nenhuma mudança sem gate: entrega = ciclo com `outcome=merged` +
   `merge_performed` + `merge_hash` + integridade de checks/build (campos
   que o contrato de cycles JÁ carrega). `model.delivered` já filtra isso —
   NÃO afrouxar.
2. `observe|heal` por categoria: `heal` SÓ para o mecânico provável por
   gate (R2/R3/R4/R5 abaixo); R1 (estrutura/produto) nasce `observe` →
   decisão do operador pelo fluxo `decide` existente (AP-724: decisão
   registrada ≠ executada — apresentar exatamente assim).
3. Veto retroativo, nunca portão: o recibo mostra o commit real; botão de
   veto SÓ existe se o contrato fornecer o dado de undo. Sem contrato →
   linha honesta "reversível por missão — registre um pedido" SEM botão.
   (Se necessário, abrir pedido em OBRA §5 por um contrato de revert de
   ciclo — NÃO inventá-lo nesta spec.)
4. Todo finding carrega: regra citada (id + texto humano), evidência
   (arquivo, contagem, medida) e severidade. Finding sem evidência não nasce.

## V3.2 Scanner da constituição (T3.1 — servidor)
Comando `php artisan atlas:native:constitution-scan
--repo=/Users/vitorepf/develop/Atlas/atlas-native [--json] [--file-findings]`.
Precedente direto: `AtlasCodeViolationService` (C24) — função pura sobre
snapshot + testes com repo sintético. Estrutura: service puro
`AtlasNativeConstitutionScanner` + comando fino.

**Regras v1 (id · detecção · categoria · política):**
| id | Detecção (determinística) | Severidade | Política |
|---|---|---|---|
| `R1 file_over_limit` | `wc -l`: view em App/Atlas > 400 OU arquivo Sources > 500 | media | **observe** |
| `R2 dead_symbol` | tipo/método `public` de AtlasCore com 0 refs em App/ e 0 em Sources fora do próprio arquivo (excluir Checks; excluir sub-structs de resposta Codable — allowlist de raízes de resposta para não matar tipo estrutural) | media | **heal** |
| `R3 warning_regression` | `xcodebuild build` conta warnings > baseline registrado (arquivo de baseline no repo: `docs/evidence/perf-baseline/warnings.txt`) | alta | **heal** |
| `R4 check_count_regression` | total impresso pelo `AtlasCoreChecks` < baseline | alta | **heal** |
| `R5 dead_theme_token` | token `AtlasTheme.` com 0 usos fora da definição | baixa | **heal** |

**Saída:** findings no formato do backlog Autônomos EXISTENTE (hash estável
= sha1(rule+alvo), título público humano — ex.: "R2: AtlasFoo.bar sem
consumidor há N dias", risco, rota) gravados pela mesma via que o
stewardship/loop já usa para findings (reusar o serviço/tabela existente —
`place-feature` dirá o owner exato; NÃO criar tabela nova).
**Área:** garantir a área Autônomos `atlas-native` registrada com
`repo_scope` apontando para o repo (config/registro pela via existente de
áreas; se exigir migration de config, é config, não contrato novo).
**Política:** mapear R→observe/heal na config da área (a máquina de política
por regra já existe no C25 — reusar o padrão).

**PHPUnit (red→green), casos mínimos:** repo sintético com view de 500
linhas → R1 observe; símbolo público órfão plantado → R2 heal; baseline de
warnings 0 + warning plantado → R3; baseline de checks N + check removido →
R4; token morto plantado → R5; repo limpo → zero findings (silêncio);
finding idempotente (2 scans → 1 finding, mesmo hash).

## V3.3 Superfície na casca (T3.2)
ZERO tela nova. Em `AutonomosView`:
- Detectar a área self: `area.repositoryNames.contains("atlas-native")`
  (dado público existente).
- Na seção de entregas comprovadas quando a área é self: header vira
  `"O ATLAS MELHOROU O PRÓPRIO APP"` (mono tracking, `domAutonomos`);
  cada entrega abre `SelfConstructionReceiptSheet`.

**`SelfConstructionReceiptSheet.swift` — wireframe:**
```
┌─────────────────────────────────────────────┐
│ RECIBO DE AUTO-CONSTRUÇÃO                    │ mono 11 textTertiary
│ O Atlas removeu código morto do próprio app  │ serif(18) — título público
│                                              │   do ciclo (real)
│ Regra citada                                 │
│ "§3.6 — deletar > adicionar; símbolo         │ serifItalic(14) — texto da
│  público sem consumidor não fica"            │   regra vinda do finding
│                                              │
│ Prova                                        │
│ checks ✓ 561→561 · build ✓ · merge a1b2c3d   │ mono(12) — campos de
│                                              │   integridade REAIS do ciclo
│ [ Desfazer — com recibo ]   ← só se o dado   │ alert border; AUSENTE sem
│                               de undo existir │ contrato (lei 3)
│ você não foi necessário                      │ serifItalic(13) textTertiary
└─────────────────────────────────────────────┘
```
Padrão visual: `AtlasCodeHealReceiptSheet` (E4) é o precedente — copiar a
gramática, não o arquivo. Dados: exclusivamente `model.delivered` /
`model.backlog` / recibos existentes; zero rede na View. Findings `observe`
(R1) aparecem no fluxo `decide` existente com a regra citada no corpo —
apresentar aceite como "decisão registrada, execução pendente do owner"
quando `isRecordedDecisionOnly` (regra existente).
A11y: `A11yID.selfReceiptSheet/Veto`.

## V3.4 Edge cases
| Caso | Comportamento |
|---|---|
| Scan sem findings | silêncio (nenhuma seção/badge extra) |
| Finding já corrigido antes do ciclo | loop fecha sem mudança → não vira entrega; finding some no próximo scan |
| Loop sem workspace-cert p/ o repo | parar no ponto honesto: scanner+backlog provados; registrar em §5 o bloqueio EXATO; superfície mostra backlog/decisões (real), sem entrega fabricada |
| Ciclo falha nos gates | não é entrega (delivered já filtra); aparece em ciclos com resultado honesto |
| Undo ausente no contrato | recibo SEM botão de veto + linha honesta (lei 3) |
| Área self não existe | criar via registro existente; se exigir decisão do servidor, §5 |

## V3.5 Prova fim-a-fim (T3.3 — a prova mais importante da spec)
1. Plantar violação sintética REAL (símbolo público morto num commit local);
2. `atlas:native:constitution-scan` → finding aparece (probe HTTP do
   backlog real);
3. Loop executa (dry_run primeiro; depois `execute` com operador+motivo
   REAIS do operador ou registrados como teste em §7);
4. Merge real com gates verdes → entrega comprovada;
5. App exibe em "O ATLAS MELHOROU O PRÓPRIO APP" + recibo aberto;
6. Evidência: PHPUnit verde + screenshots dos momentos 2/4/5 + hashes →
   `docs/evidence/<data>-selfconstruction/` + OBRA §7.
**Nenhum passo simulado. Se um passo não fechar, a entrega PARA no último
passo provado e o §5 registra o que falta.**

Commits V3: server (`feat: a constituição do nativo vira lei executável`)
· server config área · `feat(ui): o recibo de auto-construção — você não
foi necessário` · prova+`docs(obra)`.

---

# V4 · ARTIFACTS & PROOF — com régua (dentro das superfícies existentes)

## V4.0 Ficha
- **Tese:** artefatos do turno visíveis DENTRO do turno. **Régua do
  operador:** sem galeria, sem rota nova — sheet a partir do
  `ExecutionProof`. **Camadas:** server + core + casca. **Tamanho:** M.

## V4.1 Leis
1. Linha "ARTEFATOS (N)" só com manifesto não-vazio. Trace sem
   run/workspace → `unavailable` explícito e NADA na UI.
2. Preview só do que se renderiza com verdade: image→imagem;
   text/markdown→`AtlasMarkdownView`; diff→renderização do review
   existente; resto→ficha (nome+tamanho+sha). Preview inventado é proibido.
3. Conteúdo trace-scoped, cap de bytes, sha256 validado no Core contra o
   manifesto (divergência = erro, nunca render). A View nunca monta URL.

## V4.2 Contrato servidor (T4.1)
`GET /ai/interactions/{trace}/artifacts` → 200:
```json
{ "schema_version": "atlas.trace_artifacts.v1",
  "state": "available",
  "run": { "workspace_label": "atlas-native" },
  "items": [
    { "id": "art_9f2c", "kind": "markdown",
      "name": "relatorio-final.md", "relative_dir": "docs",
      "byte_size": 18234, "sha256": "…", "created_at": "…",
      "origin": "produced" } ] }
```
- `state: "unavailable"` + `reason: "no_workspace" | "no_run" | "multiple_runs"`
  (invariantes iguais ao C15: `available` exige `run`; `unavailable` proíbe
  `items`).
- `kind`: `image|markdown|text|diff|file` (server decide por MIME/extensão;
  na dúvida `file`).
- `origin`: `produced|modified` (dado real do run; sem certeza → `produced`
  não é permitido — omitir o item é melhor que rotular errado? NÃO: itens
  vêm do registro do run; se o registro não distingue, campo ausente e o
  Core trata como não-informado).
- Allowlist de path: `name` = lastPathComponent; `relative_dir` = no máx. 2
  níveis relativos; NUNCA path absoluto.
- `GET /ai/interactions/{trace}/artifacts/{id}/content?max_bytes=5242880` →
  200 bytes + `Content-Type` honesto + `X-Atlas-Sha256`; artefato maior que
  o cap → `413` com corpo JSON `{ "error": "too_large", "byte_size": … }`;
  id fora do trace → 404. Fonte: vínculo trace→run unívoco do C15 (zero ou
  múltiplos runs → unavailable).
**PHPUnit:** manifesto de run real; unavailable nos 3 reasons; 413; 404
cross-trace; sha do content == manifesto; path allowlist (tentativa de
absoluto/`..` no registro não vaza).

## V4.3 Core (T4.2) — `AtlasTraceArtifacts.swift`
```swift
public struct AtlasTraceArtifacts: Sendable, Equatable {  // decode fail-closed via requireSchema
    public enum State: String, Sendable { case available, unavailable }
    public struct Item: Sendable, Equatable, Identifiable {
        public enum Kind: String, Sendable { case image, markdown, text, diff, file }
        public let id: String; public let kind: Kind; public let name: String
        public let relativeDir: String?; public let byteSize: Int
        public let sha256: String; public let createdAt: Date?
    }
    public let state: State; public let reason: String?
    public let workspaceLabel: String?; public let items: [Item]
    // invariantes no init(from:): available⇒run presente; unavailable⇒items vazio
}
public struct AtlasArtifactContent: Sendable { public let data: Data; public let contentType: String }
extension AtlasClient {
    public func getTraceArtifacts(traceId: TraceID) async throws -> AtlasTraceArtifacts
    public func getTraceArtifactContent(traceId: TraceID, artifactId: String,
                                        maxBytes: Int = 5_242_880) async throws -> AtlasArtifactContent
    // valida SHA-256(data) == manifesto (o caller passa o esperado) — divergência lança artifactShaMismatch
}
```
**Golden checks (`AtlasTraceArtifactsChecks.swift`):**
`artifacts_decode_available` · `artifacts_schema_unknown_fails_closed` ·
`artifacts_invariant_unavailable_no_items` · `artifacts_kind_unknown_maps_file`
(kind aberto: valor novo → `.file`, nunca crash) · `artifacts_sha_mismatch_throws`
· `artifacts_maxbytes_in_query`.

## V4.4 Casca (T4.3)
- Model (no `ChangeReviewModel` pós-SOTA F3.1; se não existir, no
  `ConversationModel` citando F3.1): `artifactsByTrace: [TraceID: AtlasTraceArtifacts]`,
  `refreshArtifacts(traceId:)` (chamado junto do refresh do review — mesmo
  gatilho), `loadArtifactContent(traceId:item:)` com cache em memória
  pequeno (NSCache, 8 itens) das previews decodificadas.
- `ExecutionProof` (ConversationCockpit): abaixo do sumário existente,
  linha só com `items.count > 0`:
  `⎘ ARTEFATOS (3)` — mono(12), `textSecondary`, chevron; tap → sheet.
- **`ArtifactSheet.swift` — wireframe:**
```
┌─────────────────────────────────────────────┐
│ ARTEFATOS DO TURNO · atlas-native           │ mono 11 textTertiary
│ ▸ relatorio-final.md        18 KB  markdown │ linha: nome serif(15) +
│ ▸ captura-execucao.png     412 KB  imagem   │  meta mono(11) textTertiary
│ ▸ dados.bin                 2.1 MB  arquivo │
├─────────────────────────────────────────────┤
│ [preview da seleção]                        │ image→Image (decodificada 1×,
│                                             │  cache); markdown/text→
│                                             │  AtlasMarkdownView; diff→view
│                                             │  do review; file→ficha:
│                                             │  nome · tamanho · sha (mono)  │
└─────────────────────────────────────────────┘
```
- Estados DECLARADOS: carregando (BreathingDiamond) · erro (toast padrão
  `userMessage`) · `413/too_large` → ficha com "grande demais para
  visualizar aqui · <tamanho>" (sem botão de download — não existe destino
  honesto no iPhone v1).
- A11y: `A11yID.artifactsRow/Sheet/Item(index:)`; VoiceOver da linha:
  "<nome>, <tamanho legível>, <tipo>".

## V4.5 Edge cases
| Caso | Comportamento |
|---|---|
| Trace sem run/workspace | linha ausente (unavailable nunca renderiza lista) |
| sha diverge | erro do Core → toast; preview NUNCA mostrada |
| Artefato apagado entre manifesto e content | 404 → toast honesto; item permanece na lista com ficha |
| PNG gigante | cap 413 → ficha "grande demais" |
| kind novo do servidor | `.file` (ficha) — nunca crash |
| Replay/reload | manifesto refaz fetch; cache de preview por sha |

## V4.6 Prova (T4.4)
Turno real com workspace produzindo `.md` real (pedir ao agente:
"crie docs/nota-de-prova.md com o texto X") → linha aparece, preview mostra
X; turno sem workspace → linha ausente; live-probe do fluxo; XCUITest: a
linha só existe quando o manifesto tem itens; screenshots →
`docs/evidence/<data>-artifacts/`.

---

# V5 · H1 BIOGRAFIA DO ARQUIVO — blame semântico

## V5.0 Ficha
- **Tese:** tocar um arquivo na proveniência responde "por que este arquivo
  existe e o que o moldou" — as frases REAIS do ledger dos commits que o
  tocaram. **Camadas:** server + core + casca. **Tamanho:** P/M.
  v1 é FILE-level; o contrato nasce com `line` opcional (servidor pode
  ignorar na v1).

## V5.1 Leis
1. Frase SÓ do ledger (join C23). Commit sem registro → `provenance: null`
   → "sem proveniência registrada". NUNCA apresentar mensagem de commit
   como intenção.
2. Recorte dito: "N de M · história truncada" quando `truncated`.
3. Regras E2.1 do locator: slug registrado vence; `..`/absoluto/`/` no
   `file` → 422; slug ambíguo → silêncio (404 sem eco de caminho).

## V5.2 Contrato servidor (T5.1)
`GET /api/code/why?repo=atlas-native&file=App/Atlas/RootView.swift&limit=20[&line=]`
→ 200:
```json
{ "schema_version": "atlas.code.why.v1",
  "repo": "atlas-native", "file": "App/Atlas/RootView.swift",
  "commits_total": 34, "truncated": true,
  "commits": [
    { "hash": "…40 chars…", "when": "2026-07-15T22:14:03Z",
      "agent": "fable", "subject": "polish(ui): a home respira",
      "provenance": { "quote": "quero a home viva, não um menu",
                      "obra": "obra-17", "gates": ["checks","build"] } },
    { "hash": "…", "when": "…", "agent": "voce", "subject": "…",
      "provenance": null } ] }
```
- Implementação: `git log --follow --format=… -n{limit} -- {file}` no repo
  resolvido pelo locator E2.1 + join provenance por hash REUSANDO o serviço
  C23 (não duplicar a lógica de ledger). `agent` pela mesma projeção E2
  (`vitordsny@gmail.com`→`voce` etc.). `subject` é a 1ª linha do commit —
  permitido como METADADO (rotulado subject), distinto da quote.
- Erros: repo desconhecido/ambíguo → 404 `{}`; `file` inválido → 422;
  arquivo sem commits → 200 com `commits: []` e `commits_total: 0`
  (ausência dita, não erro).
**PHPUnit:** arquivo real com provenance conhecida; provenance null
preservado; `--follow` sobrevive a rename (fixture com rename); traversal
`../` → 422; repo ambíguo → 404; limite/truncated corretos.

## V5.3 Core (T5.2) — `AtlasCodeWhy.swift`
```swift
public struct AtlasCodeWhy: Sendable, Equatable {   // requireSchema("atlas.code.why.v1")
    public struct Commit: Sendable, Equatable, Identifiable {
        public struct Provenance: Sendable, Equatable {
            public let quote: String; public let obra: String?; public let gates: [String]
        }
        public let hash: String; public let when: Date?
        public let agent: String; public let subject: String
        public let provenance: Provenance?
        public var id: String { hash }
    }
    public let repo: String; public let file: String
    public let commitsTotal: Int; public let truncated: Bool
    public let commits: [Commit]
}
extension AtlasClient {
    public func getCodeWhy(repo: String, file: String, limit: Int = 20) async throws -> AtlasCodeWhy
}
```
**Golden checks (`AtlasCodeWhyChecks.swift`):** `why_decode_full` ·
`why_schema_unknown_fails_closed` · `why_provenance_null_preserved` ·
`why_truncated_flag` · `why_empty_commits_ok`.

## V5.4 Casca (T5.3)
- Model `AtlasCodeWhyModel` (molde dos models do Código; `LoadPhase` da
  SOTA F1.4; `load(repo:file:)` único gatilho de rede).
- Entrada: na folha de proveniência (componente `AtlasCodeFileRow` — após o
  split SOTA F3.2 estará em arquivo próprio), o toque no arquivo abre
  `AtlasCodeWhySheet`.
- **Wireframe:**
```
┌─────────────────────────────────────────────┐
│ POR QUE ESTE ARQUIVO EXISTE                 │ mono 11 textTertiary
│ App/Atlas/RootView.swift                    │ mono(12) textSecondary
│                                             │
│ ● "quero a home viva, não um menu"          │ quote: serifItalic(15)
│    fable · há 1 dia · a1b2c3d               │ meta: mono(11) textTertiary
│ │                                           │ espinha vertical gold@0.35
│ ● sem proveniência registrada               │ textTertiary italic
│    voce · há 2 dias · e4f5a6b               │
│ │                                           │
│ ● "a busca precisa ser real"                │
│    fable · há 3 dias · 9c8d7e6              │
│                                             │
│ mostrando 20 de 34 · história truncada      │ mono(11) textTertiary
└─────────────────────────────────────────────┘
```
- Ordenação: mais recente no topo. `agent` com a MESMA paleta de agente já
  usada na proveniência (não inventar cores novas). Tempo relativo:
  `AtlasCodeRelativeTime` existente. Espinha: gramática visual do grafo
  (gold @0.35), decorativa → `accessibilityHidden(true)`.
- Estados: carregando (diamond) · `commits vazio` → "este arquivo não tem
  história neste recorte" (honesto) · falha → mensagem do model.
- A11y: `A11yID.whySheet/whyRow(index:)`; VoiceOver: "<quote ou 'sem
  proveniência registrada'>, <agente>, <tempo>".

## V5.5 Edge cases
| Caso | Comportamento |
|---|---|
| Arquivo renomeado no meio da história | `--follow` cobre; check PHPUnit fixa |
| Arquivo novo (1 commit) | timeline de 1 item; sem truncated |
| Todos sem ledger | lista inteira "sem proveniência registrada" — verdade absoluta, sem desculpa |
| Repo não registrado no locator | sheet mostra indisponível explícito (404 do servidor) |
| limit > commits | truncated=false, N=M |

## V5.6 Prova (T5.4)
Probe real: `App/Atlas/RootView.swift` deste repo (história densa com
ledger) → frases reais na tela; arquivo sem registro → ausência honesta;
XCUITest estende hub→radar→grafo→proveniência→**arquivo→why**; screenshots
simulador+device → `docs/evidence/<data>-h1-why/`; PHPUnit + golden checks
+ gates verdes.

---

## §E · ORDEM MESTRA DE COMMITS (20)

```
V1: 01 feat(ui)   TurnPresence.liveSessions + threadId no watch
    02 feat(ui)   LiveNowSection + integração na home
    03 test(ios)  prova da home adaptativa + screenshots + §7
V2: 04 feat(core) AtlasDayRhythm + golden checks (+ main.swift)
    05 feat(core) pontos recordActivity nos models (missão §6)
    06 feat(ui)   NightlyProposal + card + delegate de notificação
    07 test(ios)  prova (simulador + device) + §7
V4: 08 server     manifesto + content (PHPUnit red→green) + probe real
    09 feat(core) AtlasTraceArtifacts + checks
    10 feat(ui)   linha ARTEFATOS + ArtifactSheet
    11 prova      live-probe + XCUITest + screenshots + §7
V3: 12 server     constitution-scan service+command (PHPUnit red→green)
    13 server     área atlas-native + política observe/heal + probe
    14 feat(ui)   seção self + SelfConstructionReceiptSheet
    15 prova      FIM-A-FIM real (plantar→detectar→curar→recibo) + §7
V5: 16 server     /api/code/why (PHPUnit red→green) + probe real
    17 feat(core) AtlasCodeWhy + checks
    18 feat(ui)   AtlasCodeWhySheet + toque no FileRow
    19 prova      real + XCUITest estendido + §7
    20 docs(obra) registro final das 5 verticais + fila §4 DONE
```

## §F · DEFINITION OF DONE

| V | Prova objetiva (todas obrigatórias) |
|---|---|
| V1 | Screenshot ocioso idêntico ao pré-mudança · 2 sessões vivas com fases/relógios do servidor · XCUITest verde · zero rota nova · boundary verde |
| V2 | 8 golden checks do rhythm verdes · proposta com workspaces reais na janela aprendida · aceite→recibo `enqueued` real · dia vazio/cold start = silêncio · foto da notificação no device |
| V3 | PHPUnit das 5 regras verde · ciclo INTEIRO real provado (plantar→finding→cura→merge com gates→recibo no app) — nenhum passo simulado · veto presente APENAS com contrato |
| V4 | Artefato real previewado com sha validado · unavailable sem UI · 413 vira ficha honesta · kind desconhecido não crasha (check) |
| V5 | Frases reais do ledger na biografia de arquivo real · provenance null vira ausência dita · rename coberto (--follow) · truncamento exibido |

Fechamento global: OBRA §7 com as 5 entregas + evidências; fila §4 DONE;
re-auditoria rápida: `rg "Route\." App/Atlas | wc -l` não cresceu em rotas.

## §G · RISCOS E PLAYBOOK

1. **V3 não fechar o ciclo** (workspace-cert, worker, política): PARAR no
   último passo provado; §5 com o bloqueio exato; entregar
   scanner+backlog+superfície como PARCIAL honesto. Nunca simular cura.
2. **Drift do repo** (Codex/Fable ativos na main): `git status --short`
   antes de cada commit; símbolos > linhas; conflito de escopo → reler
   OBRA §4 e trabalhar na próxima tarefa independente.
3. **Notificações no simulador** são limitadas: entrega real da notificação
   prova-se em device físico; simulador prova card/fluxo.
4. **SOTA incompleto** (A11yID/LoadPhase/atlasCard/splits ausentes): criar o
   mínimo aqui citando a tarefa SOTA — nunca duplicar em paralelo.
5. **Server drift** (porta 3737 servindo versão velha — precedente
   MISSION-LOG): provar contra instância nova em porta livre e registrar.
6. **Duas falhas seguidas na mesma frente** → parar a frente, §5 honesto,
   seguir para a próxima tarefa independente. Vermelho nunca se esconde.
