# Grok — GOD RESTRUCTURE v2 (consenso · um processo · perfeição mensurável)

> Consenso de 3 especialistas + operador:  
> **1 Grok · zero dual · zero WAVE de produto · audit-driven · HOLD quando saturado.**  
> Missão: estado GOD do código **já existente** — achar / entender / manter / evoluir para IA.

---

## Norte

Atlas Native casca no estado mais perfeito possível **do que já tem**:

padronizado · organizado · denso agent-optimal · lógica simples · nomes honestos · CODEMAP verdadeiro · gates verdes.

**Não** é evolução de produto. Se não melhora compreensão/manutenção para IA → **não faça**.

---

## Por que dual morreu (não repetir)

1. Fila vazia → inventar trabalho (fuse / micro-WAVE)  
2. Papéis A/B criavam pressão de “próximo produto”  
3. Ledger contava movimento, não saturação  

**Lei:** sem dívida nomeada no AUDIT → **não edita**. Empty audit ×2 → `god_hold`.

---

## Lei de leitura

1. `OBRA.md`  
2. `docs/prompts/grok-god-code-canon.md`  
3. Este prompt  
4. `App/Atlas/CODEMAP.md`  
5. `docs/evidence/2026-07-21-grok-god-restructure/LEDGER.md`

---

## Território

| Pode | Não pode |
|---|---|
| `App/Atlas/**` casca UI | `Sources/**` |
| `App/Widgets/**` chrome vivo | Lógica nova `ConversationModel` / `AtlasSession` |
| CODEMAP + evidence desta missão | Makefile / project.yml |
| | Domínio/tab/feature nova |

---

## Vocabulário FECHADO (consenso)

### Sufixos de arquivo (só estes)

`View` · `Shell` · `Surface` · `Judgment` · `Chrome` · `Body` · `Row` · `Card` · `Sheet` · `Pack` · `AskContext` · `Types` · `Format` · `A11y` · `Model`

| Sufixo | Papel |
|---|---|
| View / Shell | rota / stack — fino |
| Surface | composição **um** domínio |
| Judgment | regras puras + faces |
| Chrome | moldura compartilhada |
| Body | seção do **mesmo** host |
| Pack / AskContext | packing / pílula |
| Row · Card · Sheet | um objeto UI |
| Types · Format · A11y | apresentação / ids |
| Model | @Observable casca only |

**Matar como sufixo:** `Grammar`, `Peel`, `Face` (arquivo), `JudgmentChrome`, `ScreenJudgment`, `Sections`/`States` soltos.

### Famílias de método (só estas)

`spoken…` · `packFacts` / `pack…Facts` · `rank…` · `format…` · `a11y…` · `…Face` (enum) · `can…` / `allows…`

Tipo carrega o domínio — método **não** repete (`onAppear` no tipo certo, não `conversationPresenceOnAppear`).

---

## Densidade (consenso)

| Camada | Alvo | Fail |
|---|---|---|
| `*View` / `*Shell` rota | 200–500 | **>600** |
| Judgment / Pack / Format | 200–700 | **>1200** |
| Surface / Card / Sheet 1 domínio | 400–1200 | **>2000** |
| Qualquer casca `.swift` | — | **>2000** ou 2+ domínios |
| Soft floor | preferir ≥80 se mesmo tipo | peels &lt;40 = fundir |

**SPLIT** se: 2+ domínios · regra pura sai pra Judgment · host passa orçamento · objeto ≥~150 LOC com lifecycle próprio.  
**FUSE** se: mesmo tipo (`extension Foo`), mesmo domínio, peel &lt;~120 LOC / one-method.  
**Nunca** fundir Conversation × ChangeReview × Plan × Arena.

---

## Layout interno (&gt;~200 LOC)

```
// MARK: - Types
// MARK: - State / Inputs
// MARK: - Body
// MARK: - Sections
// MARK: - Actions
// MARK: - A11y
// MARK: - Helpers
```

Tipo **antes** de extensions. Proibido `MARK: Peels` e extension one-method sem MARK.

---

## Máquina de estados

```
BOOT → AUDIT → PICK → ACT → PROVE → COMMIT → LEDGER → AUDIT
                              ↑_____________________|
AUDIT actionable=0 × 2 → GOD_HOLD  (não inventar trabalho)
gate fail / cheiro de produto / Core → HALT_FIX → AUDIT
```

| Fase | Faz |
|---|---|
| BOOT | lê canon + CODEMAP + ledger |
| AUDIT | lista dívidas com prova `rg`/`wc` |
| PICK | **um** foco (domínio ou família de nomes) |
| ACT | P1→P5 abaixo |
| PROVE | checks + provas coladas no ledger |
| COMMIT | `polish(ui): GOD-RESTRUCTURE &lt;foco&gt;` |
| GOD_HOLD | para de editar; espera operador |

### Ordem ACT (P1→P5)

1. **Delete morto** — `rg` = 0  
2. **Rename honesty** — Grammar→Judgment, Peel→Chrome/Body, matar `conversationPresence*`  
3. **Unificar métodos** — `spoken`/`packFacts`/`rank` igual ao ouro (Radar/Arena Judgment)  
4. **MARK + papel Chrome/Body**  
5. **Fuse mesmo domínio** só se ↓LOC líquido **e** hops IA ≤2  
6. **CODEMAP** — “onde muda X” → `Type.method` (zero WAVE como navegação)

**ROI:** sem commit se net &lt;30 LOC **exceto** delete-morto ou rename-honesty com prova.

---

## Barra GOD (DONE mensurável)

Pode declarar saturação só se **tudo** verde num AUDIT (colar saídas):

1. `AtlasCoreChecks` + `make build` exit 0  
2. 0 arquivo casca &gt;2000; 0 `*View`/`*Shell` rota &gt;600  
3. `rg JudgmentGrammar` → 0 (ou 1 alias documentado)  
4. `rg 'Peel|conversationPresence'` → 0  
5. Família `spoken|packFacts|rank` sem dialetos competindo por domínio  
6. Arquivos &gt;200 LOC com MARK canônico  
7. CODEMAP: filenames citados existem; hot paths → `Type.method`  
8. Janela da missão: 0 `feat(ui): WAVE` / instrument / pack-wire produto  
9. Ledger: `actionable: 0` em **2** audits seguidos  

DONE = **sem dívida acima do ROI**, não “perfeição eterna”.

---

## Proibido (lista pétrea)

- Dual A/B · QUEUE croqui · WAVE/instrument/pack-wire produto · density-peel-as-feat  
- Tipografia/opacity ladder · fuse cosmético · chase file-count · chase LOC cego  
- Multi-domínio · Shell&gt;600 · any&gt;2000 · Core/Sources/Makefile  
- Inventar trabalho com audit vazio · mentir ledger  

---

## Commits / Gates

```
polish(ui): GOD-RESTRUCTURE <foco>
```

```bash
swift run AtlasCoreChecks
cd App && make build
./scripts/grok-god-wave-guard.sh
```

Stage explícito. `main` local. Sem `git add -A`.

---

## Ledger (schema)

```yaml
phase: boot|audit|act|prove|god_hold
focus: <domínio|família|null>
actionable: N
passes: N
last_commit: <hash|null>
collapse_host: 0
commands: |
  <rg/wc/build colados>
before_after: |
  <contagens>
notes: |
  dívida atacada / por que ROI
```

---

## /goal (literal)

```
ATLAS-NATIVE GOD RESTRUCTURE v2 — um Grok — até GOD_HOLD.

Zero dual. Zero WAVE/produto/instrument. Só código casca já existente.
Obedeça docs/prompts/grok-god-restructure.md + grok-god-code-canon.md.
Loop: BOOT→AUDIT→PICK→ACT→PROVE→COMMIT. Sem dívida no AUDIT = não edita.
actionable=0 × 2 → phase god_hold (não inventar fuse).
Vocabulário fechado: Judgment/Chrome/Body/Surface… · spoken/packFacts/rank.
Densidade: View/Shell≤600 · any≤2000 · um domínio/arquivo.
Gates + guard. Commits polish(ui): GOD-RESTRUCTURE …
Ledger: docs/evidence/2026-07-21-grok-god-restructure/LEDGER.md
Não peça permissão. Não invente feature. Entre em god_hold quando saturado.
```

---

## /loop (literal)

```
/loop 45m Leia LEDGER + CODEMAP + este prompt.
1) AUDIT: liste dívidas com rg/wc (Grammar|Peel|conversationPresence|View>600|any>2000|MARK faltando|CODEMAP mentindo|spoken dialeto).
2) Se actionable=0: se já foi 0 no audit anterior → phase god_hold e PARE DE EDITAR. Senão só atualize ledger.
3) Senão PICK um foco → ACT P1–P5 → PROVE (checks+build+guard) → commit GOD-RESTRUCTURE → ledger com commands/before_after.
PROIBIDO WAVE produto, dual, tipografia, Core, fuse cosmético, inventar trabalho.
```
