# Varredura Apple-bar — dossiê consolidado (2026-07-18, Fable)

Goal do operador: "entrar em todas as telas, avaliar como a Apple faria,
simplificar, polir, gestos, funcionamento perfeito, AX/UX espetacular".
Método: tour visual com dados reais (XCUITest + screenshot avaliado) em toda
superfície alcançável sem dado vivo raro; auditoria de código profunda nas
demais; crítica → fix → gates → deploy no iPhone do operador (7 deploys hoje).

## Por superfície — avaliação, fixes e prova

| Superfície | Avaliação | Fixes (commits) | Prova |
|---|---|---|---|
| Home | 4 tours + 3 críticas diretas do operador | IA no modelo livre-OU-workspace `0d65f044` · glass `5845aa40` · sem pontos vermelhos + perfil `e218c7cf` · linha premium + pílula ✦ + Arena limpa `957a6f95` | `../2026-07-18-home-limpa/01..07` |
| Conversas livres (vazio) | tour dedicado | filtro só com conteúdo `33542f7d` | `04-livres-vazio-limpo.png` |
| Workspace (lista com 85) | tour search+workspace | chips de área já gated; "novo" saturado é da mesma régua (abaixo) | `/tmp` tour sw |
| Workspaces (gestão) | crítica "falha miseravelmente" + referência Cursor | top-3 recentes + Adicionar + picker 13 repos reais + conversa nasce no repo `4e6abbd3` | `06-add-workspace-picker.png` |
| Busca | tour vazio+resultados | gesto voltar `0fe1ce7b`/`a758599d` · "novo" 9/9 saturado silenciado `25a26b3f` | tour sw + bateria |
| Conversa (thread) | tour com thread real + AXXXL | corpo markdown escala `fd25873d` · "editar e reenviar" sem mono `fc602bf4` · gesto voltar | `../2026-07-18-dynamic-type/` |
| Arena | 2 tours + hero device | scroll-edge nativo `48d877f7` · suítes bastidor `c3633d5`* · sublinha some da home `957a6f95` | `../2026-07-18-scroll-edge/` |
| Código (radar+grafo) | 2 tours + fluxo E2E | voz tipográfica `fc602bf4` · SIGSEGV morto + bateria estável `146f3e6b` · scroll-edge `48d877f7` | post-mortem OBRA §7 |
| Review/Execution/Artifacts/Plan/Nightly/sheets | auditoria de código (6 achados) | tokens cor/motion + A11yIDs críticos + serif fora de lista `01175e4c` | OBRA §7 |
| Perfil (novo) | ordem direta | sheet padrão com dados honestos + toggle auditoria `e218c7cf` | `05-perfil-sheet.png` |

*com o agente paralelo (mesma missão, pistas coordenadas).

## Gestos
- Voltar pela borda: restaurado nas 4 telas de chrome próprio; prova executável
  `AtlasSwipeBackTests` (edge-swipe real) verde na bateria. Arena/Código/Review
  usam barra nativa (gesto nunca morreu).
- Swipe/scroll: coalescido (SOTA F2); sheets nativas com drag-to-dismiss.

## AX (acessibilidade)
- Dynamic Type TOTAL: zero fonte fixa na casca (110 sites + markdown);
  prova AXXXL em `../2026-07-18-dynamic-type/`.
- Reduce Motion: 100% gated (auditoria varreu; zero animação sem guarda).
- VoiceOver: labels falados por elemento nas telas (entregas anteriores) +
  A11yIDs nos controles críticos do Execution `01175e4c`.
- Chips/overflow alcançáveis em AXXXL `9494ba2a`.

## Canons documentados hoje (o sistema que segura o nível)
`AtlasGlassCircle`/`Capsule` (§6) · `AtlasTheme.Radius` · `.atlasSans`
(curva Apple pré-computada, thread-safe) · durations → `AtlasMotion` ·
linha premium do site (sectionLabel/rowDivider) · régua do "novo" saturado.

## Honesto — o que segue aberto
- Prova física fina (háptica, ProMotion, OLED, Instruments N8): mão do operador.
- Sugestões do card de conversa da pílula do Código (agente vivo) — sessão própria.
- VoiceOver: colapso de container do iOS 26 (label da tela no botão da pílula) —
  task dedicada aberta.
- Fila de padrão: escala de espaçamento completa, primitiva única de chip e de
  empty state, contraste do texto terciário (~3:1; muda identidade, pede olho
  do operador).
- Bateria completa desta noite: resultado no rodapé deste dossiê.

## Bateria completa (2026-07-18 19:21, iPhone 17 Pro Max sim, build limpo)
**17 testes · 14 verdes** — 8/8 tours de design (Home, Autônomos, Arena,
Código, Conversa+thread, Livres, Perfil, Busca+Workspace, AddWorkspace),
Arena flow E2E, Código hub→radar→grafo→proveniência, LiveNow com sessão
viva, Nightly card→sheet, Ritmo, edge-swipe de voltar. Falhas (2, conhecidas
e registradas): sugestões do card da pílula (agente vivo — sessão própria) e
harness de tool ao vivo do device-proof. Rodada final da home 10/10:
`../2026-07-18-home-limpa/08-home-10de10.png`.

**Lição operacional carimbada:** SIGSEGV `incrementSlow` em buildExpression
com sítio variável = corrupção de BUILD INCREMENTAL do DerivedData (provado
2× por clean-build: radar e masthead). Bateria/captura: sempre build limpo.
