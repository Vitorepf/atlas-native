# atlas-native

App iOS nativo do Atlas — a casca SwiftUI que encaixa no **atlas-server** local.
Inteligência, memória e execução moram no servidor; este repo entrega a experiência.

## Stack

- Swift 6 · SwiftUI · Strict Concurrency
- Zero dependências externas (Foundation / SwiftUI / ImageIO / CryptoKit / Charts)
- SPM: `AtlasCore`, `AtlasImaging`, `AtlasCoreChecks`
- App em `App/` (XcodeGen → `make build`)

## Rotas do produto

Home · Conversa · Workspaces · Busca · Autônomos · Código · (Arena — medição dos motores)

## Gates (antes de qualquer commit)

```bash
swift run AtlasCoreChecks
cd App && make build
git diff --check
```

Wire/contrato → `ATLAS_LIVE=1 ATLAS_TOKEN=… swift run AtlasCoreChecks`.
Visual → screenshot / XCUITest; device físico quando a prova exigir.

## Coordenação

- Blackboard: [`OBRA.md`](OBRA.md)
- Plano ativo: [`docs/plano-profundidade-total.md`](docs/plano-profundidade-total.md)
- Rich input: [`docs/rich-input-shared-core.md`](docs/rich-input-shared-core.md)
- Arena (M61): [`docs/spec-arena-medicao.md`](docs/spec-arena-medicao.md)

Lanes: **Codex** = `Sources/*` + lógica dos models; **Fable** = views / design system.
Pedidos entre lanes → OBRA §5.

## Servidor

OrbStack `atlas-backend` :3737 em `/Users/vitorepf/develop/Atlas/atlas-server`.
Token: `ATLAS_TOKEN` (Secrets.xcconfig / env do live-probe).

## Branch

Main local apenas. Commits escopados; nunca `git add -A`.
