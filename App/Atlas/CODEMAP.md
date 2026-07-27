# Atlas Native — CODEMAP (casca)

> GOD RESTRUCTURE v4 continuous residual. Soft Sections/States = **0**. Density OK.
> Product chrome (títulos, vazios, acessibilidade, nav, widgets) vive nos
> Judgments de domínio.

## Vocabulário fechado — leia antes de nomear qualquer coisa

Os prefixos abaixo não são estilo: cada um marca **quem consome** aquele texto.
Trocar um pelo outro muda o significado, não só o nome.

| Prefixo | Quem consome | Exemplo |
|---|---|---|
| `product*` | O operador **lê** na tela. Português, linguagem humana, sem jargão. | `productChooserTitle = "Área da frota"` |
| `spoken*` | O VoiceOver **fala**. Frase corrida, minúscula, sem sigla. | `spokenClose = "fechar escolha de área"` |
| `productWord` | **Chave técnica** em inglês (facts do pack agêntico, `accessibilityValue`). **Nunca** vai para a tela. | `"finished"`, `"quiet"` |
| `pack*` | Fatos que alimentam a pílula agêntica. | `packFacts(...)` |
| `rank*` / `format*` | Ordenação e formatação puras, sem estado. | `rankedArtifacts(...)` |

Regra que já custou um bug: exibir `productWord` como selo pôs **`FINISHED`**
sobre "execução concluída" no card de conclusão. Se o operador lê, é `product*`.

### Acessibilidade — um nome por coisa

`a11y` é o numerônimo padrão da indústria (**a** + 11 letras + **y** =
*accessibility*), usado por Apple, W3C e Google. Curto porque aparece em
centenas de símbolos. O que **não** se admite é sinônimo:

| Coisa | Nome único | Não usar |
|---|---|---|
| Identificador para teste/XCUITest | `accessibilityID` (parâmetro) · `A11yID.foo` (constante) | ~~`a11yID`~~, ~~`a11yKey`~~ |
| Helper que aplica label/hint/id a uma view | sufixo `...A11y` | ~~`...A11yChrome`~~ |
| Texto falado | `spoken*` | ~~`voiceOver*`~~, ~~`accessibilityText`~~ |

Todo identificador vive em `A11yID.swift` — o target `AtlasDeviceProof` só
compila o glob `A11yID*.swift`, então uma constante fora dali derruba a
bateria de testes inteira com `Cannot find 'A11yID' in scope`.

## Régua visual — não invente degrau novo

Medido em 27/07: o app tinha **47 tamanhos de fonte** e **34 valores de
padding**, contra 2 tokens de espaço no tema. Os órfãos a ≤1pt de um vizinho
foram absorvidos (47→28 e 34→28). O resto da consolidação é trabalho aberto.

**Antes de escrever um número novo, use o degrau que já existe.** Verifique:

```bash
grep -ohE "AtlasFont\.(serif|serifItalic|mono)\([0-9]+" App/Atlas/*.swift | grep -oE "[0-9]+" | sort -n | uniq -c
grep -ohE "\.padding\([^)]*[0-9]+\)" App/Atlas/*.swift | grep -oE "[0-9]+" | sort -n | uniq -c
```

Se o valor que você quer aparece 1–2 vezes, ele é órfão: escolha o pico
vizinho. Degraus com uso real hoje:

| Família | Degraus vivos |
|---|---|
| `mono` | 9 (kicker) · 10 (meta, pico) · 11 · 12 · 13 |
| `serif` | 12 14 16 18 20 22 24 28 32 34 (+display 44/52/56/58/62) |
| `serifItalic` | 12 13 14 15 16 |
| `atlasSans` | 8 9 10 11 12 13 14 15 16 17 |
| `padding` | **sempre par.** Respiro: 2 4 6 8 10 12 14 16 18 20 22 24 · Bloco: 28 32 40 · Dock/âncora: 56 96 108 140 |

Espaço de tela e de linha **sempre** por token: `AtlasTheme.Space.screen` (20)
e `.row` (13) — nunca o número cru.

**Ímpar é bug.** Não existe padding ímpar na casca (fechado em 27/07: 34 → 20
valores, todos pares). Se você escrever `7` ou `9`, escolheu o degrau errado —
o vizinho par existe e alguém já o usou dezenas de vezes.

## Superfícies → host

| Superfície | Hosts |
|---|---|
| Home | `RootView` · `RootChrome` · `RootHomeBody` · `HomeOpsJudgment` · `HomeNightlyJudgment` · `LiveNowJudgment` |
| Conversa | `ConversationSurface` · Messages · Composer · Toolbar · Judgment families · `ConversationModel` |
| Código | `AtlasCodeSurface` · Radar · Provenance · Graph · MarkdownRender |
| Arena | `ArenaPremiumRoot` · Execution · Surfaces · Fleet/Live/Control Judgments |
| Autônomos | `AutonomosHost` · Map · Model · CanDo/FleetRun/Organs Judgments |
| Workspace/Search | `WorkspaceSurface` · `SearchSurface` |
| Review/Plan/Exec | `ChangeReview*` · `PlanCard` · `ExecutionStateCard` · `ArtifactSheet` |
| Continuity | `TurnPresence` · Widgets Host A/B |

## Onde muda X

| X | Host |
|---|---|
| Home kickers / LiveNow | `HomeOpsJudgment` · `RootHomeBody` · `LiveNowJudgment` |
| Nightly | `HomeNightlyJudgment` |
| Mid-thread / steer / outline | `ConversationSurface` · Messages/Steer/Outline Judgments |
| Composer attach/mode/workspace | `ConversationComposer` · `ComposerToolbar` / Sheet/Effort Judgments |
| Execution / Plan | `ExecutionStateCard` · `PlanCard` |
| Change review | `ChangeReviewSurface` · Control/Sheet/Risk Judgments · Body |
| Radar / Provenance / Graph | `AtlasCodeRadarSurface` · ProvenanceSheet · Graph · Surface |
| Arena product empties/actions | `ArenaNowJudgment` · Surfaces · Root/Execution |
| Autônomos product faces | `AutonomosListJudgment` · Host · Map |
| Widgets product | `LiveSessionWidgetA11y` · `FleetWidgetA11y` |

## BLOCKED

Sources · ConversationModel/AtlasSession **logic** · App Group data · WAVE produto

## Proibido restructure

Goal Done · god_hold · dual · Core paths
