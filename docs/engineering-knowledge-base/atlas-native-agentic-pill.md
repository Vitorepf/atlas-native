---
doc_schema: atlas_canonical_module_doc.v1
id: atlas-native-agentic-pill
type: engineering_knowledge
title: Atlas Native — Pílula agêntica (baseline, não “avançado”)
status: active
implementation_state: code_home_grafo_arena_partial_pack_pending
owner: operator (Vitor)
priority: 99
category: native
risk_level: high
graph_id: atlas-native-agentic-pill
graph_title: Pílula agêntica
graph_world: atlas
graph_layer: surface
graph_kind: contract
graph_parent: atlas-native-overview
graph_status: active
graph_source: repo
human_name: Pílula agêntica
human_summary: >-
  Órgão vital do app: intenção humana em linguagem natural com contexto
  perfeito compilado da tela. Isto é o mínimo do produto na era agêntica —
  nunca “fase avançada”.
human_what: Contrato canônico da pílula em toda superfície Atlas Native.
human_purpose: >-
  Impedir que IAs tratem a pílula como botão opcional ou polish. Sem pílula
  com contexto compilado, a superfície não está na era agêntica.
human_input: Tela ativa + âncoras (commit, motor, run) + intenção falada.
human_output: Resposta OU ação (governada) no contexto daquela superfície.
human_change_when: Mudar gramática da pílula, contexto por superfície, ou escopo ask/do.
human_block_when: >-
  Bloqueie ship de superfície nova/reformada sem pílula contextual, ou com
  contexto misturado de outra tela.
canonical_name: Atlas Native Agentic Pill
technical_name: AgenticPill
summary: >-
  Na era agêntica o humano direciona; o agente faz. A pílula é o único verbo
  primário de intenção. Contexto = pack compilado perfeito da ocasião
  (nada a mais, nada a menos). Perguntar → responde. Mandar → faz.
when_to_use:
  - Antes de qualquer trabalho de casca em Home, Workspace, Código/Grafo, Arena, Autônomos
  - Antes de mockup ou polish de superfície
  - Quando uma IA perguntar se a pílula é “nice to have”
trigger_signals: [pílula, ask pill, agentic, contexto compilado, linguagem natural]
tags: [agentic, pill, context, conversation-supremacy, casca]
capabilities:
  - intencao_linguagem_natural
  - contexto_compilado_por_superficie
  - perguntar_e_mandar_fazer
decisions:
  - Isto é baseline / MVP da era agêntica — nunca rotular como “avançado”.
  - Toda superfície operacional carrega a pílula; Arena sem pílula = falha de produto.
  - Contexto não mistura telas; âncora refina, não troca de mundo.
maintenance:
  - Atualizar matriz de superfícies quando nascer superfície operacional nova.
  - OBRA.md §6 vence se houver decisão mais nova do operador.
repo_paths:
  - App/Atlas/AtlasCodeView+AskPill*.swift
  - App/Atlas/RootView+InputBar*.swift
  - App/Atlas/WorkspaceView+ChromeNewPill*.swift
related_paths:
  - OBRA.md
  - docs/engineering-knowledge-base/atlas-native-overview.md
  - docs/atlas-codigo-evolucao.md
  - docs/rich-input-shared-core.md
depends_on:
  - atlas-native-overview
flows_to:
  - atlas-native-overview
unlocks:
  - experiência agêntica coerente em todas as superfícies
governs:
  - presença, contexto e verbo da pílula no atlas-native
allowed_changes:
  - Expandir packs de contexto por superfície com prova
  - Portar pílula para superfícies que ainda não têm (Arena)
forbidden_changes:
  - Remover a pílula de superfície operacional
  - Dumpar contexto de outra tela
  - Tratar a pílula como decoração ou CTA genérico
  - Chamar este contrato de “fase avançada” / “nice to have”
evidence:
  - OBRA.md §6 2026-07-20 (decisão operador)
  - App/Atlas/AtlasCodeView+AskPill*.swift (Grafo parcial)
required_tests:
  - XCUITest de abertura da pílula por superfície quando existir
quality_gates:
  - Superfície operacional nova/reformada sem pílula contextual = bloqueio de ship
failure_modes:
  - Doc fraca → IA omite pílula (falha 2026-07-20 na Arena)
  - Contexto misturado → resposta/ação no mundo errado
  - Só “perguntar” sem “fazer” → era agêntica incompleta
next_actions:
  - Mockup Arena com pílula + pack de contexto Arena
  - Portar casca Arena após OK visual
  - Fechar gaps de “mandar fazer” por superfície conforme governança
observability_signals:
  - presença da pílula em screenshots de prova por superfície
requires_evidence: true
---

# Pílula agêntica — o que É (baseline)

> **Isto não é avançado. Isto é o mínimo.**  
> Se uma IA ou um plano chamar isto de “fase 2”, “nice to have” ou “polish”,
> o plano está errado.

## 1. Por que existe

Na era agêntica o agente faz melhor, mais rápido e mais estruturado.
O humano **não compete em execução**. O humano:

1. **Quer** (vontade)
2. **Julga** (o que é bom / errado / importa)
3. **Direciona** (prioridade, risco, soberania)
4. **Fala** (intenção em linguagem natural)

A pílula é o lugar físico dessa função no iPhone.
A tela é o **mundo**. A pílula é a **porta**.

Sem pílula com contexto perfeito, a superfície é dashboard com IA grudada —
não é Atlas.

## 2. Lei pétrea (6 regras)

1. **Toda superfície operacional tem a pílula.**  
   Home, Workspace, Código/Grafo, **Arena**, Autônomos (quando superfície de comando).  
   Omitir = falha de produto (não “dívida visual”).

2. **Existe um único tipo visual de pílula.**  
   O chrome canônico é o da **home**: Liquid Glass / recessed, ✦ ouro com respiração,
   convite em Fraunces itálico ~16, fio de ouro artesanal (`RootView+InputBarContent`,
   mockup `docs/proposals/grok-home-v1.html`).  
   **Só muda o texto do convite** (e âncoras humanas, se houver).  
   Proibido: segunda família (borda mais gorda, mono na cara, pack visível, tamanho “quase”).

3. **Contexto = pack compilado da ocasião.**  
   Nada a mais, nada a menos.  
   Grafo do repo `atlas-native` → só gestão/contexto daquele grafo daquele repo.  
   Arena → só medição (frota, capacidades, corridas, scores, plano).  
   **Proibido misturar mundos.**

4. **Âncora refina; não troca o mundo.**  
   Swipe num commit no Grafo: o pack continua sendo o grafo daquele repo, **mais**
   o commit linkado com o contexto perfeito daquele nó.  
   Não vira “conversa genérica”. Não puxa Arena. Não dumpa o Mac inteiro.

5. **Perguntar → responde. Mandar → faz.**  
   “Qual o melhor motor pra programação com/sem Atlas?” → responde com o dado da Arena.  
   “Roda uma medição…” → inicia (respeitando governança: ator/motivo quando o contrato exige).  
   “Como está o status?” → status real.  
   Botões na tela (Rodar, Parar) são atalhos do mesmo verbo — **não substituem** a pílula.

6. **A pílula nunca some** enquanto a superfície estiver viva  
   (durante execução: escrever enfileira / age; não some a affordance).

## 3. O que é “contexto perfeito compilado”

Não é “mandar o JSON da tela”. É um **pack** curado:

| Campo | Significado |
|---|---|
| `surface` | qual mundo (code.graph, arena, home, …) |
| `subject` | identidade do mundo (repo key, measurement id, …) |
| `anchors[]` | refinamentos (commit sha, engine id, suite, run) |
| `facts` | só fatos necessários à intenção típica daquela tela |
| `absences` | o que não está medido / não existe — declarado, nunca inventado |

**Teste do artesão:** se remover um campo do pack e a resposta/ação ainda for correta e segura, o campo era ruído. Se faltar um campo e o agente inventar ou perguntar o óbvio, o pack estava incompleto.

**Superfície vs motor:** o pack **nunca** vaza na UI como `arena · agora · live`.
A pílula mostra só convite humano (ex.: “pergunte sobre esta medição”). O pack
é compilado por baixo — igual hash no Grafo.

### Exemplo — Grafo `atlas-native`

- Pack base: repo, branch/HEAD relevantes, sinal “sem retorno”, nós visíveis necessários.
- Swipe no commit X: pack base **+** commit X (mensagem, autor, tempo, lane, relação com main) — link explícito.
- A pílula mostra legenda humana do âncora; o agente age **sobre aquilo**.

### Exemplo — Arena

- Pack base: aba atual (Agora/Frota/Capacidades/Motor), motor selecionado, scores 0–10, estado live (idle/running/… ), alertas reais.
- Perguntas e ordens só sobre medição — nunca “explica o grafo do código”.

## 4. Matriz de superfícies (baseline)

| Superfície | Pílula | Pack | Estado 2026-07-20 |
|---|---|---|---|
| Home | “Escreva ao Atlas” → picker/nova conversa | intenção geral / workspace | parcial (partida) |
| Workspace | pílula nova conversa | área/workspace | parcial |
| Código / Grafo | “pergunte sobre este repositório” + âncora | repo + âncoras de commit | parcial (ask leitura; do limitado) |
| **Arena** | **obrigatória** | medição / frota / capacidades / live | mockup HTML com pílula (2026-07-20); casca Swift ainda ausente |
| Autônomos | conforme superfície de comando | frota/área | verificar |

## 5. Anti-padrões (proibido)

- Chamar isto de “avançado”, “v2”, “depois do MVP”.
- Entregar mockup/casca de Arena (ou outra superfície operacional) **sem** pílula.
- Dump de contexto (“manda tudo que a view tem”).
- Misturar Grafo + Arena + Home no mesmo pack.
- Pílula que só abre chat genérico e perde a ocasião.
- Só botões “Rodar/Parar” como verbo — sem caminho em linguagem natural.
- Mic / voz na pílula (voz fora do roadmap atual).
- Segunda família visual de pílula (chrome diferente da home).
- Pack interno vazando na UI (`arena · agora · live`).

## 6. Por que a documentação anterior falhou

A pílula aparecia espalhada (leis do Código, H6, home) como feature de superfície —
não como **órgão do produto**. IAs leram “Grafo tem ask” e “Arena tem Rodar” e
omitiram a pílula na Arena. Este doc fecha o buraco: **uma lei, todas as superfícies.**

## 7. Relação com outros docs

- `OBRA.md` §6 — decisões do operador (vence em conflito).
- `docs/atlas-codigo-evolucao.md` lei 7 — pílula nunca some (Código); este doc generaliza.
- `docs/engineering-knowledge-base/atlas-native-overview.md` — overview aponta para cá.
- H6 “Mandar fazer” pode ter **gates de governança** (escrita, spend) — isso limita *como*
  faz, não *se* a pílula é o verbo.

## 8. Gate de ship (casca)

Antes de declarar uma superfície “pronta”:

1. Pílula visível e tocável.
2. Pack de contexto documentado (o que entra / o que nunca entra).
3. Pelo menos um caminho **perguntar** e um caminho **mandar** (mesmo que mandar
   abra fluxo governado).
4. Prova visual (screenshot) no device ou mockup aprovado com a pílula presente.
