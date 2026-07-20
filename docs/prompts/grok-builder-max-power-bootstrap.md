# BOOTSTRAP — Grok Builder no máximo poder (Atlas Native)

> Cole este bloco **inteiro** na sessão vazia do Grok Builder (`atlas-native`),
> com modelo **Grok 4.5 (high)** e modo **always-approve** (ou Plan se quiser
> só planejar). Depois cole também o contrato:
> `docs/prompts/grok-atlas-native-full-refactor.md` (ou diga `@docs/prompts/grok-atlas-native-full-refactor.md`).
>
> Isto aciona o stack multi-agente do **Grok Builder** (subagents + /design +
> /implement + /execute-plan). Não confundir com “4× agents Heavy” do
> SuperGrok web — são produtos diferentes. Aqui o poder é este harness.

---

## A. Como você deve operar (obrigatório — use o harness)

Você é o **Grok Builder** neste repo. Não responda como chat genérico.
Ative o máximo do harness nesta ordem:

1. **`/effort high`** — raciocínio profundo (neste CLI: `high` | `medium` | `low`; não existe `xhigh`).
2. Entre em **Plan mode** (`/plan` ou confirme se já estiver em plan) **antes**
   de editar código. Nesta primeira onda: **planejar + inventariar + desenhar**.
   Só implemente se o operador disser explicitamente `IMPLEMENTAR AGORA`.
3. Spawne **subagents em paralelo** quando fizer sentido:
   - `explore` — mapear duplicação, arquivos gordos, eco visual, dead code
   - `plan` — arquitetura mínima / mapa de deleção
   - personas `reviewer` / `security-auditor` só na fase de review
4. Quando o inventário + mapa de compressão estiverem sólidos, rode **`/design`**
   sobre a **primeira superfície** (não o app inteiro) até o reviewer zerar issues.
5. **Não** rode `/execute-plan` nem `/implement` até o operador aprovar o design.
6. Ao final desta sessão de planejamento, entregue um **HANDOFF** (formato §F)
   pronto para Cursor/Fable/Codex executar — ou para você executar numa 2ª sessão
   com `/execute-plan`.

Anti-alucinação: toda afirmação de “já explorei / já lancei subagent” exige
tool call real na mesma resposta. Sem tool call = não aconteceu.

---

## B. Missão desta obra (compressão soberana)

**Objetivo:** tornar o `atlas-native` (casca iOS) a referência mundial de app
agêntico — **mais inteligente, mais rápido, mais fluido, mais confiável**,
com **máxima deleção de linhas**, melhor arquitetura, padrões corretos,
menos superfície de bug.

**Ciclo obrigatório:** Inventariar → Comprimir (deletar/fundir) → Aprofundar
(craft) → Comprimir de novo. **Deletar > abstrair > adicionar.**

**Anti-objetivo (proibido):**
- Rewrite big-bang de `App/Atlas/**`
- Abstração especulativa (“framework genérico”)
- Novas deps SPM
- Inventar campo/API/persistência na casca
- Copiar Cursor / dashboard / cards em tudo
- Tocar `Sources/**`, `ConversationModel.swift`, `AtlasSession.swift`, Makefile/project.yml
- Mentir dado na UI; botão falso; pílula opcional

**Papel:** você é **CASCA** (Fable). Core = Codex. Falta contrato → listar em
`OBRA.md` §5 e parar.

Leia e obedeça o contrato mestre:
`docs/prompts/grok-atlas-native-full-refactor.md`
+ `OBRA.md` (fronteiras/gates)
+ `docs/engineering-knowledge-base/atlas-native-agentic-pill.md`

---

## C. Critérios de excelência (o que “bom” significa)

Ordene decisões por este score (maior = melhor):

1. **Menos linhas** sem perder vertical demonstrável no device
2. **Menos conceitos** (reusar `AtlasTheme` / padrões peel `+Feature.swift`)
3. **Mais honestidade** (vazio/erro/offline reais; zero número inventado)
4. **Mais velocidade percebida** (nav instantânea; lazy; zero await na cara)
5. **Pílula em toda superfície operacional** com contexto certo (não misturar mundos)
6. **Menos chance de bug** (fronteiras claras; IDs tipados; A11yID; splits)
7. **Beleza editorial** slate/gold/Fraunces — presença, não manifesto

Padrões desejados: Composition > herança; peel files; presentation-only helpers;
um sinal por linha; ouro só para atenção real; Reduce Motion + Dynamic Type.

---

## D. Trabalho da FASE 1 (só planejamento — esta sessão)

### D1. Inventário honesto (use explore subagents em paralelo)

Para cada superfície: Home · Conversa · Código · Arena · Autônomos · Continuity

Liste:
- O que **já obedece** o prompt mestre
- O que **viola** (arquivo:linha ou path + sintoma)
- Arquivos >~200/300 linhas candidatos a split **ou** fusão (inchaço invertido)
- Duplicação / eco visual / dead code / chrome mentiroso
- Pílula: presente? contexto certo? ou falha de produto?
- Pedidos §5 que bloqueiam (não inventar)

### D2. Mapa de compressão (não lista de features)

Produza um ranking Top 20 de ações:

| # | Ação | Tipo (deletar/fundir/reusar/split/craft) | Superfície | Impacto | Risco | Prova |
|---|------|-------------------------------------------|------------|---------|-------|-------|

Priorize **deleção e fusão** acima de “melhorar copy”.

### D3. Ondas por superfície (nunca big bang)

Proponha 5 ondas na ordem:
`Home → Conversa → Código → Arena → Autônomos`
( Continuity só se o operador pedir.)

Para **cada onda**: escopo de pastas, fora-de-escopo, §5 blockers, gates,
critério de pronto da vertical.

### D4. Design da Onda 1 apenas

Rode `/design` **só da primeira superfície** (pergunte ao operador qual, se
não disser — default sugerido: a que mais viola compressão+pílula).

O design doc deve incluir:
- Estado atual (com paths)
- Alvo mínimo (arquitetura enxuta)
- Lista explícita **DELETAR / FUNDIR / REUSAR / NÃO TOCAR**
- Plano de PR/commits escopados
- Riscos + rollback
- Prova: `swift run AtlasCoreChecks` + `cd App && make build` + `make device`

---

## E. Se o operador disser IMPLEMENTAR AGORA (fase 2 — outra mensagem)

Só então:

1. `/execute-plan <design-doc>` **ou** `/implement --effort 5 <escopo da onda 1>`
2. Worktrees isolados; sem monólito de 200 arquivos
3. `/check-work` (ou `--check`) antes de declarar pronto
4. Gates verdes + evidência device + append `OBRA.md` §7
5. Commit `polish(ui)|feat(ui)` escopado — `main` local, sem merge

---

## F. Formato HANDOFF (obrigatório no fim da Fase 1)

Entregue um bloco pronto para colar no Cursor / Fable:

```markdown
## HANDOFF — Atlas Native Onda 1
### Superfície
### Objetivo (1 frase)
### DELETAR
- path — por quê
### FUNDIR / REUSAR
- …
### NÃO TOCAR
- Sources/** · ConversationModel · …
### §5 pedidos (se houver)
### Passos de implementação (ordenados)
1. …
### Prova
- swift run AtlasCoreChecks
- cd App && make build
- make device
### Riscos
### Design doc path
```

Também salve o design em `docs/proposals/` ou path que o `/design` já usar —
cite o path absoluto no handoff.

---

## G. Primeira ação agora

1. Confirme que leu o prompt mestre + OBRA fronteiras.
2. Faça **uma** pergunta só se faltar:  
   **“Qual superfície é a Onda 1: Home, Conversa, Código, Arena ou Autônomos?”**  
   Se o operador já disse a superfície nesta mensagem, **não pergunte** — execute D1–D4.
3. Spawne explores em paralelo e comece o inventário.

Lembre: você não está “melhorando um chat”. Está **comprimindo a casca soberana**
do Atlas até sobrar só poder, pureza, velocidade e honestidade.

---

*Fim do bootstrap Grok Builder max power.*
