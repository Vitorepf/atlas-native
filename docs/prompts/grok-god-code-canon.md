# Atlas Native — GOD CODE CANON (agent-optimal)

> Código da casca feito para **IA ler, navegar e editar com zero atrito**.  
> Humanos também ganham. Contagem de arquivos **não** é métrica de sucesso.  
> Canon vivo: **GOD RESTRUCTURE v2** (`docs/prompts/grok-god-restructure.md`) — um Grok, audit-driven, `god_hold` quando saturado.  
> Dual A/B e WAVEs de produto: **OFF**.

---

## 1. Norte

**GOD code** = padronizado · organizado · denso · um domínio por arquivo · nomes honestos · menos linhas *por intenção* (não por obsessão).

Era agêntica: floresta de peels (50 LOC × milhares) **e** monólito 5k+ são os dois venenos.  
Alvo: **módulos coesos que cabem em 1–2 reads de contexto**.

---

## 2. Domínios vivos (só estes)

| Domínio | Prefixo |
|---|---|
| Home | `Root*`, `Home*`, `Workspace*` |
| Conversa | `Conversation*` |
| Código / Grafo / Radar | `AtlasCode*` |
| Pílula agêntica | `Agentic*` |
| Arena Premium | `ArenaPremium*`, `Arena*` (suite/run/score) |
| Autônomos | `Autonomos*` |
| Continuity | Island / Lock / `Live*` ActivityKit chrome |
| Design system | `AtlasTheme*`, `AtlasType*`, `AtlasMotion*`, glass |

**Proibido:** domínio/tab/área nova. Continuity App Group / widgets data = BLOCKED até Core.

---

## 3. Vocabulário de arquivo (1 papel = 1 sufixo)

| Sufixo | Significa |
|---|---|
| `View` | entry / shell de rota — fino |
| `Shell` | orquestração de tabs/stack da superfície |
| `Surface` | composição **de um** domínio (não lixeira) |
| `Judgment` / `Grammar` / `Pack` | regra de produto pura (preferido GOD) |
| `Row` / `Card` / `Sheet` | UI de um objeto |
| `Chrome` | moldura compartilhada da superfície |
| `A11y` | ids + spoken **do mesmo domínio** |
| `Types` / `Format` / `Display` | apresentação / formatação |
| `Model` | @Observable casca — **não inventar Core** |

Se o nome não descreve o conteúdo → **renomear** (idle de alto valor).

---

## 4. Densidade agent-optimal (substitui dogma 400 global)

| Camada | Alvo | Hard fail |
|---|---|---|
| Shell / `*View` de rota | ≤ 500–600 | **> 600** |
| Judgment / Grammar / Pack / Format | 200–800 | **> 1200** |
| Surface / Card / Sheet **um domínio** | 800–1500 | **> 2000** |
| Qualquer `.swift` casca | — | **> 2000** ou **2+ domínios** |

Métrica boa: *1 read = 1 intenção completa*.  
Métrica ruim: chase de file-count; fuse cosmético; host collapse.

---

## 5. Layout interno obrigatório (arquivos > ~200 LOC)

```
// MARK: - Types
// MARK: - State / Inputs
// MARK: - Body
// MARK: - Sections
// MARK: - Actions
// MARK: - A11y
// MARK: - Helpers
```

Proibido: pilha de `extension Foo` sem MARK em arquivo denso.

---

## 6. Nomes de métodos

- Verbo + objeto de domínio: `rankReposBySeverity`, `openSuite`, `packTopAttention`
- Tipo já carrega o domínio → método **não** repete o prefixo do arquivo  
  (`ConversationPresence.onAppear` ≠ `conversationPresenceOnAppear` espalhado)
- Famílias estáveis: `spoken…` · `a11y…` · `rank…` · `pack…` · `format…`
- Regras puras → `enum` / `struct` estático (`AtlasCodeRadarJudgment` = padrão ouro)
- Bindings: tipos nomeados, não tuplas anônimas gigantes

---

## 7. Idle compress — ordem de valor (Grok B)

Só nesta ordem (pular o que não tiver ROI):

1. **Delete morto** — `rg` call sites = 0 (prova no commit)
2. **Extrair Judgment / Grammar / Pack** da View/Surface gorda
3. **Rename honesty** — sufixo/domínio/método alinhados ao canon
4. **MARK + ordem canônica** em arquivos densos
5. **Fundir peels do mesmo domínio** até a faixa agent-optimal
6. **Dedupe real** Theme/chrome/copy honesty

### Idle proibido

- Fuse cosmético (&lt;30 LOC net / rename-only fingindo compress)
- Colapsar 2+ domínios no mesmo arquivo
- Empurrar qualquer arquivo para &gt;2000
- Empurrar `*View`/`*Shell` de rota para &gt;600
- Token/opacity/fonte ladder como “compressão”
- Tocar `Sources/**`, `ConversationModel`, `AtlasSession`, Makefile, project.yml
- Área nova

Commits idle: `polish(ui): IDLE-COMPRESS …` com **motivo canônico**  
(ex.: `extract RadarJudgment`, `MARK ChangeReview`, `delete dead peel X`).

---

## 8. CODEMAP (mapa para IA)

Manter `App/Atlas/CODEMAP.md` curto e verdadeiro:

- superfície → arquivos canônicos
- “onde muda X” (Radar sort, pill pack, Island phase, …)
- BLOCKED honestos

Atualizar CODEMAP em todo W3 de WAVE e em idle que mude topologia.

---

## 9. Design system = lei

Cores, type, motion, glass: só `AtlasTheme` / `AtlasType` / `AtlasMotion` (+ primitives Atlas).  
Zero magic number visual ad hoc em idle.

---

## 10. Gate mental antes de commit

1. Um domínio?  
2. Nome honesto?  
3. MARKs se denso?  
4. Dentro da faixa de densidade?  
5. `AtlasCoreChecks` + `make build`?  
6. `./scripts/grok-god-wave-guard.sh`?  
7. CODEMAP precisa de 1 linha?

Se algum = não → não commit.
