# Missão noturna · Atlas Código E1–E5

## 2026-07-15 · Codex · E1 parcial

- Servidor: `GET /api/code/graph?repo=atlas-server&limit=2` respondeu `200` em
  instância nova do Laravel, com schema `atlas.code.graph.v1`, `head` real,
  dois nós de `git log`, worktrees, paginação e fingerprint de refs.
- Native: DTO estrito, cliente AtlasCore, geometria midpoint e tela M0 em
  SwiftUI Canvas foram implementados sem mock de produto.
- Gates: `swift run AtlasCoreChecks` verde; `cd App && make build` verde;
  PHPUnit direcionado verde (4 testes, 43 asserções); `git diff --check` verde.
- Nota operacional: a porta 3737 está ocupada por OrbStack e serviu uma versão
  antiga sem a rota; o probe com a instância nova em 3847 foi o que comprovou o
  contrato atual. O gate visual físico — abrir a tela no iPhone e comparar com
  `git log` — não foi executado nesta sessão.
- Decisão de vigília: E2–E5 não avançam até o gate de E1 previsto no contrato;
  não há claim de conclusão da missão.

## 2026-07-15 · Ciclo E1 fechado

- O simulador iPhone 17 Pro abriu M0 contra uma instância Laravel local da versão
  atual; a tela mostrou `atlas-server`, `main · 200 nós` e os prefixos dos hashes.
- Os 12 primeiros prefixos visíveis conferem byte a byte com `git log` e com o
  probe real do endpoint. Evidência: `docs/evidence/atlas-code-e1/`.
- `ATLAS_HOST=127.0.0.1` foi somente argumento de build para o simulador; nenhum
  segredo ou `.env` foi alterado. O gate físico segue `device-pending`.
- Próxima ação: E2 — correlação de autor, ledger e traces, com ausência honesta
  quando não houver proveniência.

## 2026-07-15 · Ciclo E2 fechado

- Backend C23 entregue: `GET /api/code/provenance/{hash}?repo=atlas-native` lê
  identidade Git real e somente projeta quote/obra/gates quando existem no ledger.
- Gate: três commits reais (`d0a65d0`, `838585d`, `e11b4e6`) foram consultados por
  hash completo; todos retornaram `agent=voce`, quote literal e `trace_id` ausente.
- A folha nativa é tocável e mostra `sem proveniência registrada` quando não há
  registro. O endpoint também foi exercitado no commit de servidor `b43e907daa`.
- Próxima ação: E3 — scanner puro, cinco leis e sandbox de branch.

## 2026-07-15T06:17Z · Ciclo E3 vertical

- O backend OrbStack recebeu um sandbox efêmero em `/tmp`; a tela nativa foi
  ligada por `ATLAS_CODE_REPO=sandbox:/tmp/atlas-code-sandbox-e3-container`.
- Prova: app mostrou `Grafo Governado`, dois nós e `Sinais de governança` com
  `main_only`/`orphan_branch`; o endpoint real retornou `plan[]`. Depois da
  resolução, o sandbox ficou em `main` com um nó e a tela ficou silenciosa.
- O harness local `App/scripts/atlas-code-sandbox.sh` também foi exercitado em
  create→resolve. O `/tmp` do container e o `/tmp` do Mac foram mantidos
  explicitamente separados para não falsificar o gate.

## 2026-07-15T06:18Z · Ciclo E4 heal + undo

- Sandbox: baseline `main` e branch `atlas-code-cobaia` foram capturados antes
  da ação. `mode=heal` executou o plano sem aprovação humana e gravou dois
  recibos; o scan seguinte não tinha violações.
- `undo` restaurou a referência de `main`, manteve a branch com o hash original,
  deixou o worktree limpo e retornou `state=byte_for_byte`/dois passos restaurados.
- O ciclo corrigiu duas falhas de prova encontradas ao vivo: o ledger devolve
  eventos como arrays e a resposta de heal não podia usar união de arrays para
  substituir `step_receipts`. O observe posterior oculta recibos já desfeitos.

## 2026-07-15T06:19Z–06:23Z · Ciclo E4/E2 visual

- Após uma segunda cura no mesmo sandbox, o simulador exibiu `Recibo de cura`,
  `CURADO SOZINHO`, `você não foi necessário`, os dois passos e somente o veto
  retroativo `Desfazer — com recibo`; não existe ação de aprovação.
- O undo foi repetido e verificado byte a byte. A proveniência foi aberta no
  simulador pelo cartão de commit; para a cobaia sem ledger, a tela exibiu
  `Por que esta linha existe` + `sem proveniência registrada`.

## 2026-07-15T06:24Z · Ciclo E5 reconciliado

- Preflight real no sandbox bloqueou `merge_ff` para `atlas-code-cobaia` por
  `main_only`, com notificações desligadas; a branch foi removida depois.
- `/api/code/week` retornou janela `2026-07-08..2026-07-15`, `1` commit, `2`
  curas, `1` prevenção e `0` aguardando. A contagem independente de Git deu `1`
  commit; SQL direto do ledger deu `2` heal IDs distintos e `1` preflight
  bloqueado. `notifications.enabled=false` em todos os probes.
- Gates físicos do iPhone continuam `device-pending`; esta vigília fecha as
  provas de simulador/container, não inventa prova de aparelho físico.

## 2026-07-15T06:26Z · Regressão final do executor

- Após a correção, o POST `mode=heal` devolveu imediatamente dois
  `step_receipts` completos (`cite_rule_to_agent`, `merge_ff`), e não apenas no
  observe seguinte.
- O undo voltou a `state=byte_for_byte`; a branch efêmera foi removida e o
  sandbox terminou limpo em `main`. A contagem final da semana passa a ser `1`
  commit Git, `3` heal IDs e `1` preflight bloqueado.
