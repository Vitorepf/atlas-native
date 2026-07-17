# Design — Atlas Native Elite Agêntica 24×7

> Canon de produto + leis de execução para o plano mestre
> `docs/plano-elite-agentica-24x7.md`.
> Hierarquia: **canon do operador > este design > plano > OBRA operacional > improviso.**

## Tese

O Atlas Native é o aplicativo nº 1 — e disparado — de programação agêntica
de altíssimo nível. O VS Code morreu porque foi feito para humanos
digitando. Nesta era, a IA escreve o código; o papel do ser humano
concentra-se em três atos e um não-ato:

1. **Intenção** — o que deve existir.
2. **Julgamento** — produto, preço, risco, trade-off quando o caminho bifurca.
3. **Assinatura** — publicação/destruição irreversível (gesto deliberado + recibo).
4. **Ausência (não-papel)** — “você não é necessário agora”; operação saudável
   não espera humano.

**Autonomia > aprovação.** Plumbing (commit, merge, heal, mirror, scan) nunca
pede “Aprovar”. O humano tem **veto retroativo com recibo**, não portão.
Autônomos roda 24/7; atenção é o recurso mais caro; silêncio é o produto.

## Leis permanentes (invioláveis)

1. **Zero rotas novas dentro do app.** Enum `Route` fecha em 9 casos
   (inclui `.arena`). Toda UX nova = seção/sheet/deepen nas superfícies
   existentes: Home, Conversa, Workspace, Busca, Autônomos, Arena, Código.
2. **Fora do app = liberdade.** Dynamic Island, Lock Screen, widgets,
   notificações, StandBy, Control Center, App Intents, ícones alternativos —
   todas as variações honestas são desejáveis.
3. **Humano fora do fluxo operacional.** Liturgia `ator+motivo` só para
   *iniciar* missão governada / Arena run / atravessar lanes — nunca por
   passo dentro de um loop já autorizado.
4. **Criação ≠ Medição.** Código da Criação nunca usa “Rivals”/“benchmark”;
   a tela chama-se **Arena**; servidor pode manter namespace Rivals.
5. **Ausência de contrato = ausência de UI.** Nunca fabricar progresso,
   merge, scoreboard, delivered ou prova.
6. **View ~200 linhas; arquivo ~300 = candidato a split.** Delete > add.
7. **Gates antes de todo commit:** `swift run AtlasCoreChecks` +
   `cd App && make build` (+ live/device quando o fatia exigir).
8. **Ciclo de obra obrigatório:** Implementar → Comprimir → Aprofundar →
   Comprimir (repete). Nenhum ciclo “aprofundar” sem compressão anterior
   verde.

## Superfícies congeladas (in-app)

| Route | Nome | Deepen permitido |
|---|---|---|
| (root) | Home | LiveNow, OPERAÇÃO, chips, sem sheet nova de domínio |
| `.thread` / `.new` | Conversa | Cockpit, estados C14, fila, review, artifacts, steer |
| `.workspace` / `.conversas` | Workspace | Filtros/listas |
| `.search` | Busca | Filtro real (já existe) |
| `.autonomos` | Autônomos 24/7 | Frota, ledger, digest, transfer, self-construction |
| `.arena` | Arena | Índice, AGORA, suites, capacidades, run sheet |
| `.code` / `.codeGraph` | Código | Radar, grafo, provenance, heal, why |

**Proibido:** Session Hub como rota; Voice/LiveKit; Siri conversacional;
Atlas-wide (agenda/saúde); iPad-first; nova rota “Rivals”.

## Superfícies livres (fora do app)

Catálogo-alvo ≈ 130+ variantes (ver plano §CICLO A / Onda F):
widgets frota/sessão/semana/arena · accessories lock · Live Activity
CONV/FLEET/ARENA/CODE · Island compact/minimal/expanded · notificações
por exceção · deep links honestos · APNs · StandBy · Controls · ícones.

## Resolução de tensões documentadas

| Tensão | Resolução canônica |
|---|---|
| “Nada roda sem toque” (nightly v1) vs autonomia | Toque = **início de política**, não approve de plumbing |
| Aceitar veredito vs 0 approve ops | Aceitar = julgamento de produto; ops = veto |
| Assinatura vs veto | Assinar = mundo; veto = trabalho local já feito |
| `attention_required` pausa | Exceção legítima; nunca caminho feliz |
| Face ID (M53) | Default SKIP até operador decidir |

## Definição de “feito” por fatia

Uma fatia só fecha quando: contrato tipado (se Core) · casca só projeta ·
golden check · build verde · ausência honesta se dado faltar · evidência
em `docs/evidence/` · linha em OBRA §7 · **device-proven quando a fatia
tocar presença/iPhone** (senão `device-pending` explícito, dono=operador).
