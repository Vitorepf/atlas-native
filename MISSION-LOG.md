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
