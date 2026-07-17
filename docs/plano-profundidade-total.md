# PLANO PROFUNDIDADE TOTAL — as 155 melhorias do atlas-native
<!-- M01–M160: 160 slots − 4 removidos por canon (M63/M73/M74/M75) − 1
     absorvido (M67→M83). Canon 2026-07-17 v2: DENTRO do app, zero telas
     novas exceto Rivals; FORA do app (widgets, lock screen, Dynamic Island,
     StandBy, Controls), tudo liberado e incentivado. Voz fora em definitivo.
     v3: §SUPREMO-DETALHE + Ondas 15–18 (M118–M140).
     v4: SD-6..SD-9 + Ondas 19–22 (M141–M160) + KPIs mensuráveis + matriz de
     rastreabilidade + anti-padrões das superfícies externas. -->


> **Para qualquer IA executora (Grok, GPT, Codex, Claude) sem contexto prévio.**
> Plano-mestre pós-SOTA e pós-Próximo Patamar: TUDO que resta para levar o
> atlas-native ao teto absoluto do escopo atual, organizado em 11 ondas
> executáveis. Hierarquia: **canon do operador > este plano > OBRA.md
> operacional > improviso.** O repo evolui — re-verifique símbolos com `rg`
> antes de editar.
>
> **Pré-requisitos assumidos (verifique com `git log`):** plano SOTA 10/10
> concluído; verticais V1/V2/V4/V5 DONE; V3 PARCIAL no último passo (worker);
> rede documentacional ADN F1–F5 viva no atlas-server.
>
> **Leis permanentes desta era (canon do operador, v2 2026-07-17):**
> **DENTRO do app: zero telas novas** — todo investimento é PROFUNDIDADE das
> 6 rotas existentes (home/conversa/workspaces/busca/Autônomos/Código).
> Exceção única e final: **M61 Rivals**. Sheets/seções dentro das telas
> atuais não são telas — são profundidade da tela dona.
> **FORA do app: tudo liberado e incentivado** — widgets de Home, lock
> screen (accessories + Live Activity interativa), Dynamic Island em todas
> as variações, StandBy, Controls, notificações ricas (Ondas 11–14).
> **Voz fora EM DEFINITIVO** — inclusive Siri como interface. App Intents
> são permitidos SOMENTE como encanamento mecânico de botões (Live Activity
> interativa/Controls), nunca como interface de voz prometida ou anunciada.
> iPad e Atlas-wide removidos. Congelados da Onda 9 só descongelam pelo
> critério objetivo. Zero dado inventado; ausência ≠ zero; nenhum botão sem
> ação; `device-pending` nunca vira prova.
> **A tese-alvo:** o app supremo de programação agêntica de altíssimo nível —
> a elite de engenharia vê, audita, entende, rege e melhora o que os agentes
> fazem, de qualquer superfície do iPhone, sem jamais abrir mais uma tela.

## §A · Protocolo (obrigatório, resumo — o detalhe vive nas specs anteriores)

1. Ler `OBRA.md` INTEIRO; registrar missão em §6 com autorização do operador;
   reivindicar linhas na fila §4 (IN_PROGRESS + write scope).
2. Gates antes de TODO commit: `swift run AtlasCoreChecks` + `cd App && make
   build` + `git diff --check` — exit 0, sem `|| true`. Wire → live-probe
   `ATLAS_LIVE=1 ATLAS_TOKEN=…`. Visual → screenshot + XCUITest.
3. Branch main local nos dois repos; stage explícito; commits pequenos em
   português (o quê + por quê); prefixos `feat(core)|fix(core)|feat(ui)|
   polish(ui)|test(ios)|docs(obra)`.
4. Lado servidor: place-feature antes de endpoint novo; PHPUnit red→green;
   respostas allowlist provider-safe com schema `atlas.*.v1` fail-closed;
   knowledge sync + index-code após docs/código.
5. Cada onda fechada → OBRA §7 com PROVA + fila §4 DONE.
6. Duas falhas seguidas na mesma frente → parar, §5 honesto, próxima tarefa.

## §B · Mapa de decisões pendentes do OPERADOR (bloqueiam itens específicos)

| Decisão | Bloqueia | Default se não decidido |
|---|---|---|
| Nome da tela de medição no código (ESCOPO já decidido 2026-07-17: completo, todas as métricas/resultados; recomendação de nome: `AtlasArena*`) | M61 | não implementar até o nome |
| Arquivar OBRA §7 pré-15/07 em OBRA-ARCHIVE.md | M60 | não arquivar |
| Commitar docs de planejamento (SOTA/roadmap/specs) | M82 | permanecem untracked |
| Paisagem para telas de leitura (hoje Portrait-only deliberado) | M27 | manter Portrait |
| Adotar SwiftFormat/lint como gate | M41 | não adotar |
| Biometria em ações destrutivas | M53 | não implementar |

---

# ONDA 0 · PROVA — fechar o que está aberto (M01–M06)
*Nada de código novo enquanto prova pendente mente sobre o estado. 1 dia.*

### M01 [P·server+device] Ciclo V3 completo com worker/lease real
**O quê:** destravar o bloqueio §5 do worker SCL: garantir lease real na área
`atlas-native`, rodar `execute` (operador+motivo reais), cura R2 executa,
merge comprovado (`outcome=merged`+`merge_hash`), entrega aparece em
"O ATLAS MELHOROU O PRÓPRIO APP" com `SelfConstructionReceiptSheet`.
**Prova:** screenshots do ciclo + hashes no OBRA §7; `model.delivered`
não-vazio para a área self. NUNCA simular nenhum passo.

### M02 [P·operador+device] Sessão de prints DEVICE_PROVEN
**O quê:** bateria de fotos no iPhone físico: U1 strip, U2 composer
3-estados, U4 erro editorial, U5 AXXXL, U6 ícone na home, U8 timeline viva,
U9 notificação lock screen, U10 Live Activity/Dynamic Island.
**Prova:** `docs/evidence/<data>-device-proven/01..08.png` + fila §4 dos U
marcados DEVICE_PROVEN.

### M03 [M·operador+Xcode] Baselines Instruments (N8 real)
**O quê:** no iPhone físico: cold launch (alvo <400ms, template App Launch),
scroll da conversa em streaming de 40k (alvo 0 hitches @120Hz, template
Animation Hitches), load do grafo 200 nós, pico de memória em upload 20MB
(alvo <60MB incrementais).
**Prova:** números + traces em `docs/evidence/perf-baseline/`; N8 já é gate
em OBRA §2 — a partir daqui regressão = não commita.

### M04 [P·operador] Credencial APNs no cofre
**O quê:** habilitar Push Notifications p/ `com.vitor.atlas.native` no Apple
Developer; instalar `ATLAS_LIVE_ACTIVITIES_APNS_KEY_ID/_TEAM_ID/_PRIVATE_KEY`
+ `ATLAS_LIVE_ACTIVITIES_ENABLED=true` no cofre do servidor.
**Prova:** Live Activity atualizada por push com app morto; foto da lock
screen; registro §7. Até lá o transporte local segue honesto.

### M05 [P·device] Provas físicas das 5 verticais
**O quê:** repetir no iPhone: V1 (2 sessões vivas na home), V2 (notificação
das 21h real na lock screen), V4 (artefato real previewado), V5 (biografia
com frases reais). V3 coberto por M01.
**Prova:** `docs/evidence/<data>-verticais-device/` + §7.

### M06 [P·executor] Bateria live-probe completa com token
**O quê:** `ATLAS_LIVE=1 ATLAS_TOKEN=… swift run AtlasCoreChecks` integral
(upload 3.2MB/sha/resume, create→SSE→done, long message, tools >5s) — várias
rodadas recentes pularam por falta de token no ambiente.
**Prova:** saída integral colada no §7.

---

# ONDA 1 · CONTRATOS DE SERVIDOR (M07–M14)
*A casca está pronta ou quase para todos; cada um é PHPUnit red→green +
decode fail-closed no Core + binding mínimo.*

### M07 [M·server+core+casca] Contrato de STEERING (regência viva)
**O quê:** hoje a fila C11 só injeta APÓS o turno. Novo contrato: `POST
/ai/interactions/{trace}/steer` com `{instruction, scope: current_step|
replan}` → o servidor entrega ao agente no próximo checkpoint seguro e
publica evento público `steering_accepted|steering_rejected(reason)`.
Allowlist: a instrução do operador é o ÚNICO texto que atravessa.
Core: `steerInteraction(traceId:instruction:scope:)` + evento na timeline.
Casca: ação "Redirecionar" no ExecutionStateCard/LiveNow row (sheet com
campo de texto + destino literal do recibo).
**Prova:** PHPUnit; live: turno real redirecionado com o evento na timeline
e o agente citando a instrução; XCUITest do fluxo. **Desbloqueia:** M68.

### M08 [P·server+core+casca] Contrato de UNDO/REVERT de ciclo Autônomos
**O quê:** `POST /autonomos/{area}/cycles/{cycle}/revert` com operador+motivo
→ enfileira missão de reversão do `merge_hash` (git revert governado), recibo
append-only com `revert_of`. Core: DTO + `revertCycle(...)`. Casca: o botão
"Desfazer — com recibo" do SelfConstructionReceiptSheet nasce (hoje ausente
por lei do botão falso).
**Prova:** PHPUnit; ciclo real revertido com recibo; o recibo original NUNCA
some (append-only).

### M09 [P·server+casca] C19 · Digest agendado + next_digest_at
**O quê:** `GET /autonomos/digest` → `{next_digest_at, last: {window,
delivered[], risks[], pending_decisions[]}}` provider-safe. Casca: seção
"próximo resumo" na AutonomosView + a notificação da manhã (V2) passa a
citar o headline REAL do digest.
**Prova:** PHPUnit; manhã real com conteúdo verdadeiro; sem digest → o
convite genérico atual permanece (nunca número inventado).

### M10 [P·casca] C20 · Painel de pareceres/consenso na review
**O quê:** `CouncilMember`/`councilDiverged` já decodificados. Renderizar na
ChangeReviewSheet: posição pública por papel (provider/model/status/hash),
divergência como FATO (hashes distintos), nunca veredito inventado.
**Prova:** trace real de council com o painel; trace sem council → seção
ausente; screenshot.

### M11 [P·casca] Pílula de diff ao vivo (+N −M)
**O quê:** `diff_stats {files_touched, lines_added, lines_removed}` já chega
nos checkpoints (C18, fonte `9a06fd4c56`). Renderizar a pílula no
ExecutingStrip/cockpit DURANTE a execução; sem workspace → ausente.
**Prova:** execução real com workspace mostrando a pílula crescendo;
screenshot + XCUITest.

### M12 [P·server+casca] Contrato "abrir instância" do Autônomos
**O quê:** definir com o operador o que "abrir" significa (v1 recomendada:
folha com placement+missão+último checkpoint+ledger recente da instância —
`GET /autonomos/instances/{id}` provider-safe). Sem contrato, a affordance
continua não existindo.
**Prova:** PHPUnit + folha real no simulador.

### M13 [M·server+core+casca] Sessões vivas do servidor (cockpit onisciente)
**O quê:** `GET /ai/sessions/live?installation=` → sessões interativas ativas
da instalação `{thread_id, title, phase_title, timing, elapsed_active_ms,
running_since}` (mesmo shape da presença — o servidor JÁ tem tudo). Core:
DTO + polling leve (30s) só quando o app está ativo. Casca: LiveNowSection
funde locais (TurnPresence) + remotas (dedup por trace), remotas com selo
"em outra superfície".
**Prova:** turno iniciado no Terminal aparece na home do iPhone; PHPUnit;
XCUITest com fixture.

### M14 [P·casca+desktop] Handoff de superfície fim-a-fim (cena 08)
**O quê:** a ação "abrir no destino" com o recibo `ready` existente + deep
link; prova cruzada iPhone→Terminal (`atlas:cli:state --thread=` já aceita).
**Prova:** mesma thread aberta nas duas superfícies sem clone; §7.

---

# ONDA 2 · EXPERIÊNCIA & POLISH (M15–M27)
*Território Fable puro, salvo indicado. Cada item: screenshot antes/depois.*

### M15 [M] As 3 correções do QA de 13/07
(a) Faixa "Seguindo a execução · N eventos · tempo · Parar" na régua compacta
do mock — nunca 2 linhas, nunca competindo com o composer; (b) pills
`geral`/`auto` com prioridade/overflow explícito em largura iPhone — rótulo
nunca some; (c) pós-conclusão o composer volta ao estado mínimo (sem
controles vazios gigantes). **Prova:** os 3 screenshots do QA refeitos.

### M16 [P] Estado visual "pausada há muito tempo"
LiveNow row com `paused` > 30min ganha tratamento próprio (opacidade + "há
Xh" em vez do ‖ eterno). Dado real do `pauseTimestamp`.

### M17 [P] Haptic de resposta em outra thread
Quando um turno seguido conclui e o operador está noutra tela, `.soft` +
o ◆ some — hoje só o visual. Gated por app ativo.

### M18 [M] Scroll-to-anchor no grafo
Tocar commit citado na resposta da pílula/biografia rola o grafo até o nó
(ScrollViewReader + id por hash). Reduce Motion → salto sem animação.

### M19 [P] Pull-to-refresh uniforme
`.refreshable` em AutonomosView e AtlasCodeView (radar já tem?
verificar) — mesmo gesto em toda lista de dados vivos.

### M20 [P] Cold start visível da Proposta das 21h
Linha discreta na AutonomosView enquanto `sampleDays < 4`: "aprendendo seu
ritmo · dia N de 4" (dado REAL do rhythm). Some ao completar.

### M21 [M] Zoom de imagem no ArtifactSheet
MagnificationGesture + drag no preview de imagem; double-tap reset.
A11y: `accessibilityZoomAction`.

### M22 [P] "Ver no grafo" no recibo de auto-construção
O `merge_hash` do ciclo vira link → abre AtlasCodeView com âncora no nó
(usa M18). Fecha o loop V3↔Código.

### M23 [M] Skeleton editorial para listas grandes
Componente `AtlasSkeletonRow` (shimmer sutil na paleta, Reduce Motion →
estático) para grafo/frota/threads no primeiro load. Nunca skeleton sobre
dado já cacheado (o read-cache F6.1 mostra conteúdo real).

### M24 [P] Micro-confirmação de revalidação do read-cache
Selo "visto há X" pulsa 1× (editorial, 0.32s) quando o refresh confirma;
Reduce Motion → troca de texto seca.

### M25 [M] Fila na Dynamic Island
`queuedMessages.count > 0` → "⧗ N na fila" na região expanded (dado real do
model; ContentState aditivo — retrocompatível com payload APNs).

### M26 [P] Rotor de VoiceOver no grafo
`accessibilityRotor("Violações")` saltando entre nós `.violating`; idem
"Curados". O leitor navega o grafo como o olho.

### M27 [M·DECISÃO] Paisagem para telas de leitura
SE o operador aprovar: biografia/diff/artefato aceitam paisagem
(`supportedInterfaceOrientations` por apresentação); resto permanece
Portrait. Senão: registrar decisão e fechar.

---

# ONDA 3 · PERFORMANCE — o degrau pós-SOTA (M28–M34)
*Regra: MEDIR antes (M03) e depois. Regressão de baseline = não commita.*

### M28 [M] Grafo com 1.000+ nós
Elevar o teto de paginação e medir: LazyVStack aguenta? Se hitch:
`drawingGroup()` por linha (M32) → se ainda: aí sim N1/Metal descongela
(critério objetivo J71).

### M29 [P] Prefetch no touch-down
`ThreadRow` inicia `model.load()` no press (PressableScale já captura o
gesto) — a conversa abre com dados chegando.

### M30 [P] Cache de sessão da biografia
`[repo+file: AtlasCodeWhy]` em memória (NSCache 16 itens) com selo de idade;
refresh explícito por pull.

### M31 [M] Coalescer mutações de bubbles no streaming
Medir: acumular tokens por até 80ms/4 tokens antes de mutar `bubbles`
(reduz re-diff do Observable). SÓ se M03 mostrar custo; a percepção de
"vivo" não pode morrer — validar com o operador.

### M32 [P] Rasterizar a espinha do grafo
`.drawingGroup()` no container da spine+nó por linha (conteúdo estático);
manter texto fora (Dynamic Type).

### M33 [P] Instruments Leaks nos singletons novos
TurnPresence/NightlyProposal/LiveActivityRemoteBridge: sessão de Leaks +
Allocations; confirmar zero ciclos de retenção (closures + delegates).

### M34 [M] Perfil do primeiro frame
App Launch template: custo de AtlasSession.init, registro de fontes, primeiro
body do RootView. Meta N7 <400ms cold. Otimizações óbvias (lazy fonts?) só
com número na mão.

---

# ONDA 4 · QUALIDADE DE CÓDIGO (M35–M42)

### M35 [P·server] Grammar ausente = erro DITO
`CodeGraphTreeSitterExtractor`/`CodeGraphRuntimeInvoker`: linguagem na
allowlist sem grammar carregado → `grammar_missing:<lang>` no payload e
exit≠0 no index — nunca 0 símbolos silencioso. PHPUnit com grammar fake
ausente. (Follow-up registrado na ADN.)

### M36 [P] Poda pós-verticais
Rodar o scanner R2 (dead_symbol) sobre o HEAD atual; deletar o que as
verticais deixaram sem consumidor. Gates + re-grep por símbolo.

### M37 [M·triagem] Os 319 findings do constitution-scan
Triagem em 3 baldes: (a) threshold a calibrar (R1 com limite certo p/ o
repo?), (b) dívida real → fila §4 com owner, (c) falso-positivo → regra
refinada + PHPUnit do caso. Meta: backlog do scanner 100% triado, zero
finding "paisagem".

### M38 [P] Sweep final de idioma
`rg -l "// [A-Z]" Sources App` heurístico + revisão: comentários
remanescentes em inglês → PT (decisão F4.3). Sem commit dedicado gigante;
por arquivo tocado ou 1 varredura final.

### M39 [P] Models novos no padrão LoadPhase
Verificar AtlasCodeWhyModel/artifacts state usam `LoadPhase` (não Phase
próprio). Regredir à triplicação é violação da F1.4.

### M40 [M] Snapshot tests das views-chave
Home ociosa, home cockpit, card 21h, recibo self, biografia: snapshot por
`ImageRenderer` comparado a referência versionada (tolerância 0). O critério
"byte-igual" vira teste, não screenshot manual. (Sem dependência externa —
ImageRenderer é SwiftUI puro; ADR §6 se optar por lib.)

### M41 [P·DECISÃO] SwiftFormat/lint como gate
SE o operador aprovar: config mínima + `make lint` no gate §2. Senão
registrar decisão contrária.

### M42 [M] Golden checks de edge das verticais
Artifacts: manifesto com item deletado entre manifest e content (404),
resposta 413; Why: fixture com rename real (--follow), arquivo de 1 commit;
Rhythm: virada de ano/DST. Cada edge da spec §V*.5 sem check ganha um.

---

# ONDA 5 · ROBUSTEZ & RESILIÊNCIA (M43–M48)

### M43 [M] Reconexão automática por NWPathMonitor
Rede volta → models com `LoadPhase.failed` re-tentam sozinhos (1×, com
backoff); o selo do read-cache atualiza. Nunca loop agressivo.

### M44 [P] Timeout adaptativo por qualidade de caminho
`NWPath.isExpensive/isConstrained` → create usa 90s; caminho bom → 45s com
1 retry. Medir antes de mudar defaults.

### M45 [M] 503 com Retry-After = "servidor atualizando"
`AtlasNetworkFailureKind.maintenance` novo (Core) + copy editorial própria +
re-tentativa automática no horário indicado. Servidor: emitir 503+header no
deploy (já emite? verificar).

### M46 [P] Guarda contra clock skew do device
Se `runningSince` do servidor está no "futuro" do device (>2min), mostrar
fase sem relógio + nota "relógio do aparelho divergente" — nunca timer
negativo.

### M47 [P] Versionamento do arquivo do rhythm
Campo `v` já existe; escrever o caminho de migração v1→v2 no padrão do
outbox (load tolerante, persist no formato novo) + golden check.

### M48 [M] Silenciar propostas por período
Ação "silenciar por 7 dias" no card das 21h (armazenada no rhythm store,
local) — respeita a lei da não-insistência sem exigir Settings do iOS.
Estado visível: "propostas silenciadas até <data>" em Autônomos.

---

# ONDA 6 · SEGURANÇA & PRIVACIDADE (M49–M53)

### M49 [M] Pinning por perfil de host
Para hosts não-locais (multi-empresa futuro): `URLSession` delegate com
pinning opcional por config; localhost/Tailscale seguem como hoje. ADR §6.

### M50 [P] ATLAS_TOKEN no Keychain
Migração transparente: primeiro launch lê do Info.plist → grava Keychain →
usa Keychain; xcconfig vira só bootstrap de dev. Boundary check: Keychain
API permitida SÓ em AtlasSession (ajustar allowlist do check com justificativa).

### M51 [P] Redaction audit das notificações
Revisar todo `UNMutableNotificationContent`: título de thread pode vazar
conteúdo sensível na lock screen. v1: truncar + `plainText`; v2: quando o
contrato de privacy-class por thread existir, respeitar.

### M52 [P] PrivacyInfo.xcprivacy
Manifesto Apple: declarar UserDefaults (installSalt), file timestamp APIs
(rhythm/outbox), zero tracking. Exigência de App Store futura e honestidade
presente.

### M53 [M·DECISÃO] Face ID em ações destrutivas
SE aprovado: `LAContext` antes de encerrar frota / reverter ciclo / veto de
cura. Prepara N4 sem Secure Enclave ainda.

---

# ONDA 7 · A REDE & O CÉREBRO NO NATIVO (M54–M60)

### M54 [M] Ampliar o canto canônico (4 docs)
`atlas-native-rich-input.md`, `atlas-native-codigo.md`,
`atlas-native-autonomos.md`, `atlas-native-gates.md` — cada um no padrão
ouro completo (frontmatter integral + 12 seções), apontando para os dossiês
e código. docs-health 0 violações cada; sync federado os ingere.

### M55 [P] README.md
Porta de entrada: o que é, arquitetura em 10 linhas, como buildar
(`make build/sim/device`), gates, onde começar a ler (OBRA → canto → specs).
Curto — aponta, não duplica.

### M56 [M] docs/arquitetura.md
O mapa que só existe nas auditorias: 3 camadas com diagrama, o seam, os
contratos `atlas.*` consumidos (tabela única), concorrência (actors), padrão
fail-closed, boundary check. Vira o 5º doc do canto (padrão ouro).

### M57 [P·server] R6 no constitution-scan: canto desatualizado
Doc canônico com mtime > 30d atrás do churn do módulo que ele governa →
finding `observe` "documentação fria". A frota passa a cobrar a rede.
PHPUnit com fixture.

### M58 [P·server] Semear invariantes do brief
As leis do OBRA §3 + fronteiras §1 viram `invariant` memories
workspace-scoped no registro canônico → o brief do atlas-native deixa de
mostrar `invariantes: 0`. Via `atlas:memory:add` governado (G0-G8).

### M59 [M·server] Decisões §6 como memórias por workspace
Capturador: entrada nova em OBRA §6 → candidato de memória
`decision` workspace=atlas-native (quarentena imune normal). O pack passa a
lembrar decisões da obra sem depender do doc inteiro.

### M60 [P·DECISÃO] OBRA-ARCHIVE.md
SE aprovado: mover §7 pré-2026-07-15 para `docs/OBRA-ARCHIVE.md` com
ponteiro; OBRA.md volta a ser lido de uma vez pelos executores.

---

# ONDA 8 · PRODUTO dentro do "zero telas novas" (M61–M67)

### M61 [G·server+core+casca] O COCKPIT DE MEDIÇÃO — a única tela nova
**ESCOPO PLENO DECIDIDO PELO OPERADOR (2026-07-17, v2):** a tela é o cockpit
COMPLETO da medição — (1) o ÍNDICE CONSOLIDADO que roda as ~10 suites e
consolida num resultado único ("o maior e mais completo do mundo"),
(2) medições RODANDO AGORA com braço visível (normal × com Atlas),
(3) AÇÃO de disparar uma medição (governada), (4) perfil de CAPACIDADES/
habilidades medidas, (5) TODAS as métricas com gráficos. Pendente apenas o
NOME no código (regra Criação≠Medição; recomendação: `AtlasArena*`, rota
`.arena`; título exibido = escolha do operador).

**Fonte (atlas-server, domínio Rivals):** suites externas (terminal_bench,
inspect_evals, …) + adapters + braço comparativo com/sem Atlas. O que não
existir ainda no servidor (índice consolidado, perfil de capacidades, runs
live, start governado) É PARTE DESTE ITEM — PHPUnit red→green, allowlist.

**Os 5 contratos `atlas.arena.*.v1`** (allowlist absoluta — NUNCA prompt,
caso, log, stdout, fixture):

```json
1) GET /api/arena/composite            ← O ÍNDICE CONSOLIDADO
{ "schema_version": "atlas.arena.composite.v1",
  "suites_total": 10, "suites_measured": 8,     // parcial é DITO
  "weights_public": {"terminal_bench": 0.15, "…": 0.10},
  "engines": [{ "engine": "codex_cli",
    "composite": 0.83, "previous": 0.79, "delta": 0.04,
    "with_atlas_composite": 0.92, "without_atlas_composite": 0.75,
    "atlas_multiplier": 1.23,
    "coverage": 0.8 }] }                        // mediu 8/10 → dito

2) GET /api/arena/scoreboard           ← por suíte × motor (como v1 anterior)
   score, previous, delta, with/without_atlas, multiplier,
   cases_passed/failed/total, duration_avg_ms, regressed, last_run_at

3) GET /api/arena/capabilities?engine=  ← HABILIDADES medidas
{ "schema_version": "atlas.arena.capabilities.v1",
  "capabilities": [{ "capability": "terminal_operation",
    "score": 0.86, "with_atlas": 0.93,
    "suites_contributing": ["terminal_bench"], "cases_total": 42 }] }
   // dimensões: terminal, edição de código, raciocínio, recuperação de
   // contexto, correção de bugs, … — derivadas do MAPEAMENTO PÚBLICO
   // suíte→capacidade (config versionada no servidor, exposta no payload)

4) GET /api/arena/runs/live            ← RODANDO AGORA
{ "runs": [{ "run_id_public": "…", "suite": "…", "engine": "…",
   "arm": "with_atlas" | "baseline",
   "cases_done": 17, "cases_total": 42, "started_at": "…",
   "status": "running" | "queued" }] }

5) POST /api/arena/runs                ← RODAR UMA MEDIÇÃO (governado)
{ "suites": ["terminal_bench"] | "all",
  "engine": "codex_cli", "arms": ["baseline","with_atlas"],
  "operator_actor": "…", "operator_reason": "…" }
→ 202 { "status": "enqueued", "receipt_hash": "…" }
   // liturgia do Autônomos: ator+motivo obrigatórios; recibo "na fila ·
   // ainda não iniciado"; NUNCA promovido a "rodando" sem o /runs/live
   // provar; execução real depende do worker/lease de medição.
```

**A tela (rota nova AUTORIZADA — a única):**
```
┌ [NOME] · MEDIÇÃO DOS MOTORES ────────────────┐
│ ⚠ inspect_evals · hermes regrediu −0.05      │ ← exceções SEMPRE primeiro
├─ AGORA ──────────────────────────────────────┤ ← só existe com run vivo
│ ● terminal_bench · codex · COM ATLAS  17/42  │   braço em destaque
│ ○ swe_like · claude · baseline  na fila      │
├─ O ÍNDICE ───────────────────────────────────┤
│        CONSOLIDADO DAS 10 SUITES              │
│  codex   0.83 ▲   com Atlas 0.92  ×1.23      │ ← a prova N×M do Atlas
│  claude  0.86 ▬   com Atlas 0.94  ×1.31      │
│  cobertura 8/10 suites · pesos públicos ⓘ    │ ← parcial é DITO
│  [gráfico de linhas: composto por rodada]     │
├─ CAPACIDADES ────────────────────────────────┤
│  terminal      ████████░░ 0.86  ⣿ 0.93 c/A   │ ← barras duplas
│  edição código ███████░░░ 0.74  ⣿ 0.88 c/A   │   (Swift Charts nativo)
│  raciocínio    █████████░ 0.91  ⣿ 0.95 c/A   │
├─ SUITES ─────────────────────────────────────┤
│  TERMINAL_BENCH · 12 rodadas · há 2h  [spark]│ → folha da suíte
│  INSPECT_EVALS  · 9 rodadas · há 1d   [spark]│
├──────────────────────────────────────────────┤
│            [ ▶ Rodar medição ]               │ → sheet: suites/motor/
└──────────────────────────────────────────────┘    braços + ator+motivo
```
Folha da suíte: por motor — casos ✓/✗ (contagens), duração média, série
histórica completa, rodadas com quando/score/braço. Folha do motor: série
composta + por capacidade.

**Leis do cockpit de medição:**
- Índice consolidado SÓ com pesos públicos no payload e cobertura dita
  (8/10 ≠ 10/10 — o número parcial nunca se veste de completo).
- `atlas_multiplier` só com os DOIS braços medidos na mesma janela.
- 3 estados sempre: medido / regrediu / **não-medido (cinza — nunca verde)**.
- "Rodar medição" segue a liturgia governada (ator+motivo, recibo `enqueued`
  = "na fila", execução provada só pelo /runs/live). Botão de suíte sem
  adapter instalado NÃO renderiza essa suíte como opção.
- Run vivo pode virar Live Activity ("Seguir" — herda M93/SD-2; braço no
  título). Gráficos: **Swift Charts (framework Apple — zero dependência
  externa)**; Reduce Motion desliga animação de traçado; todos os números
  `mono` tabulares; VoiceOver anuncia score+delta+braço por linha.
- Padrão técnico integral da casa: DTOs fail-closed, model LoadPhase,
  read-cache com selo de idade, zero rede na View, A11yID, entrada pela
  home (seção OPERAÇÃO), badge SÓ por regressão.
**Prova:** PHPUnit por contrato (incl. composto com cobertura parcial e
start governado) + golden checks + rodada REAL disparada do app aparecendo
em AGORA e depois no scoreboard + XCUITest + screenshots + device.
Widget do índice (posterior) herda SD-1.

### M62 [P·casca] Fila visível (cena 11 completa)
Chip "Fila N" quando `queuedMessages` não-vazio + folha com texto, "Enviar
agora" → `promote(id:)`, apagar → `removeQueued(id:)`. Seam pronto há dias
(C11). XCUITest do fluxo.

### M63 — REMOVIDO POR CANON (era App Intents/Siri — voz/superfície nova)

### M64 [P·casca] PlanCard "comparar versões"
`plan_revisions` decodificado (C19-fonte) → "ver versão anterior": diff de
passos (saiu/entrou) + motivo público. Sem revisões → affordance ausente.

### M65 [M·casca] Resposta inline da notificação
`UNTextInputNotificationAction` na notificação de turno concluído →
o texto vira `queue(text:)` na thread (fila C11 real). Zero tela.
Prova no device físico (simulador não entrega action).

### M66 [P·casca] Da âncora à biografia
Resposta da pílula cita commits → long-press num commit citado abre a
biografia do arquivo mais tocado daquele commit (dados já no
`AtlasCodeAskResponse.commits` + files da proveniência).

### M67 — REMOVIDO POR CANON (era Widget de Home — superfície nova)

---

# ONDA 9 · CONGELADOS com critério objetivo (M68–M72) — NÃO IMPLEMENTAR

| # | Item | Descongela QUANDO |
|---|---|---|
| M68 | Regência completa (pausar/redirecionar em run vivo) | M07 steering entregue e provado |
| M69 | Memória de critério (P9) | ≥100 decisões reais no ledger de decide/review |
| M70 | H9 Futuro fantasma (camada no grafo EXISTENTE, zero tela) | servidor emitir `ghost_nodes[]` em dry-run |
| M71 | Metal Graph Engine (N1 — motor do grafo existente) | M28 medir hitch real no teto de nós do produto |
| M72 | libgit2 / espelho on-device (N2 — sem UI nova) | decisão §6 do operador (1ª dependência externa) |

*Qualquer IA que tocar num M68–M72 sem o critério satisfeito está violando o
canon. A resposta certa é citar esta tabela e parar.*

## REMOVIDOS POR CANON (v2 2026-07-17 — não são congelados; NÃO EXISTEM)

| # | Era | Motivo |
|---|---|---|
| M63 | Siri como interface ("como está a frota?") | voz, em definitivo. App Intents só como encanamento de botões (M89/M92) |
| M73 | Atlas-wide (agenda/saúde/decisões/capturas) | N domínios = N telas dentro do app |
| M74 | iPad | superfície nova inteira |
| M75 | Voice Supremacy | removida em definitivo |
| M67 | — | ABSORVIDO: restaurado e ampliado como M83/M84 (fora do app liberado no canon v2) |

---

# PATAMAR SUPREMO — as ondas de profundidade (11–14)
*Canon v2: fora do app tudo liberado; dentro do app, as telas existentes ao
teto absoluto. As 4 frentes nomeadas pelo operador.*

# ONDA 11 · FORA DO APP — presença total no iPhone (M83–M93)
*Regra transversal: toda superfície externa consome SNAPSHOT/push de dado
real (read-cache por App Group ou presença tipada) — NUNCA rede própria,
NUNCA número inventado; sem dado → estado honesto "abra o Atlas".*

### M83 [M·widget] Widget de Home — frota por exceção
Pequeno/médio: incidente real OU silêncio editorial ("frota íntegra ·
varrida há Xh" — só com varredura real) + última entrega comprovada
(merge_hash). App Group + snapshot do read-cache (novo entitlement, ADR §6);
timeline 30min. XCUITest de widget + foto na Home.

### M84 [P·widget] Widget "A Semana do Código"
Médio/grande: commits/curas/prevenções da janela real do `/code/week` (via
snapshot). Tendência com setas quando M110 existir. Zero número sem fonte.

### M85 [P·widget] Lock screen accessories
Circular: contagem de sessões vivas (◆N). Rectangular: fase pública da
execução seguida + relógio congelável (regras C14). Inline: "Atlas · 2
executando". Dados da presença tipada via App Group.

### M86 [M·casca+widget] Dynamic Island — gramática completa por fase
Hoje a ilha mostra fase+timer. Elevar à gramática do design system: cor/
ícone por kind (executando=gold pulsante, pausado=‖ congelado, atenção=
alerta com apresentação urgente, falhou=alert, concluído=check verde por 5s).
`attention_required` ganha a variante expanded automática (iOS alert
presentation). Tudo derivado do `AtlasExecutionPresence` — zero estado novo.

### M87 [P·widget] Dynamic Island — progresso N/M real
`executionProgress` existe → compact trailing mostra fração (4/6); expanded
mostra `título do passo atual`. `nil` → comportamento atual (nunca barra
fabricada). ContentState aditivo (retrocompat APNs).

### M88 [M·casca+widget] Dynamic Island — multi-sessão navegável
Expanded com 2+ sessões: lista compacta das sessões (título+fase) e tap
alterna qual a ilha segue (persistido no TurnPresence). Long-press → app na
sessão. O contador ×N atual vira navegação real.

### M89 [M·casca+widget] Live Activity INTERATIVA (botões na lock screen)
iOS 17+: botões via App Intent MECÂNICO (canon: encanamento, não voz):
"Parar" (cancel do turno), "Retomar" (retryableJobId em failed),
"Escolher…" (awaiting_user_choice → abre o app direto no ExecutionStateCard).
Cada botão só existe quando a ação existe no model (lei do botão falso).
Prova só em device físico.

### M90 [P·casca] Notificações ricas com attachment
`attention_required`/turno concluído com artefato de imagem → attachment de
preview na notificação (dado do manifesto V4, cap de tamanho). Redaction
audit (M51) aplica.

### M91 [P·widget] StandBy
Apresentação dedicada da Live Activity para modo mesa (fonte maior,
contraste noturno da paleta, sem informação nova — a mesma verdade, legível
a 1 metro). A proposta das 21h e a manhã aparecem dignamente no criado-mudo.

### M92 [P·widget] Controls (iOS 18 Control Center)
Dois controles de ABERTURA (zero mutação): "Abrir cockpit" (app na home
viva) e "Seguir missão" (última missão seguida). App Intent mecânico.

### M93 [M·server+casca] Push-to-start para missões da frota
A infra push-to-start existe (C8) para turnos; ampliar: "Seguir" uma missão
Autônomos → o servidor abre Live Activity remota da missão (fase pública do
ciclo, checkpoint) mesmo com app morto. Allowlist do payload = projeção
mínima já definida; PHPUnit + prova física com APNs (M04).

# ONDA 12 · AX SUPREMO — ver, auditar, entender e reger os agentes (M94–M103)
*A frente que o operador chamou de "AX design": a estrutura de auditar o que
os agentes fazem, como fazem e como mostram. Tudo dentro da conversa/cockpit
existentes.*

### M94 [P·casca] Duração por passo na timeline
Delta entre `occurred_at` consecutivos → cada passo mostra duração (mono,
textTertiary). Passo > p90 da execução ganha destaque sutil — o gargalo
salta ao olho do auditor. Dado 100% do ledger.

### M95 [M·casca] Lanes por agente (a orquestra visível)
Quando `trace.jobs` tem 2+ agentes: timeline agrupa atividades por executor
(faixa fina com cor de domínio + nome público do agente). A cena 05
("orquestra") dentro da conversa existente. Sem multi-agente → layout atual.

### M96 [M·casca] Plano vs Executado (pós-conclusão)
PlanCard de turno terminal ganha modo auditoria: passos previstos ×
checkpoints reais (feito/pulado/replanejado), com os `plan_revisions` (M64)
inline. O desvio é o dado mais valioso para melhorar prompts/missões.

### M97 [P·casca] Recibo de decisão expandido
`decisionSummary` hoje é resumo; expandir com o que o contrato JÁ carrega
(router decision, receipt) em folha de auditoria: por que este provider/
workflow, com os campos públicos existentes. Nada além do contrato.

### M98 [P·casca+server?] Quality gate breakdown
Se o contrato de quality expuser dimensões (hoje: score+nível), renderizar o
breakdown; senão, pedir via §5 e manter o número. Nunca inventar dimensões.

### M99 [G·casca] REPLAY da execução (o scrubber de auditoria)
A timeline persistida vira reprodução: scrubber percorre os eventos com os
tempos REAIS (occurred_at), reconstruindo o cockpit como estava em cada
instante — inclusive plano N/M e presença. 100% ledger, zero rede nova.
É a ferramenta de auditoria definitiva: "o que o agente via quando decidiu X".
Reduce Motion → stepper discreto.

### M100 [P·server+casca] Custo/tokens por turno
SE o servidor expuser agregado provider-safe (tokens in/out, custo micro-usd
por trace — allowlist sem provider detail além do público), a ExecutionProof
ganha a linha de custo. Contrato via §5; sem ele, nada.

### M101 [P·casca] Comparador de artefatos
Dois artefatos de texto do mesmo turno lado a lado (diff textual reusa a
renderização do review). Seleção por long-press no ArtifactSheet.

### M102 [P·casca] Filtros de leitura da timeline
Chips locais (tools · decisões · falhas · tudo) — dim dos demais (padrão
âncora do grafo). Estado de leitura, não de dados.

### M103 [P·casca] Busca dentro da execução
Campo local na prova expandida: localizar comando/arquivo na timeline
persistida (match → scroll + highlight). Auditoria de execuções longas sem
rolagem cega.

# ONDA 13 · ATLAS CODE SUPREMO (M104–M111)

### M104 [M·casca] Pan/zoom temporal do grafo
Pinch = densidade temporal (mais/menos commits por altura); pan horizontal
para lanes futuras. Medido contra baseline (M03/M28); se hitch → M71
descongela pelo critério.

### M105 [P·casca] Filtros do grafo por agente/estado
Chips (violações · curados · voce · fable · codex · autônomos) — dim dos
demais, mesma gramática da âncora H6. Auditoria visual instantânea de "o que
o agente X fez esta semana".

### M106 [P·server+casca] Compare de dois commits
Long-press em 2 nós → `GET /api/code/compare?from=&to=` (diffstat allowlist:
files/+/− por arquivo, sem conteúdo) → folha de comparação. Contrato novo
pequeno via §5; sem ele, affordance ausente.

### M107 [P·server+casca] Radar com histórico e tendência
Varreduras têm recibo? Se o servidor persistir série (scan receipts),
expor `GET /code/scan-history?repo=` → sparkline de desvios por semana no
radar. Senão: pedir contrato; nunca desenhar tendência sem série.

### M108 [P·casca] Espelho com timeline de recibos
`AtlasCodeMirrorCard` ganha folha: espelhamentos recentes (recibo, quando,
o que bloqueou). Dado dos recibos existentes do mirror; ausência dita.

### M109 [P·server+casca] A Semana comparativa
`/code/week` com `previous_window` → setas de tendência reais (commits ↑,
curas ↓). Contrato aditivo trivial; UI só com as duas janelas presentes.

### M110 [P·casca] Biografia: filtro por agente + salto ao diff
Chips de agente na biografia (dim); commit com trace de review → link
"ver diff" abre o ChangeReviewSheet do trace correspondente.

### M111 [P·casca] Minimapa do grafo
Indicador lateral fino (posição da janela na história total, marcas de
violação em vermelho) — orientação em repos de milhares de commits.
`accessibilityHidden` (decorativo; a navegação real é a lista).

# ONDA 14 · AUTÔNOMOS SUPREMO (M112–M117)

### M112 [M·server+casca] Checkpoints públicos da missão
Contrato: série de checkpoints da missão ativa (marco público + quando —
allowlist, sem prompt/path). A área ganha "linha do tempo da missão" viva.
Via §5; a casca não inventa marcos.

### M113 [P·casca] FleetHistory como timeline editorial
`model.fleetHistory.events` (já público) renderizado como linha do tempo
(agente + evento + quando + motivo codificado) em vez de lista crua —
a mesma gramática visual da timeline de execução.

### M114 [P·casca] Drill-down de work orders/inbox/budgets
Os DTOs públicos já decodificados (findings/workOrders/inboxItems/budgets)
ganham folhas de detalhe com TODOS os campos públicos — hoje só contagens
aparecem. Ausência de campo = ausência.

### M115 [P·casca] Histórico de digests
Extensão do M09: além do próximo/último, folha com os N digests anteriores
(se o contrato os retiver). Auditoria da semana da frota.

### M116 [P·server+casca] Série de gasto por agente
Se o histórico expuser série de `spentUsd` (allowlist), sparkline por agente
na frota. Sem série → valor atual apenas (como hoje).

### M117 [P·casca] Drill-down de incidente
`incidents.present=true` → folha com flags + recommendedAction + eventos do
fleetHistory correlacionados (mesma janela). Só campos públicos existentes.

---

# §SUPREMO-DETALHE — especificações das joias da coroa
*Nível de spec executável para os itens que definem o patamar. O executor
segue LITERALMENTE; o resto do Patamar Supremo herda estes padrões.*

## SD-1 · O contrato do snapshot (fundação de TODA superfície externa)

Toda superfície fora do app (widgets/accessories/StandBy) lê UM arquivo:
App Group `group.com.vitor.atlas.native` →
`snapshot/atlas.native.snapshot.v1.json` (escrito atomicamente pelo app —
padrão do outbox — a cada: turno concluído, refresh de Autônomos/Código,
background). Schema fail-closed (versão errada → widget mostra "abra o
Atlas", nunca dado velho como novo):

```json
{ "schema_version": "atlas.native.snapshot.v1",
  "generated_at": "…",
  "live_sessions": [{ "title": "…", "phase_title": "…", "timing": "running",
                       "elapsed_active_ms": 0, "running_since": "…" }],
  "fleet": { "scanned_at": "…" , "incident": null,
             "last_delivery": { "title": "…", "merge_hash": "…", "at": "…" } },
  "week": { "window": "…", "commits": 0, "heals": 0, "prevented": 0 },
  "queued_count": 0 }
```

Regras: campo ausente = seção ausente no widget (honestidade); `generated_at`
> 6h → widget mostra idade explícita ("visto há 7h"); NUNCA rede no widget;
NUNCA valor default que pareça medição. Golden check do encode/decode dos
dois lados (app escreve, widget lê — teste compartilhado).

## SD-2 · Dynamic Island — tabela de estados canônica (M86–M88)

| Estado (fonte: AtlasExecutionPresence) | Compact leading | Compact trailing | Expanded | Minimal |
|---|---|---|---|---|
| running, sem plano | ✦ gold `breath` | timer vivo | fase (serifItalic) + timer + ×N | ✦ |
| running, com executionProgress | ✦ gold | `4/6` + timer | passo atual + barra REAL N/M + timer | fração |
| paused (awaiting_*) | ‖ âmbar estático | `‖ m:ss` congelado | "Aguardando decisão/sistema externo" + tempo ativo congelado | ‖ |
| attention_required | ⚠ alert | — | apresentação URGENTE do iOS + título da ação + botão "Escolher…" (M89) | ⚠ |
| failed | ✕ alert | `‖` final | fase + botão "Retomar" (se retryableJobId) | ✕ |
| finished | ✓ healed 5s | tempo total | "Concluído · m:ss" 5s → encerra | ✓ |
| multi-sessão (2+) | símbolo da SEGUIDA | ×N | lista das sessões; tap = trocar seguida; long-press = abrir app | ×N |

Leis: timer é SEMPRE derivado do servidor (regra C14 — pausado congela);
cor é ESTADO (gramática do §C do design system); NUNCA barra sem
`executionProgress`; a variante minimal nunca mostra número inventado.
ContentState permanece ADITIVO (payload APNs retrocompatível).

## SD-3 · Live Activity interativa — os 3 botões (M89)

```
┌──────────────────────────────────────────────┐
│ ✦ Refatorar parser SSE          4/6 · 2:41   │
│ Executando: rodando testes                    │
│ ┌──────────┐            ┌───────────────┐    │
│ │  Parar   │            │  Escolher…    │    │  ← só quando a ação
│ └──────────┘            └───────────────┘    │     existe no model
└──────────────────────────────────────────────┘
```
- Cada botão = App Intent MECÂNICO (arquivo único `AtlasLiveActivityIntents.
  swift`; canon: encanamento de botão, jamais anunciado como Siri/voz).
- "Parar" → cancel do turno (fluxo existente); "Retomar" → retryTurn
  (failed+retryableJobId); "Escolher…" → abre o app DIRETO no
  ExecutionStateCard da sessão (deep link existente + scroll).
- Botão sem ação real no model NÃO RENDERIZA (lei). Falha do intent → a
  activity mostra o erro honesto 3s. Prova: device físico apenas.

## SD-4 · REPLAY — o scrubber de auditoria (M99)

```
┌─ REPLAY · Refatorar parser SSE ──────────────┐
│ [plano 3/6 ▓▓▓░░░]  ‖ pausado em 1:47        │ ← estado RECONSTRUÍDO
│ ▸ Executando comando: swift test              │    no instante t
│   (12s · concluiu +34s)                       │
│ ○━━━━━━●━━━━━━━━━━━━━━━━━○  1:47 / 10:48     │ ← scrubber (occurred_at real)
│ ⏮  ◀◀ passo   ▶ play ×1/×4   passo ▶▶  ⏭    │
└──────────────────────────────────────────────┘
```
- Fonte: EXCLUSIVAMENTE a timeline persistida (stream_events/atividades do
  ledger) — zero rede além do trace já carregado; zero inferência.
- Reconstrução por instante t: atividades com occurred_at ≤ t; presença/
  plano no estado que os eventos provam em t. Sem evento entre t1..t2 →
  o replay mostra o VAZIO real (o silêncio também é dado de auditoria).
- Play ×1 usa os deltas reais; ×4 comprime; Reduce Motion → stepper por
  passo, sem animação de playhead. A11y: scrubber ajustável
  (`accessibilityAdjustableAction`), cada instante anunciado.
- Entrada: botão "reproduzir" na ExecutionProof (turno terminal). Edge:
  trace legado sem timestamps completos → replay indisponível DITO.

## SD-5 · Widget de frota — estados honestos (M83)

| Condição do snapshot | Widget mostra |
|---|---|
| incident.present | flag + recommendedAction (alert) |
| sem incidente + scanned_at fresco | "frota íntegra · varrida há Xm" (healed) |
| sem varredura no snapshot | "frota não lida" (textTertiary — NUNCA verde) |
| snapshot > 6h | conteúdo + "visto há Xh" em destaque |
| sem snapshot | "abra o Atlas" (estado de instalação) |

## SD-6 · MODO AUDITORIA — o que densifica, por tela (M125)

| Tela | O que aparece a mais (tudo JÁ recebido, hoje oculto) |
|---|---|
| Conversa/cockpit | traceId copiável · sequence de cada evento · latência do create/refresh (medida no model) · schema_version dos contratos do turno |
| Timeline/passo | item_id · occurred_at ISO completo · kind cru do evento |
| Review | diff_hash por arquivo · run schema · recibos lifecycle (id+hash) |
| Autônomos | run_id do lock · lease TTL numérico · receipt hashes |
| Código | fingerprint de refs do grafo · rule_canon_ref completo · scan hash |
| Global | workspace_id da sessão · idade do read-cache · contagem de reconnects |

Regras: valores em `mono(10)` `textTertiary`, um toque copia (haptic .soft);
NUNCA um campo que exija novo dado do servidor; o toggle persiste local; o
badge "AUDIT" no masthead é o único cromo novo. VoiceOver: os campos são
`accessibilityHidden(false)` com label "dado de auditoria: …".

## SD-7 · Contrato do feedback por passo (M126)

```json
POST /ai/interactions/{trace}/step-feedback
{ "schema_version": "atlas.step_feedback.v1",
  "item_id": "…",              // o id estável do passo na timeline
  "verdict": "useful" | "noise" | "wrong",
  "note": "…opcional ≤280…" }
→ 200 { "ok": true, "receipt_hash": "…", "learning_status": "quarantined" }
```
Servidor: entra como sinal ARFL/AEMOR em QUARENTENA (G0) — jamais
auto-promove; o Judgment Guard decide o que o veredito prova. Casca: o passo
avaliado ganha ✓ discreto (estado local até o recibo; depois persistente via
re-fetch do trace SE o contrato ecoar os feedbacks — senão local-only, dito).
PHPUnit: quarentena, idempotência por (trace,item,operador), nota truncada.

## SD-8 · Lanes por agente — wireframe (M95)

```
│ ARQUITETO (dom azul)                                   │ ← faixa 2px + nome
│  ● Planejando a abordagem                    12s       │   mono(10)
│  ● Leu 3 arquivos                            8s        │
│ EXECUTOR (dom bronze)                                  │
│  ● Executando comando: swift test            41s ⚠p90  │ ← gargalo (M94)
│ REVISOR (dom verde)                                    │
│  ● Verificando o diff                        6s        │
```
Fonte: `activities` agrupadas pelo executor público do evento (job/agent já
presente no evento? verificar; se o evento não carrega o executor → pedir
§5 e, até lá, lanes só quando o mapeamento existir — nunca atribuição
inventada). 1 agente → layout atual intocado.

## SD-9 · Central "aguardando você" — wireframe (M139)

```
┌ AGUARDANDO VOCÊ · 3 ─────────────────────────┐  ← SÓ existe com count>0
│ ⚠ Escolher provider — turno pausado 12min    │  → ExecutionStateCard
│ ◆ Finding high: dead_symbol em AtlasFoo      │  → fluxo decide
│ ↩ Veto aberto: cura R2 expira em 28d         │  → recibo
└──────────────────────────────────────────────┘
```
Fontes REAIS: traces em attention (presença), backlog decide pendente,
undo_windows abertas. Ordenação por urgência real (deadline > idade).
Zero item = seção inexiste (lei do silêncio).

---

# ONDAS 15–18 · APROFUNDAMENTO v3 (M118–M140)

# ONDA 15 · Fora do app — segunda camada (M118–M124)

### M118 [M·fundação] Contrato do snapshot App Group (SD-1)
Implementar SD-1 ANTES de M83/M84/M85/M91/M121: writer atômico no app
(pontos: finalize do turno, refresh dos models, background), reader
fail-closed no widget, golden check compartilhado. É a fundação de toda a
Onda 11/15 — nenhum widget nasce antes dela.

### M119 [P·casca] Time-Sensitive para atenção real
`attention_required` e falha terminal → `interruptionLevel = .timeSensitive`
(fura Focus com a permissão certa). TODO o resto permanece `.active`.
Atenção é exceção — a lei do silêncio protege o privilégio.

### M120 [P·casca] Agrupamento e sumário de notificações
`threadIdentifier` por conversa (já parcial?) + `UNNotificationContent
.summaryArgument` — 5 turnos da mesma thread = 1 grupo digno, nunca 5
banners. Auditar todos os pontos de emissão.

### M121 [M·widget] Widget "sessão viva" na Home
Widget médio que segue a execução (fase + N/M + timer do snapshot; refresh
por push de LA quando M04 ativo, senão timeline). Botão "Seguir" =
App Intent mecânico que abre o app na sessão. Sem sessão viva → mostra a
última concluída com carimbo, ou "nada executando" editorial.

### M122 [P·casca+server] Live Activity da missão noturna
Proposta das 21h ACEITA → push-to-start (M93) abre a LA da missão da frota:
fase pública do ciclo + checkpoint. A noite trabalha NA LOCK SCREEN. Sem
APNs (M04) → LA local enquanto o app viver, honesto.

### M123 [P·widget] Refinos minimal/compact da ilha
Com 2 apps em LA (minimal): garantir símbolo de ESTADO (não logo genérico);
compact quando outra LA domina: leading/trailing mínimos legíveis. QA das
combinações com Música/Timer ativos.

### M124 [P·casca] Som e tátil próprios da atenção
`UNNotificationSound` custom sutil (assinatura sonora Ink&Brass curta) SÓ
para attention/falha; haptic pattern próprio no in-app (CoreHaptics leve).
Decoro: nunca para conclusões rotineiras.

# ONDA 16 · AX — segunda camada: o loop elite→agentes (M125–M131)

### M125 [M·casca] MODO AUDITORIA global
Toggle do operador (long-press no masthead ✦): TODAS as telas densificam
com o que JÁ chega e hoje fica oculto — traceId/hashes (mono, copiáveis),
latências por chamada do model, sequence dos eventos, workspace_id do pack.
NUNCA pede dado novo ao servidor: revela o metal já recebido. Persistido
local; badge discreto "AUDIT" no masthead enquanto ativo.

### M126 [M·server+casca] Feedback por passo → ARFL (o loop fecha no cérebro)
Long-press num passo da timeline → "útil / ruído / errado" + nota opcional.
Contrato: `POST /ai/interactions/{trace}/step-feedback {item_id, verdict,
note?}` → alimenta o ARFL/AEMOR do servidor (o sinal do operador-elite vira
aprendizado governado do ACOS — G0-G8 normais, nunca auto-promoção).
A casca marca o passo avaliado (✓ discreto). PHPUnit + prova live.

### M127 [P·casca] Execuções fixadas (pins de auditoria)
Long-press na ExecutionProof → "fixar como referência". Lista local de pins
(traceIds) acessível na conversa (chip "fixadas N"). Reabre pelo replay.
Local-only (UserDefaults via model — boundary ok), zero contrato.

### M128 [P·casca] Exportar auditoria
Do replay/prova: gerar Markdown provider-safe (passos, durações, decisões,
quality, hashes — EXATAMENTE o que a tela mostra) → share sheet do sistema.
O auditor leva a evidência para onde quiser. Zero conteúdo além do exibido.

### M129 [M·casca] Comparador de execuções
Duas execuções fixadas (M127) → lado a lado: passos alinhados por kind,
duração de cada, custo (M100 se existir), desvios destacados. A pergunta
"por que ontem levou 2min e hoje 9?" respondida com dados.

### M130 [P·casca] Heatmap de ferramentas da conversa
Agregado LOCAL das activities da conversa: quais tools, quantas vezes,
tempo somado (barra horizontal por tool). Leitura instantânea do perfil de
execução. Zero rede.

### M131 [P·casca] "Explicar este passo"
Long-press no passo → "perguntar sobre isto": abre o composer com turnFacts
do passo (comando sanitizado, arquivo, timing) — o fluxo ask existente (H6
da conversa). O agente explica o próprio passo com o determinístico no fio.

# ONDA 17 · Atlas Code — segunda camada (M132–M136)

### M132 [P·casca] Worktrees visíveis no grafo
O contrato E1 JÁ retorna `worktrees[]` — hoje invisíveis. Marcador discreto
nos nós com worktree + folha listando-os (path público/branch). Governança
da allowlist de worktrees (regra C24) ganha olhos.

### M133 [P·casca] Idade de branch efêmera com escalada visual
Refs fora da main com `when` antigo: 1–3d normal; >3d âmbar; >7d alert +
citação da lei (obra_return_deadline). O grafo cobra o retorno à main
sozinho — dados já presentes (refs+when).

### M134 [P·server+casca] "Commits deste turno" (proveniência reversa)
Contrato: `GET /api/code/commits-by-trace/{traceId}` (o ledger já liga
commit→trace; expor o índice reverso). Na ExecutionProof: chip "N commits"
→ abre o grafo ancorado neles. Execução↔Código fecham o círculo.

### M135 [P·server+casca] Blame por linha (why v2)
O contrato do why JÁ tem `line` opcional. v2: da folha de arquivo, ver os
hunks do commit (contrato de diff por arquivo — pedir §5 se ausente) e
long-press numa linha → why?line=N → o commit + frase daquela linha.
Depende do contrato de hunks; sem ele, permanece file-level.

### M136 [P·casca] Tags/releases como marcos no grafo
Refs de tag (já chegam em `refs[]`) → marco visual próprio (◆ contorno gold)
+ nome da tag na linha. A história ganha os seus capítulos.

# ONDA 18 · Autônomos — segunda camada (M137–M140)

### M137 [P·casca] Aging visual do backlog
Findings com `created_at` (se o DTO expõe; senão §5): >7d âmbar, >14d alert.
Backlog não pode envelhecer invisível — o decoro do sistema imune.

### M138 [P·casca] Comparador ensaio × execução
Mesmo finding com recibo de dry_run E de execute → folha comparando os dois
recibos públicos (o que o ensaio previu vs o que a execução fez). Confiança
no loop construída com dados.

### M139 [P·casca] Central "aguardando você"
Agregado POR EXCEÇÃO na AutonomosView: decisões pendentes (backlog decide) +
attention de traces + vetos abertos, numa seção única que SÓ existe quando
count > 0. O operador-elite abre o app e vê o que é DELE em 1 olhada.

### M140 [P·server+casca] Série temporal da saúde da fila
Se o servidor retiver snapshots do task-health (§5): sparkline de
servable/claimed/blocked por dia. Sem série → o instantâneo atual (como hoje).

# ONDA 19 · A CONVERSA SUPREMA — segunda camada do coração (M141–M147)
*A tela mais usada merece a última milha. Tudo profundidade da rota
existente.*

### M141 [P·casca] Rascunho persistente por thread
Texto do composer sobrevive a sair/voltar da conversa e ao relaunch
(persistência via model — padrão outbox, por threadId). Rascunho existente →
composer nasce com ele + selo discreto "rascunho".

### M142 [M·casca] Editar e reenviar um turno
Long-press na SUA mensagem → "editar e reenviar": composer nasce com o texto
para ajuste; envio cria TURNO NOVO (nunca reescreve história — o ledger é
imutável) com referência visual "refinado de ↑".

### M143 [M·casca] Modelos de missão (templates locais)
Sheet no composer com os prompts frequentes do operador (locais, editáveis,
zero rede): "revisar o diff de …", "auditar o módulo …". Placeholder tap-to-
fill. Elite não redigita liturgia.

### M144 [P·casca] Citar trecho da resposta
Seleção/long-press num parágrafo do assistente → "citar no próximo turno":
o composer ganha o bloco citado (markdown >) + cursor abaixo. Diálogo
técnico com precisão cirúrgica.

### M145 [M·casca] Índice da conversa longa
Botão no chrome → outline overlay: um item por turno (1ª linha da pergunta +
estado do turno) → tap salta. Conversas de engenharia têm 50+ turnos; o
auditor navega por sumário, não por rolagem.

### M146 [P·casca] Marcador "novo desde a última visita"
A conversa lembra o último turno visto (local); ao reabrir com turnos novos,
linha divisória editorial "novo desde ontem · 3 turnos" + scroll até ela.

### M147 [P·casca] Teclado físico de elite
`UIKeyCommand`/shortcuts SwiftUI para quem pluga teclado no iPhone:
⌘↩ enviar · ⌘K limpar · ⌘F busca na execução (M103) · ⌘] próxima sessão
viva. Zero UI nova; poder invisível. (Teclado ≠ voz; canon ok.)

# ONDA 20 · CONFIABILIDADE DO RUNTIME AGÊNTICO (M148–M152)
*O que a elite exige de um cockpit: saber QUANDO o sinal caiu, nunca
descobrir depois.*

### M148 [M·casca] Watchdog de silêncio do turno
Turno `running` sem NENHUM evento novo há >90s → linha honesta no cockpit
"sem sinal há 1min30 · stream ativo" (o poll continua provando vida do
trace). Distingue "agente pensando" de "conexão surda". Dado 100% local
(timestamps já recebidos).

### M149 [P·casca] Reconexão visível
`InteractionRun` já reconecta com backoff (máx 4); a casca hoje não conta.
Banner discreto "reconectando · 2/4" durante a janela (evento do run →
model → view). Sumindo ao reconectar. A elite nunca fica no escuro.

### M150 [P·casca] Qualidade de caminho no cockpit
`NWPathMonitor` (já usado em M43): caminho constrained/expensive → glifo
discreto no ExecutingStrip ("rede limitada"). Explica lentidão sem culpar o
agente.

### M151 [P·casca] Escalada de espera de decisão
`awaiting_user_choice` há >10min → UMA notificação time-sensitive de
lembrete ("um turno espera sua decisão há 10min") — usa M119. Nunca repete;
respeita o silêncio depois.

### M152 [P·casca] Rascunho de decisão
Na folha de choice/decide, o texto digitado sobrevive a fechar a folha
(mesmo padrão do M141). Decisões pensadas não se perdem por um gesto.

# ONDA 21 · CRAFT — a última milha visual (M153–M157)

### M153 [P·casca] Transições numéricas
`contentTransition(.numericText())` em TODO timer/contador (ilha, cockpit,
LiveNow, frota). Números que rolam, não piscam. Reduce Motion → troca seca.

### M154 [P·casca] Tabular numbers auditoria global
`monospacedDigit()` conferido em todos os relógios/contadores (o layout não
respira quando o número muda). Varredura + snapshot tests (M40).

### M155 [P·widget] Ícones alternativos do app (iOS 18)
Variantes dark e tinted do ✦ Ink & Brass (a Apple recorta mal ícones não
preparados). Fora do app = liberado; a marca digna em qualquer Home.

### M156 [P·casca] Continuidade launch→primeira tela
O launch screen (slate) deve encaixar SEM pulo no masthead: medir o gap
visual do primeiro frame e alinhar (mesma cor, mesma posição do ✦ se
adotado no launch). Percepção de <400ms começa aqui.

### M157 [M·casca] Auditoria global de motion/haptics
Mapa único de todos os haptics e animações (doc curto no canto canônico):
cada gesto → resposta. Corrigir inconsistências (ex.: sheets com curvas
distintas). O tato do app vira sistema, não acidente.

# ONDA 22 · MULTI-WORKSPACE NO APP — a rede ADN chega à casca (M158–M160)

### M158 [M·casca] Chips de workspace na home
CONVERSAS filtrável por workspace (chips com contagem real, dim dos demais —
padrão âncora). A elite com 5 repos ativos separa contextos num toque.
Zero rota — é filtro da lista existente.

### M159 [P·casca] Identidade visual por workspace
Cor de domínio estável por workspace (hash → paleta dom*) aplicada como
filete fino na ThreadRow/LiveNow. O olho aprende "azul = atlas-native".

### M160 [P·server+casca] O pack visível (Modo Auditoria)
No Modo Auditoria (M125), o turno mostra o `context_pack_hash` que o cérebro
usou (SE o contrato do trace o expor — §5; a infra AOBG já o injeta nos
prompts). O auditor correlaciona resposta ↔ contexto servido — a ponte
app↔ACOS fecha à vista.

---

# §KPIs — como medimos "supremo" (por frente, mensurável)

| Frente | KPI | Alvo |
|---|---|---|
| Fora do app | estado da execução visível SEM abrir o app | 0 taps (lock screen/ilha) |
| Fora do app | widget↔realidade | staleness visível sempre; zero dado falso |
| AX | tempo p/ localizar o gargalo de uma execução | < 5s (M94 destaque p90) |
| AX | reproduzir o que o agente via em t | possível p/ 100% dos traces com ledger (M99) |
| Conversa | retomar contexto após 1 dia fora | < 3s (M146 marcador + M145 índice) |
| Runtime | silêncio de sinal notado pelo operador | ≤ 90s (M148) — nunca "descobri depois" |
| Código | "o que o agente X fez esta semana" | 1 toque (M105 filtro) |
| Autônomos | o que aguarda o operador | 1 olhada (M139), badge por exceção |
| Craft | frames perdidos @120Hz nas telas vivas | 0 (baseline M03 mantido) |
| Rede | pack do workspace com docs+símbolos próprios | 100% dos repos registrados |

# §MATRIZ — frente do operador → itens

| Frente nomeada | Itens |
|---|---|
| Dynamic Island / lock screen | M86 M87 M88 M89 M119 M120 M122 M123 M124 M85 M91 SD-2 SD-3 |
| Home (fora do app) | M83 M84 M118 M121 M92 M155 SD-1 SD-5 |
| Atlas Code | M104–M111 M132–M136 (13ª e 17ª ondas inteiras) |
| Uso agêntico p/ programar | M07 M08 M11 M62 M141–M152 (conversa+runtime) |
| AX (ver/auditar/entender/melhorar) | M94–M103 M125–M131 M160 SD-4 SD-6 SD-7 SD-8 |
| Autônomos | M112–M117 M137–M140 M139/SD-9 M122 M93 |

# §ANTI-PADRÕES das superfícies externas (proibições específicas)

1. Widget com rede própria — PROIBIDO (só snapshot SD-1).
2. Timeline de widget "otimista" (dado velho sem idade) — PROIBIDO.
3. Live Activity que sobrevive ao turno sem fase terminal — viola C14.
4. Botão externo sem ação correspondente no model — lei do botão falso.
5. Update de LA por APNs sem debounce — orçamento do sistema esgota e a
   Apple degrada TODAS as activities do app (o bridge já tem debounce —
   preservar).
6. Notificação de rotina como time-sensitive — queima o privilégio; só
   attention/falha (M119).
7. Som custom em evento frequente — assinatura sonora é para exceção (M124).
8. Snapshot com classe de privacidade acima de `normal` — o App Group é lido
   por processos de widget; conteúdo sensível NÃO entra no snapshot.

---

# ONDA 10 · META — o processo que mantém tudo honesto (M76–M82)

### M76 [P·server] N8 + constitution-scan como agendamento
Quando o scheduler voltar (investigação em sessão paralela): scan diário +
baselines semanais agendados; regressão abre finding automático.

### M77 [P·ritual] Re-auditoria trimestral das 5 dimensões
Arquitetura/qualidade/UI/systems/evolução re-medidas com os mesmos critérios
desta era; notas + deltas registrados em evidence. Primeira: outubro/2026.

### M78 [M·build] `make verify`
Alvo único: checks + build + XCUITests do simulador numa tacada, exit
honesto. Vira o comando de pré-entrega de qualquer executor.

### M79 [P·ritual] Triagem semanal do backlog do scanner
Findings do constitution-scan: cada um vira fila §4 com owner OU é morto com
razão registrada. Backlog parado >7d = incidente de processo.

### M80 [P·docs] Ledger único de decisões pendentes do operador
Seção fixa no OBRA (ou doc curto) com a tabela do §B deste plano — hoje as
decisões estão espalhadas. Atualizada a cada decisão tomada.

### M81 [M·regra] Prazo de validade do device-pending
Regra no OBRA §2: item DEVICE-PENDING >7 dias vira linha vermelha destacada
na fila §4 com dono=operador. Pendência honesta não pode virar paisagem.

### M82 [P·DECISÃO] Commitar os documentos de planejamento
SE aprovado: `git add docs/plano-sota-10-de-10.md docs/roadmap-proximo-
patamar.md docs/spec-proximo-patamar.md docs/plano-profundidade-total.md` +
commit `docs(obra)`. Eles são a memória da transformação.

---

## §C · ORDEM MESTRA RECOMENDADA (por dependência e alavancagem)

```
Onda 0 inteira (M01–M06)                        ← prova antes de código
M82 + M55 + M60*                                ← higiene documental de 1h
M07 → M08 → M09 (contratos que destravam)       ← server sprint 1
M15 (QA diário) + M62 (fila) + M11 (pílula)     ← casca sprint 1
M61* (Rivals)                                    ← assim que o operador decidir
M54 + M56 + M57 + M58 (a rede fica completa)    ← server+docs sprint
M10 + M64 + M12 + M13 + M14                      ← contratos sprint 2
M03-dependentes: M28→M31→M32→M34 (perf medida)   ← só com baseline
M35–M42 (qualidade) intercalado por arquivo tocado
M43–M48 (robustez) → M49–M52 (segurança)
M65 + M66 (produto — profundidade nas telas donas) ← fecha a onda 8
── PATAMAR SUPREMO (após M04 APNs + M03 baselines) ──
M118 (fundação snapshot — ANTES de qualquer widget)
M86 → M87 → M89 → M119 → M120 (ilha + lock screen — o rosto externo)
M94 → M95 → M96 → M99 → M125 (AX: duração, orquestra, plano×real,
                              REPLAY, Modo Auditoria)
M126 (feedback por passo → ARFL — o loop elite→cérebro; contrato §5)
M83 → M85 → M121 → M91 (widgets + StandBy)
M105 → M110 → M132 → M133 → M104 (Code: filtros, biografia+diff,
                                   worktrees, idade de branch, pan/zoom)
M113 → M114 → M139 → M117 (Autônomos: timeline, drill-downs, central
                            "aguardando você")
M127 → M129 → M128 (pins → comparador → export: a suíte do auditor)
── v4 (intercalar por frente, cada uma independente) ──
M141 → M146 → M145 → M144 → M142 → M143 → M147 (conversa suprema)
M148 → M149 → M151 → M150 → M152 (runtime confiável — o cockpit nunca mente)
M153 → M154 → M156 → M155 → M157 (craft final)
M158 → M159 (multi-workspace na casca) · M160 com contrato §5
Contratos §5 em paralelo: M93, M100, M106, M107, M109, M112, M116,
                          M122, M126, M134, M135, M140, M160
M76–M81 (processo) contínuo desde já
(* = aguarda decisão do operador, tabela §B)
```

## §D · DEFINITION OF DONE do plano inteiro

1. Onda 0: zero pendências de prova; N8 com números reais registrados.
2. Ondas 1–8: cada M com prova própria (PHPUnit/checks/XCUITest/screenshot/
   live) registrada em §7; zero botão falso criado; zero rota nova além de M61.
3. Onda 9: intocada, salvo critério satisfeito e registrado.
4. Onda 10: rituais rodando; ledger de decisões zerado ou atualizado.
5. Fechamento: re-auditoria (M77) confirma que as notas 10/10 se sustentaram
   ao FINAL das 82 — crescer sem regredir é o teste desta era.
