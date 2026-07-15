# Atlas Código — Especificação de Evolução v1

> **Para quem é este documento:** qualquer IA implementadora (Codex, Claude, Cursor, Gemini,
> MiniMax…). Ele é autossuficiente: contém tese, leis, contratos, payloads, geometria de UI,
> gates de prova e ordem de implementação. Se algo aqui conflitar com improviso seu, este
> documento vence. Se conflitar com o canon do operador, o canon vence — e este doc deve ser
> corrigido via OBRA.md §5.
>
> **Estado:** E0 concluída (proposta viva `docs/proposals/atlas-code-mobile.html` — tela M0,
> commit `aa01cfa`). Contratos C22–C25 registrados em `OBRA.md` §5.

---

## 0. Tese (o que é o Atlas Código)

- **Atlas Código é a camada de governança e operação de código do Atlas.** Substitui o
  GitKraken *como produto*; usa o git *como motor* (a mesma relação que o Atlas tem com os
  providers de IA).
- Não é um visualizador: **vê, julga, cura, espelha e aprende** — com recibo de tudo no
  ledger local.
- **Canon de autonomia (inviolável):** o Atlas commita e cura SOZINHO, 24/7. O Autônomos
  nunca depende de ninguém; o Forge commita até a obra completa. O humano tem **veto
  retroativo** ("desfazer, com recibo") — nunca é portão de aprovação. O papel do operador
  converge para *usuário que abre o app 1×/semana e sente a diferença*.
- **Todos os agentes trabalham na branch `main` local**, cada um com seus commits. Branch é
  exceção rara (IA que não conhece a regra, situação muito específica) — e por isso deve
  **saltar ao olho** no grafo.
- **Host remoto é adaptador, não fundação:** GitHub hoje, origin da Cursor amanhã, GitLab,
  self-host — espelhos trocáveis. A verdade mora no Mac (local-first). Abstrair por
  *trabalho* (espelhar, sincronizar, publicar), nunca por API de um host.
- **Confiança se conquista:** o mapa visual vem primeiro em toda superfície; resumo, callout
  e notificação são camadas por cima do visual, nunca substitutos.

## 1. Leis invioláveis (implementação que violar = rejeitada)

1. **Autonomia > aprovação.** Operação (commit, merge, branch, worktree, cura) nunca espera
   humano. Botão "Aprovar" para plumbing é proibido. Existe política por regra
   (`observe|heal`) e `undo` governado.
2. **Zero dado inventado.** Sem fonte real → o elemento **não existe** na tela. Nunca
   placeholder numérico, nunca barra de progresso fabricada, nunca "0" quando o dado é
   desconhecido (ausente ≠ zero).
3. **Visual primeiro.** Toda superfície mostra o MESMO mapa; a decisão/
   recibo é folha secundária por cima dele.
4. **Estado por exceção.** Saudável = silêncio absoluto (sem ✓ decorativo). Só a exceção
   fala.
5. **Um sinal primário por violação** (tag com o NOME da regra do canon) + um secundário
   (borda/anel). Nunca 3+ ênfases simultâneas.
6. **Linguagem humana na superfície; máquina embaixo do vidro** (a ≤2 toques: hash, diff,
   log existem, mas nunca como primeiro plano).
7. **A pílula de linguagem natural nunca some** de uma tela — inclusive durante execução
   (escrever enfileira, não interrompe).
8. **Decisão humana só para o que é do humano:** produto, preço, risco. Nunca para operação.
9. **Recibo para todo ato** (append-only, ledger local): detecção, cura, undo, espelho,
   release.
10. **main-only pétreo no atlas-server** (canon: `atlas-server/docs/engineering-knowledge-base/atlas-local-main-only-rule.md`).
11. **Craft system obrigatório** (seção 5 deste doc).

## 2. Arquitetura — 4 camadas

```
┌─ C4 · AUTONOMIA ──────────────────────────────────────────────┐
│  cura 24/7 · step_receipts · undo · guardrail no agente       │
├─ C3 · LEI ────────────────────────────────────────────────────┤
│  regras do canon → rules engine → violations[] anotando grafo │
├─ C2 · IDENTIDADE ─────────────────────────────────────────────┤
│  ledger/traces: commit → agente → frase do operador           │
├─ C1 · TOPOLOGIA ──────────────────────────────────────────────┤
│  git local: log --all --topo-order + refs + worktrees         │
└───────────────────────────────────────────────────────────────┘
```

- **Onde roda:** atlas-server (Laravel, no próprio Mac) expõe os endpoints; o app nativo
  (SwiftUI, repo `atlas-native`) consome. Foco exclusivo: o app nativo — sem superfície desktop no escopo.
- **Lanes da obra:** endpoints/motor = lane servidor (Codex ou quem o operador autorizar);
  decode Swift em `Sources/AtlasCore` = lane Codex; casca SwiftUI em `App/` = lane Fable.
  Fronteiras em `OBRA.md` §1 — quem não é dono não edita, pede via §5.

## 3. Fases E1–E5 (roadmap com gate por fase)

**Regra de progressão:** nenhuma fase inicia sem o gate da anterior provado no device, com
evidência registrada em `OBRA.md` §7. A direção é sempre *menos humano por fase*.

### E1 · Topologia real (contrato C22)

**Endpoint:** `GET /api/code/graph?repo=<slug>`

**Fonte (exata):**
```bash
git log --all --topo-order --parents --format='%H|%P|%an|%ae|%at|%D'
git worktree list --porcelain
```

**Resposta:**
```json
{
  "repo": "atlas-server",
  "generated_at": "2026-07-14T15:40:00-03:00",
  "head": "9a06fd4c56",
  "default_branch": "main",
  "nodes": [
    { "hash": "9a06fd4c56", "parents": ["4b2b61f974"], "refs": ["main"],
      "author_email": "…", "authored_at": 1784316000 }
  ],
  "worktrees": [ { "path": "/…/wt-9f2", "branch": "exp-schema", "head": "…" } ]
}
```

**Regras de implementação:** read-only; cache incremental (invalidar quando o conjunto
`git for-each-ref --format='%(objectname)'` mudar); limite default 200 nós + paginação por
`before=<hash>`; nunca executar comando de escrita neste endpoint.

**Casca (geometria canônica do grafo):**
- Lanes em grid x fixo (ex.: main=24, lanes seguintes +32px).
- **Curva de fork/merge com tangente vertical garantida** (a curva GitKraken):
  `M x1,y1 C x1,(y1+y2)/2 x2,(y1+y2)/2 x2,y2` — proibido control point arbitrário.
- Nó = disco pequeno (r≈5.5) na cor da lane + anel na cor do fundo (stroke 2). Sem gradiente
  radial em nó. Espinha da main = traço 3px com gradiente vertical
  (**`gradientUnits="userSpaceOnUse"`** — objectBoundingBox em linha vertical tem bbox de
  largura zero e fica invisível).
- Layout de linha (referência de densidade máxima): `Grafo | Mensagem+meta | Autor | tempo` — chips de ref
  nunca quebram linha (`nowrap`).

**Gate E1:** screenshot no iPhone lado a lado com `git log --oneline -20` no Mac — hashes
idênticos. Sem endpoint → a tela não entra no app.

### E2 · Identidade + proveniência (contrato C23)

- Enriquecer cada nó com `agent`: `{"kind": "fable|codex|voce|autonomo", "name": "forge-3"}`.
  Mapeamento: `author_email → agente` (tabela de config) + correlação com traces do ledger
  (o Atlas já carimba execuções com trace/recibo).
- `GET /api/code/provenance/{hash}` → schema `atlas.code.provenance.v2`:
```json
{ "schema_version": "atlas.code.provenance.v2", "hash": "683af18",
  "commit_message": "billing: comando para desligar a renovação",
  "commit_body": "Wind-down do faturamento sem tirar acesso de ninguém.\n\n…",
  "agent": "voce", "trace_id": "tr_…", "operator_quote": "identifica todos os erros…",
  "obra": ["obra-17"], "gates": ["checks exit=0", "device ✓"],
  "files": [ {"path": "app/Console/Commands/CancelAll.php", "status": "added",
              "additions": 160, "deletions": 0, "renamed_from": null} ] }
```
- Sem trace correspondente → **campo ausente** e a UI mostra "sem proveniência registrada".
- `files[]` vem de `git show --raw --numstat -M` (um comando, dois blocos casados por
  posição — o numstat escreve rename como `src/{a => b}.ts` e não serve de chave).
  `status` ∈ `added|modified|deleted|renamed|copied|type_changed`. Binário → `additions`
  e `deletions` **ausentes**: o Git não mediu, e ausência nunca vira `0`.
- `commit_body` é o raciocínio do autor. A tela reflui a quebra de 72 colunas
  (`AtlasCodeCommitBody.prose`) e **remove trailers** (`Co-Authored-By:`) — encanamento do
  Git que nomeia o motor não sobe à superfície.
- Totais (`7 arquivos · +457 −323`) são **derivados no app** (`diffHeadline`), nunca uma
  segunda fonte de verdade no servidor.

**Gate E2:** tocar em ≥3 commits reais mostra a frase real do operador vinda do ledger;
tocar num commit antigo sem trace mostra o estado honesto; a folha lista os arquivos
tocados com verbo e contagem conferíveis contra `git show --numstat` no Mac.

### E2.1 · Uma frota só (localizador de repositório)

O radar (M3 v2) lê o Mac; o grafo lia perfis do banco. O app listava 12 repositórios e
abria 3 — `nivor-back-end` respondia `404 repository_profile_not_found` com o nome que o
operador acabara de ver na tela.

- `AtlasCodeRepoLocator`: **perfil registrado vence** (slug canônico + config, é o que os
  gates consultam) → **senão o disco responde** (leitura é livre).
- `findByReference` **não** ganhou descoberta em disco de propósito: ele também decide
  governança (onboarding, workspace intelligence, code graph), e descoberta automática ali
  faria repositório não registrado passar por workspace governado. Leitura livre;
  autoridade continua registrada à mão.
- Slug ambíguo (dois produtos com repo de mesmo nome) → **silêncio**. Mostrar a história do
  repositório errado é mentira, e mentira é pior que erro numa ferramenta de governança.
- Slug é segmento de diretório: `..` e `/` nunca viram leitura de disco.

### E3 · A Lei — rules engine (contrato C24)

- Comando: `php artisan atlas:code:scan {repo}` (agendável; também disparado por fsevents/
  hook pós-commit). Função **pura** sobre o snapshot da topologia (testável sem git).
- `GET /api/code/violations?repo=` →
```json
[ { "id": "viol_…", "rule_id": "main_only", "rule_canon_ref": "atlas-local-main-only-rule.md",
    "target": {"type": "branch", "ref": "hotfix-rapido", "head": "…"},
    "since": "2026-07-14T02:41:00-03:00", "severity": "high",
    "plan": [ {"step": 1, "action": "cherry_pick_to_main", "params": {"hash": "…"}},
              {"step": 2, "action": "delete_branch", "params": {"ref": "hotfix-rapido"}},
              {"step": 3, "action": "cite_rule_to_agent", "params": {"agent": "forge-3", "rule_id": "main_only"}} ] } ]
```
- **Regras iniciais (5):** `main_only` (repos na allowlist pétrea), `worktree_allowlist`
  (paths permitidos), `obra_return_deadline` (branch de obra sem merge → main há > N dias),
  `orphan_branch` (branch sem commits há > N dias), `mirror_drift` (local × espelho).
- Toda violação nasce **com o plano de remediação já preparado** (lei do plano pronto).
- UI: tag pill com o nome da regra (nunca erro genérico); anel pulsante APENAS até a cura.

**Gate E3 (script de prova incluído na entrega):** num repo sandbox, criar branch cobaia →
violação aparece no app em <30s com `rule_id` correto; resolver → some. Nada hardcoded.

### E4 · Auto-remediação 24/7 (contrato C25)

- **Política por regra:** `observe` (só aponta — modo de rampa de confiança) | `heal`
  (executa sozinho — o alvo). Config do operador; UM switch por regra, nunca aprovação por caso.
- Executor de plano: ações permitidas por **allowlist** (`cherry_pick_to_main`,
  `delete_branch`, `merge_ff`, `stash_quarantine`, `cite_rule_to_agent`) — nada fora dela.
  Cada passo emite `step_receipt` no ledger: `{heal_id, step, action, started_at, finished_at,
  result, undo_ref}`.
- **Undo obrigatório:** toda ação guarda `undo_ref` (ex.: hash original, bundle da branch
  apagada) por ≥30 dias. `POST /api/code/heals/{id}/undo` reverte com recibo.
- `cite_rule_to_agent` grava guardrail na memória/knowledge do agente (aprendizado composto:
  a violação de hoje é a prevenção de amanhã).
- Push de estado ao app (o mesmo canal de presença/live já existente) para os ticks ao vivo.
- **UI:** a folha é **Recibo de Cura** (bottom sheet): kicker verde
  "CURADO SOZINHO · <regra> · <hora>", fato em serif, passos executados com ✓, linha
  "você não foi necessário", botão único `Desfazer — com recibo`. Sem botão de aprovar.

**Gate E4:** branch cobaia nasce num sandbox e é curada **sem toque humano**; `step_receipts`
conferíveis no ledger; `undo` restaura o estado anterior byte a byte.

### E5 · Prevenção + a semana

- **Guardrail pre-flight:** agentes consultam as regras ANTES de agir (bloqueio na origem —
  ex.: criação de branch no atlas-server já nasce negada com a regra citada).
- `GET /api/code/week?repo=|fleet` →
```json
{ "window": "2026-07-07..14", "commits": 214, "heals": 3, "prevented": 5,
  "waiting_for_you": 0, "by_agent": {"fable": 84, "codex": 96, "autonomos": 34} }
```
- Notificação por violação/cura via Presença (C14, já shipada) — **OFF por default**; o
  operador liga quando confiar. A autonomia nunca é opcional; a notificação sim.

**Gate E5:** o card "a semana" no app com números 100% derivados de dados reais; violações
prevenidas ≥ curadas ao longo de 2 semanas (a Lei migrando para a origem).

## 4. Horizontes H1–H6 (as fronteiras que nenhum SCM alcança)

### H1 · Blame semântico — "por que esta linha existe?" (prioridade máxima)
- **Por quê primeiro:** exige o ledger — nenhum cliente git tem essa fonte. 5/5 no filtro pétreo.
- `GET /api/code/why?repo=&file=&line=` → resolve `git blame -L {line},{line} --porcelain`
  → hash → E2 (trace → frase) → resposta:
```json
{ "line": "…código…", "hash": "683af18", "agent": {"kind": "fable"},
  "operator_quote": "identifica todos os erros de resposta…", "obra": "obra-17",
  "answer": "Esta linha nasceu do seu pedido de 14/07 para consertar os espaços colados…" }
```
- `answer` é composta por template + dados (sem LLM) na v1; via Open Brain na v2.
- UI: selecionar linha (review/diff) → folha com a cadeia linha→commit→obra→frase.
- **Gate:** 10 linhas aleatórias de arquivos recentes respondem com trace real ou o estado
  honesto "sem proveniência". Depende de: E1+E2.

### H2 · Do commit ao release
- O domínio engole o ciclo: obra → commits → cura → espelho → **build → publicação assinada**
  (slide-to-sign da Nova Era, tela 6). `release_receipt` no ledger (versão, varreduras,
  operador). Espelho/loja atrás de adaptador. Depende de: E4 + espelhamento governado (M5).

### H3 · A semana do código (frota)
- Agregação multi-repo do `/week`; hub mostra por exceção; drill por repo. Depende de: E5.

### H4 · Review agêntica no grafo
- `council_review` (posição por membro: provider, status, hash, latência — **sem raciocínio
  privado, sem veredito inventado**) já nasce no servidor (`AiCouncilCoordinator`, commit
  `9a06fd4c56` do atlas-server). Falta decode no `AtlasCore` + seção por commit no grafo:
  divergência = status distinto entre membros. Depende de: E2.

### H5 · Prevenção na origem (estágio final da Lei)
- Métrica-alvo: `violações/semana → 0` com `prevenidas > curadas`. O grafo permanentemente
  quieto é a vitória — quieto É o produto. Depende de: E4+E5 maduras.

### H6 · Perguntar sobre o código (⌘K / pílula)
- Open Brain sobre topologia+ledger+canon: "o que o forge-3 fez essa semana?", "por que essa
  branch existe?", "qual obra está mais atrasada?". Respostas com refs conferíveis (hash,
  recibo). No iPhone: a pílula (lei 7). Depende de: E1–E3; melhora com H1.

### H7–H12 · O anel do produto (resumo; detalhar quando destravar)

- **H7 · Grafo do PRODUTO:** o Atlas agrupa commits e responde "o que o app faz hoje que
  ontem não fazia" — capacidades, não hashes. *Depende: E2+E5.*
- **H8 · Grafo que cresce ao vivo:** intenção na pílula → obra nasce → commits brotando na
  espinha em tempo real (canal de presença C14, já shipado). *Depende: E1.*
- **H9 · Futuro fantasma:** antes de cura/merge/release, o grafo COMO FICARÁ em nós
  translúcidos — dry-run como imagem. *Depende: E4.*
- **H10 · Custo/valor por commit:** custo de motor + capacidade entregue = P&L de engenharia
  ("R$ 47 → 3 capacidades"). Ponte para gestão de empresas. *Depende: E2.*
- **H11 · Organismo multi-repo:** contrato mudou no server → decode nasce no app sozinho;
  violação nova "drift de contrato entre repos". *Depende: E4 madura.*
- **H12 · A noite falada:** o briefing por voz (LiveKit no ecossistema) — o Código sem tela.
  *Depende: E5.*

## 4½. Anel Nativo Absurdo — N1–N8 (só possível em Swift puro)

> **Por que existe:** o app é Swift puro para ser o mais rápido, mais confiável e mais
> próximo do hardware do iPhone — usando o máximo que o aparelho entrega. Isso é o MÍNIMO.
> Este anel é o que nenhum concorrente (Electron/RN/web) consegue seguir.

### N1 · Metal Graph Engine
O Grafo Governado renderizado em **Metal** (não Canvas): 120Hz ProMotion, milhares de nós,
zoom/pan com física de inércia, glow por shader. O grafo mais rápido do mundo, no bolso.
**Gate:** 1.000 nós a 120fps sustentados no device; hitch rate 0 (Instruments).
*Eleva: E1-casca.*

### N2 · Espelho git no aparelho
libgit2 embarcado: o iPhone guarda **espelho de leitura dos repos** (sync incremental via
BGTask). Grafo, blame e diff funcionam **offline total** — o iPhone vira nó do organismo.
**Gate:** modo avião → M0/M2/M4 funcionam com dado real local.
*Estende: E1 (fonte dupla: API do Mac + espelho local).*

### N3 · Inteligência on-device (Neural Engine)
Foundation Models/Core ML no aparelho: a pílula responde "por que essa branch existe?" e o
sumário da noite nasce **sem rede** — embeddings e busca semântica locais. Soberania extrema.
**Gate:** pergunta respondida em modo avião em < 2s.
*Eleva: H6, E5.*

### N4 · Assinatura na Secure Enclave
O release (H2) assinado com **chave que nunca sai do silício** + Face ID: slide-to-sign vira
ato criptográfico real, recibo verificável no ledger.
**Gate:** assinatura de release validável criptograficamente.
*Eleva: H2.*

### N5 · Gramática háptica
Core Haptics como linguagem: cura = pulso duplo suave; violação = textura áspera curta;
assinar = crescendo. O estado que se **sente** sem olhar — irmã tátil da gramática de cor.
**Gate:** mapa háptico por estado documentado + implementado; Reduce Motion/haptics respeitados.

### N6 · Sistema por toda parte
App Intents + Siri + Action Button + Atalhos ("Siri, como foi a noite do código?"), widgets
interativos (a Semana na home), e **StandBy noturno**: o iPhone carregando deitado vira o
painel da vigília — os commits da noite nascendo na mesa de cabeceira.
**Gate:** o intent responde com dado real; widget 100% fonte real.
*Eleva: E5, M6.*

### N7 · Zero-espera
BGTaskScheduler + push silencioso: tudo pré-carregado **antes do olhar**. Cold launch, sync
e digest prontos quando o polegar chega.
**Gate:** MetricKit no CI; cold launch < 400ms medido em device.

### N8 · Contratos de performance como lei (transversal, desde já)
| Métrica | Teto |
|---|---|
| Cold launch | < 400ms |
| Toque → folha aberta | < 100ms |
| Grafo (1k nós) | 120fps, hitch 0 |
| Memória em uso | < 150MB |
| Crash-free | ≥ 99,99% |
| Decode do snapshot do grafo | < 10ms |

Medidos por XCTest Performance + MetricKit; **regressão de performance = gate vermelho =
não commita**. Lento é bug, não detalhe.

**Encaixe na ordem:** N8 vale desde já (gate permanente); N1 junto com a casca do E1;
N2 após E1 provado; N3 com E5/H6; N4 com H2; N5–N7 transversais incrementais.

## 5. Design system (resumo executável — Ink & Brass)

**Tokens:**
```css
--bg:#0f161c; --app-bg:#1b2830; --surface:#223440; --recessed:#141f27;
--ink:#e6ebee; --ink2:#9aacb6; --ink3:#647682; --ink4:#465662;
--gold:#d4a85a; --gold-hi:#ecc984; --green:#83b46d; --red:#e08c8c; --blue:#82a8bd;
--hairline:rgba(255,255,255,0.065); --hairline-hi:rgba(255,255,255,0.12);
serif: Fraunces (editorial/página e títulos de folha) · sans: SF/-apple-system (todo chrome
de app) · mono: JetBrains Mono (APENAS hash/recibo/meta).
```

**Regras de craft (checklist de rejeição):**
1. Ícones SÓ de sprite único: `<symbol viewBox="0 0 16 16">`, stroke 1.5, round caps,
   `currentColor`. Proibido emoji/caractere como ícone (✦◆▲⚠ etc.).
2. Curva de grafo = fórmula do midpoint (seção 3/E1). Nós flat (disco+anel). Sem gradiente
   radial em elemento pequeno.
3. Chips de sistema: altura fixa, radius 6, `nowrap` — chip nunca quebra linha.
4. Avatares: squircle 24px superfície escura + ícone colorido 13px.
5. Materiais: hairlines nos dois tons acima; inset top-light; sombra em 2 camadas; vidro
   14–16px de blur.
6. **Performance é craft:** ZERO filtro SVG (feGaussianBlur trava compositor); glow = traço
   duplo (largo 10–15% embaixo + nítido em cima); animar só opacity/transform/dashoffset;
   física de mola nos nós: `cubic-bezier(0.34,1.45,0.5,1)`.
7. `font-variant-numeric: tabular-nums` em tempo/hash/contadores.
8. **Sinais de IA proibidos:** UI que se auto-narra; ✓ decorativo; ênfase redundante;
   legenda dentro do app; travessão em mensagem de app; abreviação torta; mono-uppercase
   como subtítulo iOS.
9. Componentes flutuantes (cápsulas de status) centrados e simétricos — nunca no canto.
10. Gotcha de prova: chrome-headless-shell inverte cores desta paleta em screenshot — usar
    Chrome for Testing (`~/Library/Caches/ms-playwright/chromium-*/…/Google Chrome for
    Testing`) para foto fiel; asserts de estado valem em qualquer engine.

**Padrões nomeados:** Grafo Governado (mapa) · Recibo de Cura (bottom sheet de fato
consumado + veto) · Radar (frota por exceção) · Proveniência (commit → frase) ·
Espelhamento governado (push com varredura) · A Semana (digest-usuário).

## 6. Segurança e reversibilidade

- Endpoints de leitura: sem efeito colateral, nunca tocam o working tree.
- Execução (E4): allowlist de ações; timeout por passo; `undo_ref` obrigatório; operador
  nomeado em todo recibo; logs no ledger append-only.
- Nada sai da máquina sem varredura de segredos (o espelho é sempre precedido do scan —
  padrão M5 da proposta mobile v1).
- Classes sensitive/secret/cyber nunca saem do Mac (canon de soberania).
- Provider-safe: recibos e payloads não expõem prompt/raciocínio interno de agentes.

## 7. Ordem de implementação e dependências

```
E1 ──► E2 ──► E3 ──► E4 ──► E5
        │      │       │     └─► H3 (semana/frota)
        │      │       └───────► H5 (prevenção — maturidade)
        │      └───────────────► H6 (⌘K v1 — melhor pós-H1)
        ├──────────────────────► H1 (blame semântico — PRÓXIMO GRANDE SALTO)
        └──────────────────────► H4 (review agêntica; precisa decode C21 no AtlasCore)
                       E4 ─────► H2 (release governado)
```

Racional: E1–E2 são leitura pura (risco zero, confiança pelo "eu preciso ver"); E3 julga sem
tocar; E4 age com undo; E5/H* compõem. H1 pode andar em paralelo após E2 — é o
diferencial que só o Atlas pode ter.

## 8. Definição de pronto (por fase/horizonte)

- [ ] Gates da casa verdes (typecheck/testes do repo tocado; no atlas-native: `swift build`
      + checks; no atlas-server: PHPUnit).
- [ ] Gate de honestidade da fase provado com evidência (screenshot/script) anexada em
      `OBRA.md` §7 (append-only).
- [ ] Zero mock/zero dado inventado em produto (a proposta HTML é o único lugar de encenação).
- [ ] Recibo/ledger para todo ato novo.
- [ ] Craft checklist (seção 5) sem violação.
- [ ] Fronteiras de lane respeitadas (`OBRA.md` §1); cruzou → pedido em §5.

## 9. Referências

- Proposta viva (contrato visual): `docs/proposals/atlas-code-mobile.html` (M0–M6)
- Blackboard: `OBRA.md` §5 (C22–C25), §7 (entregas com prova)
- Plano-mestre: `docs/proposals/atlas-codigo-plano.html`
- Canon pétreo: `atlas-server/docs/engineering-knowledge-base/atlas-local-main-only-rule.md`
- Governança de conhecimento: `../CLAUDE.md` (projeção Atlas; memória Atlas é canônica)
