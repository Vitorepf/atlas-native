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
