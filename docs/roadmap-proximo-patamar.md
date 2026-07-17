# Roadmap — O Próximo Patamar do atlas-native

> Decisões do operador em 2026-07-16, estruturadas para virar obras.
> Hierarquia: canon do operador > este roadmap > improviso. Cada item aqui
> vira spec executável própria (como `docs/plano-sota-10-de-10.md`) antes de
> qualquer código. Pré-requisito de tudo: o plano SOTA 10/10 concluído.

## Decisões canônicas (2026-07-16)

- **Voice Supremacy: REMOVIDA do roadmap.** Futuro distante. Nenhum microfone,
  nenhum LiveKit parcial, nenhuma affordance de voz entra em obra alguma até
  decisão nova do operador. (Reforça o veto que o OBRA §4 já declarava.)
- **Lista aprovada para estruturação** (abaixo, P1–P10).
- **Agent Cockpit: em avaliação** — explicação entregue ao operador; aguarda
  decisão de entrada na lista.
- **Prioridade declarada pelo operador:** Self-Construction na casca é o item
  mais importante da lista. Presença Ambiental (fluxo das 21h) é desejo forte
  e entra como primeira vertical de baixo custo.

---

## A lista estruturada

Formato por item: **Tese** (uma frase) · **Estado hoje** · **Contratos
necessários** (server ⇄ core ⇄ casca) · **Dependências** · **Tamanho**.

### P1 · Presença Ambiental — v1 "A Proposta das 21h" ⭐ detalhada abaixo
- **Tese:** o app entende o contexto físico do operador (hora, rotina) e
  propõe, no momento certo, pôr a frota para trabalhar enquanto ele descansa.
- **Estado hoje:** zero. Mas TODOS os blocos de execução já existem
  (Autônomos `startRun`, digest C19/C20 parcial, notificações, Live Activity).
- **Tamanho:** P (a v1 é composição de contratos existentes + 1 contrato novo).
- **Dependências:** nenhuma dura; melhora com C19 (digest) fechado.

### P2 · Self-Construction na casca ⭐ MAIS IMPORTANTE (canon do operador)
- **Tese:** o Atlas propõe e entrega melhorias NO PRÓPRIO APP — detecta o
  problema (hitch, tela lenta, fluxo com atrito), escreve o fix, prova nos
  gates, apresenta o recibo; o operador tem veto retroativo, nunca portão.
- **Estado hoje:** o padrão inteiro já existe PARA REPOSITÓRIOS no Atlas
  Código E4 (heal → step_receipts → undo governado). Self-Construction OS é
  coluna vertebral do Atlas no server. Falta apontar esse motor para o
  próprio atlas-native.
- **Contratos:** (server) missão de auto-melhoria com workspace=atlas-native,
  política `observe|heal` por categoria de mudança (perf/polish/fix), recibo
  com evidência de gate (checks+build+screenshot) e `undo_ref` por commit;
  (core) DTOs do recibo de auto-construção; (casca) superfície "o app se
  melhorou" — card com diff, prova e veto, no padrão do Recibo de Cura.
- **Fonte de sinal para a v1:** os baselines N8/F5 do plano SOTA (regressão de
  performance detectada → missão de correção nasce sozinha) + achados de
  auditoria pendentes.
- **Dependências:** plano SOTA F5 (baselines como detector); Atlas Código E4
  como molde. **Tamanho:** M.
- **Regra de segurança:** auto-mudança na casca passa pelos MESMOS gates de
  qualquer agente (checks, build, XCUITest, screenshot) + categoria `heal`
  limitada por allowlist de tipos de mudança; mudança de comportamento de
  produto exige `observe` (propor, não aplicar) até o operador promover.

### P3 · Artifacts & Proof completo
- **Tese:** todo turno que produz artefato (arquivo, diff, screenshot, doc)
  o expõe como cidadão de primeira classe — ver, abrir, comparar, aprovar.
- **Estado hoje:** change review C15/C16 shipado (diff por trace, aceite por
  arquivo); `ExecutionProof` mostra passos/decide/quality. Falta: galeria de
  artefatos por turno, preview inline (imagem/markdown/pdf), diff visual fora
  do review, screenshot de execução como evidência navegável.
- **Contratos:** (server) manifesto de artefatos por trace (id, kind, size,
  hash, url trace-scoped); (core) DTO + fetch com validação; (casca) galeria
  + previews. **Dependências:** nenhuma. **Tamanho:** M.

### P4 · Continuity total
- **Tese:** o Atlas está presente em toda superfície do sistema — Siri/App
  Intents ("como está a frota?"), Share Extension (mandar qualquer coisa pro
  Atlas), StandBy, Action Button, widgets de Home.
- **Estado hoje:** Live Activity + Dynamic Island + deep link shipados; push
  remoto APNs implementado aguardando credencial no cofre.
- **Contratos:** quase tudo é casca/OS (App Intents expõe os seams que já
  existem: `session.threads`, `autonomos.fleet`, `startRun`). Share Extension
  precisa do engine de rich input (já único — C3).
- **Dependências:** credencial APNs (operador). **Tamanho:** M.

### P5 · Atlas-wide
- **Tese:** o app deixa de ser só engenharia — agenda, saúde, decisões,
  capturas, busca universal: a superfície cognitiva única no bolso.
- **Estado hoje:** zero no nativo (o server tem os domínios).
- **Contratos:** por domínio, mesmo molde provider-safe do Autônomos (DTOs
  allowlist + model @Observable por domínio + rota própria).
- **Dependências:** decisão de escopo do operador (quais domínios primeiro).
  **Tamanho:** G (mas fatiável por domínio — cada um é vertical demonstrável).

### P6 · H1 — Blame semântico ("por que esta linha existe?")
- **Tese:** qualquer linha de código responde com a frase de intenção
  original do operador, vinda do ledger — o fosso que nenhum SCM pode copiar.
- **Estado hoje:** proveniência POR COMMIT shipada (C23). H1 é o refinamento
  por LINHA: `git blame` → hash → trace → frase.
- **Contratos:** (server) `GET /api/code/why?repo=&file=&line=` (blame +
  ledger join, provider-safe); (core) DTO; (casca) ação "por quê?" na folha
  de arquivo do commit. **Dependências:** C23 (feito). **Tamanho:** P/M.

### P7 · H9 — Futuro fantasma (dry-run como imagem)
- **Tese:** antes de aprovar, VER o futuro: o grafo renderizado com os nós
  que passarão a existir se o plano executar — fantasmas tracejados.
- **Estado hoje:** grafo M0 shipado; `execution_plan` C10 dá os passos; nada
  de projeção visual.
- **Contratos:** (server) dry-run que emite `ghost_nodes[]` (commits
  previstos: mensagem provável, arquivos alvo — honesto: previsão marcada
  como previsão); (casca) camada fantasma no grafo com gramática visual
  própria (tracejado, nunca cor de estado real — previsão ≠ fato).
- **Dependências:** grafo M0 (feito), C10 (feito). **Tamanho:** M.

### P8 · Anel Nativo N1–N8
- **Tese:** usar o hardware Apple como diferencial físico: Metal Graph Engine
  (1.000 nós @120fps), espelho git on-device (libgit2 — governança em modo
  avião), triagem no Neural Engine, assinatura na Secure Enclave + Face ID,
  gramática háptica, cold launch <400ms como lei.
- **Estado hoje:** N8 (performance como lei) nasce no plano SOTA F5. O resto
  é greenfield.
- **Ordem interna recomendada:** N8 (já no SOTA) → N4 Secure Enclave (casa
  com slide-to-sign/H2 futuro) → N1 Metal (quando o grafo precisar de
  pan/zoom real) → N2 libgit2 (quando offline importar) → N3/N5/N6/N7.
- **Atenção à lei do repo:** libgit2 seria a PRIMEIRA dependência externa —
  exige decisão registrada em OBRA §6 com justificativa. **Tamanho:** G
  (fatiável por N).

### P9 · Memória de critério do operador
- **Tese:** cada veto, aceite e decisão de risco treina o critério local; o
  Atlas passa a pré-decidir o que você decidiria e só acorda você para o
  inédito. KPI: decisões que você NÃO precisou tomar.
- **Estado hoje:** as decisões já são recibos no ledger (decide de findings,
  aceites de review, undos). Falta o loop de aprendizado e a projeção
  "pré-decidido por critério aprendido, veto disponível".
- **Contratos:** (server) modelo de critério por categoria de decisão +
  recibo "auto-decidido por critério v N, baseado em suas M decisões
  anteriores" (transparente e auditável); (casca) fila de pré-decisões com
  veto em lote. **Honestidade:** pré-decisão NUNCA silenciosa — sempre
  visível com a regra que a gerou. **Dependências:** volume de decisões reais
  (P3/cockpit geram). **Tamanho:** M/G.

### P10 · Contratos por geração, não por pinagem
- **Tese:** DTOs Swift GERADOS do schema do servidor — drift deixa de ser
  detectado (golden checks) e vira impossível. + fuzzing dos decoders
  fail-closed.
- **Estado hoje:** pinagem por fixtures (excelente, mas manual).
- **Contratos:** (server) schemas exportáveis por endpoint (o Laravel já
  versiona `atlas.*.v1`); (tooling) gerador schema→Swift rodando como check;
  property-based tests dos decoders com payloads adversariais.
- **Nota:** infra, não produto — sequenciar em janela de manutenção.
  **Tamanho:** M.

### P0 · Cockpit como POSTURA PADRÃO do app (APROVADO 2026-07-16)
- **Tese:** o cockpit não é uma tela — é o que o app VIRA quando há trabalho
  vivo. Duas posturas: **nada vivo** → home editorial intenção-primeiro
  (exatamente a de hoje; "saudável = silêncio"); **qualquer sessão viva** →
  a home se reorganiza: seção "VIVO AGORA" no topo (cada sessão interativa
  com fase real, agente ativo, timer do servidor), regência a um toque,
  linha de exceção da frota abaixo. A conversa vira o drill-down de uma
  sessão, não o centro do app.
- **Por quê:** cada turno do Atlas JÁ é uma orquestra (plano/agentes/tools/
  gates renderizados) — chat-primeiro é herança da era chatbot, como
  buffer-primeiro era herança da era da digitação. O supervisor abre o app
  para pedir OU para reger; a home deve servir as duas posturas.
- **Fatia 1 — postura adaptativa (ZERO contrato novo):** promover os seams
  existentes — `TurnPresence.runningTitles` (hoje vira só o ◆ na ThreadRow),
  `currentExecutionPresence` tipada, `trace.jobs` — para a seção "VIVO
  AGORA" da home. Deep link da Live Activity pousa no contexto do cockpit.
  Casca pura. **Tamanho:** P.
- **Fatia 2 — regência completa:** pausar sessão, redirecionar agente no
  MEIO do run (steering — contrato novo no servidor: a fila C11 só enfileira
  para depois do turno), escolher (já existe via
  `resolveExecutionChoice`), comparar propostas de agentes lado a lado.
  **Tamanho:** M.
- **Guardrail canônico:** NÃO absorve os Autônomos — a frota 24/7 mantém
  superfície própria (aviso do OBRA §4); o cockpit mostra sessões
  interativas + a exceção da frota com link para o Command Center.
- **Sinergia:** alimenta P9 (cada regência é dado de critério).

---

## P1 detalhado · Presença Ambiental — "A Proposta das 21h"

> O cenário canônico do operador: às 21h o Atlas sabe que o dia dele está
> terminando e propõe: "quero rodar os Autônomos esta noite em cima do que
> você trabalhou hoje". De manhã, o resumo do que foi feito.

### As leis desta vertical (herdam a constituição)

1. **Sinal físico fica no aparelho.** Hora, rotina, uso — processados
   on-device; o servidor recebe só a consequência (a missão proposta/aceita),
   nunca o sensor. Soberania.
2. **Proposta é proposta.** Nada roda sem o toque do operador na v1. O botão
   de aceitar dispara o contrato governado que JÁ existe
   (`startRun(mode:operatorActor:operatorReason:)` — ator: operador, motivo:
   "missão noturna aprovada às 21h").
3. **Uma proposta por noite, zero insistência.** Ignorou = silêncio até
   amanhã. Estado por exceção vale para notificação também.
4. **Conteúdo real ou nada.** A proposta nomeia área/foco REAIS derivados do
   dia (threads/workspace tocados hoje — o app sabe localmente; obra ativa —
   o server sabe). Sem trabalho detectado no dia → proposta não existe.
5. **A manhã só fala se houver fato.** O resumo de acordar usa o digest
   governado (C19/C20) — entregas comprovadas, riscos, decisões pendentes.
   Noite sem resultado → "a frota não produziu resultado novo" (honesto),
   nunca silêncio constrangedor nem número inventado.

### v1 — Janela aprendida + proposta + manhã (a fatia demonstrável)

**Detecção da janela (on-device, sem permissões novas):**
- O app registra localmente (UserDefaults/arquivo, nunca servidor) o horário
  da última interação de cada dia. Mediana móvel de 7 dias = "fim do dia
  aprendido". Fallback: ajuste manual em Configurações ("meu dia termina ~21h").
- Gatilho: notificação local agendada para a janela aprendida
  (`UNCalendarNotificationTrigger`), reagendada diariamente.

**A proposta (notificação + card):**
- Corpo: "Seu dia costuma terminar agora. Hoje você trabalhou em
  [workspace/área real]. Quero pôr os Autônomos para melhorar isso durante a
  noite — ensaio ou execução?"
- Tocar → abre card na rota Autônomos com a área pré-selecionada, o foco
  derivado do dia visível e editável, e os dois botões que já existem
  (dry_run default / execute com ator+motivo). Recibo `enqueued` mostrado
  como "na fila · ainda não iniciado" (lei C13 existente).
- Novo contrato mínimo (server): `POST /autonomos/nightly-proposal` NÃO é
  necessário na v1 — a proposta é montada no app com dados que ele já tem
  (threads do dia) + `model.areas` existente. Zero endpoint novo na v1.

**Durante a noite:** a missão é uma missão Autônomos normal — Live Activity
apenas se o operador escolher "Seguir" (canon do Command Center); atenção
real fura por notificação (contrato C14 `attention_required`).

**A manhã:**
- Notificação na janela de início aprendida (mesma técnica, mediana da
  primeira interação do dia): "Enquanto você dormia: [headline real do
  digest]". Tocar → `AutonomosView.operationDigest` (já existe, parcial) —
  entregas comprovadas (`model.delivered`, só merges reais), pendências,
  decisões aguardando.
- Fecha C19/C20 (digest agendado + `next_digest_at`) como parte desta
  vertical — o pedido já está ABERTO no OBRA §5.

**Prova da v1 (gate):** device físico — o operador recebe a proposta na
janela real do seu dia, aceita um dry_run, e de manhã recebe o resumo com
conteúdo real. Screenshot dos três momentos em `docs/evidence/`.

### v2+ (só depois da v1 provada)
- **Focus/Sono:** entitlement `com.apple.developer.focus-status`
  (INFocusStatusCenter — booleano de foco, com permissão) e/ou janela de sono
  do HealthKit (permissão explícita) para substituir a heurística de horário.
- **Localização grosseira** (casa vs fora) para calibrar a manhã.
- **StandBy:** a proposta e o digest como cartões de mesa de cabeceira.
- **Integração com P9:** aceites/recusas da proposta treinam o critério
  (semana em que você recusou toda noite → a proposta muda de forma ou cala).

### Sequência recomendada da lista inteira

```
(pré) Plano SOTA 10/10 concluído + provas físicas
 1. P0  Cockpit postura v1           (P — home adaptativa; ZERO contrato novo)
 2. P1  Presença Ambiental v1        (P — a Proposta das 21h)
 3. P3  Artifacts & Proof            (M — fundação de prova p/ tudo)
 4. P2  Self-Construction na casca   (M — o mais importante; usa N8 do SOTA)
 5. P6  H1 Blame semântico           (P/M — fosso defensivo)
 6. P0  Cockpit regência completa    (M — steering; alimenta P9)
 7. P4  Continuity total             (M — presença em todo o sistema)
 8. P9  Memória de critério          (M/G — precisa do volume de 4/6)
 9. P7  H9 Futuro fantasma           (M)
10. P8  Anel Nativo (por N)          (G — puxado pelo produto)
11. P5  Atlas-wide (por domínio)     (G — a expansão final)
    P10 Contratos por geração        (infra — janela de manutenção, qualquer hora)
```

Racional: as duas posturas do app primeiro (P0 v1 + P1 — ambas P, ambas
recombinação de seams existentes, e juntas mudam a CARA do produto: o app
que se reorganiza quando há trabalho vivo e que propõe a noite às 21h).
Depois as fundações que os outros consomem (P3 prova, P2 motor, P6 fosso),
a regência quando o steering existir, e os patamares G fatiados por último —
cada um entra como vertical demonstrável no device, nunca como "fundação
pra depois".
