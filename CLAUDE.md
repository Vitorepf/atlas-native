# atlas-native — instruções de agente (Fable 5 / Claude)

**Seu papel nesta obra: CASCA** — polir, melhorar o design, a experiência e
tudo que o operador vê e toca. Território: `App/Atlas/*View*.swift`, componentes
visuais, design system (`AtlasTheme/AtlasType/AtlasMotion` — slate teal + gold
+ Fraunces, identidade editorial PRÓPRIA, não cópia do Cursor), assets/ícone,
motion/haptics/acessibilidade. Você NÃO edita `Sources/*` nem a lógica dos
models — isso é do Codex (funciona). Precisa de dado/campo novo do model?
Registre em **OBRA.md §5 (Pedidos de contrato)**; helpers presentation-only
podem viver em `ConversationModel+UI.swift` (extension, sem lógica).

## Protocolo (obrigatório)
1. **Leia `OBRA.md` INTEIRO antes de trabalhar.** Fronteiras, gates, fila
   (§4, coluna Fable U1..U6), pedidos, decisões.
2. Antes de todo commit: `swift run AtlasCoreChecks` verde + `cd App && make
   build` verde. Mudança visual → `make device` + screenshot do operador
   (Wispr Flow bloqueia o simulador; o device é a prova).
3. Commits escopados `feat(ui)|polish(ui)`, branch main local, sem merges.
4. Ao entregar: atualize OBRA.md §7 (registro com PROVA) e marque a fila.
5. A casca fala SÓ com os models @Observable — nunca com endpoints. O boundary
   check do AtlasCoreChecks falha se `/ai/uploads` aparecer fora do engine.

## Leia também
- `OBRA.md` — o blackboard (fonte de verdade da coordenação)
- `docs/rich-input-shared-core.md` — dossiê do rich input (a strip/composer
  renderizam `LocalDraft`/`UploadProgress` — o único contrato de UI de anexos)
- Anti-inchaço: OBRA.md §3 — a lição do app RN. View >~200 linhas = split;
  estados vazio/erro/offline são feature, não afterthought; Reduce Motion e
  Dynamic Type sempre.
