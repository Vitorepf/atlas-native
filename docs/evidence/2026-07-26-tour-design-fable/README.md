# 26/07 · Tour de design — antes e depois (Fable)

25 superfícies capturadas por rodada pelo `AtlasDesignTourTests` no simulador
(iPhone 17 Pro, iOS 26.5), com **dados reais** do servidor.

- `antes/` — estado no início da auditoria (commit `2da56081`)
- `depois/` — após `2e249e06`

## Como reproduzir

```bash
cd App && xcodebuild -project Atlas.xcodeproj -scheme Atlas \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath build-sim -resultBundlePath build-sim/DesignTour.xcresult \
  -only-testing:AtlasDeviceProof/AtlasDesignTourTests test
xcrun xcresulttool export attachments \
  --path build-sim/DesignTour.xcresult --output-path <destino>
```

## Duas notas que contradizem o que estava escrito

**1. O simulador não está bloqueado.** `CLAUDE.md` e OBRA §2 afirmam que "Wispr
Flow bloqueia verificação no simulador; device é a prova". O tour rodou inteiro
8/8, quatro vezes seguidas, dirigindo toques, swipes e teclado sem interferência.
O que impedia a bateria era o `enum A11yID` fora do glob do target de teste —
erro de build, não de ambiente. O device continua sendo a prova final para
tipografia e haptics; o simulador serve, e bem, para o resto.

**2. O backend do container está morto.** `atlas-backend` em crash-loop
(`Unresolvable dependency [callable $pendingPacketsSource]` em
`AtlasMaestroPriorityFactSnapshotter`) — imagem com código antigo. No host o
artisan sobe normal. Esta auditoria rodou contra `php artisan serve` local na
3737. **Não é problema da casca**; fica registrado para quem cuida do server.
