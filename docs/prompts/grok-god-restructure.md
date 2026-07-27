# Grok — GOD RESTRUCTURE v4 (24h · até cancelar · grind)

> Padrão dos prompts que **rodaram horas**: Goal **até cancelar** · `/loop` reacorda · **Não pare**.  
> **1 Grok · zero dual · zero WAVE de produto · fila DEBTS · sem god_hold.**  
> Missão: estado GOD do código **já existente** — achar / entender / manter / evoluir para IA.

v3/v2 falharam porque “até GOD_HOLD” + soft opcional → Goal Done em minutos. **v4 mata isso.**

---

## Norte

Padronizado · organizado · denso agent-optimal · lógica simples · nomes honestos · CODEMAP verdadeiro · gates verdes.

**Não** é evolução de produto. Se não melhora compreensão/manutenção para IA → **não faça**.

---

## Lei de leitura (ordem)

1. `OBRA.md`  
2. `docs/prompts/grok-god-code-canon.md`  
3. Este prompt  
4. `docs/evidence/2026-07-21-grok-god-restructure/DEBTS.md` ← **cursor**  
5. `App/Atlas/CODEMAP.md`  
6. `docs/evidence/2026-07-21-grok-god-restructure/LEDGER.md`  
7. `docs/prompts/grok-god-restructure-START.md`

---

## Território

| Pode | Não pode |
|---|---|
| `App/Atlas/**` casca UI | `Sources/**` |
| `App/Widgets/**` chrome vivo | Lógica nova `ConversationModel` / `AtlasSession` |
| CODEMAP + evidence desta missão | Makefile / project.yml |
| DEBTS + LEDGER | Domínio/tab/feature nova · WAVE produto |

---

## Vocabulário FECHADO

### Sufixos de arquivo (só estes)

`View` · `Shell` · `Surface` · `Judgment` · `Chrome` · `Body` · `Row` · `Card` · `Sheet` · `Pack` · `AskContext` · `Types` · `Format` · `A11y` · `Model`

**Matar como sufixo:** `Grammar`, `Peel`, `Face` (arquivo), `JudgmentChrome`, `ScreenJudgment`, `Sections`/`States` soltos → viram `Body` / `Surface` / `Chrome` / estados dentro do host.

### Famílias de método

`spoken…` · `packFacts` / `pack…Facts` · `rank…` · `format…` · `a11y…` · `…Face` (enum) · `can…` / `allows…`

---

## Densidade

| Camada | Alvo | Fail |
|---|---|---|
| `*View` / `*Shell` rota | 200–500 | **>600** |
| Judgment / Pack / Format | 200–700 | **>1200** |
| Surface / Card / Sheet 1 domínio | 400–1200 | **>2000** |
| Qualquer casca `.swift` | — | **>2000** ou 2+ domínios |

**SPLIT** se 2+ domínios ou host acima do teto.  
**FUSE** se mesmo tipo/host, peel &lt;~120 LOC, ↓LOC líquido.  
**Nunca** fundir Conversation × ChangeReview × Plan × Arena.

---

## Layout (&gt;~200 LOC)

```
// MARK: - Types
// MARK: - State / Inputs
// MARK: - Body
// MARK: - Sections
// MARK: - Actions
// MARK: - A11y
// MARK: - Helpers
```

---

## Máquina de estados (24h — sem god_hold)

```
BOOT → AUDIT → PICK(DEBTS) → ACT → PROVE → COMMIT → DEBTS+LEDGER → AUDIT → …
gate fail → HALT_FIX → AUDIT
```

| Fase | Faz |
|---|---|
| BOOT | lê canon + DEBTS + CODEMAP + ledger |
| AUDIT | dívidas do `domain_index` + soft global (`rg`/`wc`) |
| PICK | **um** foco da checklist DEBTS |
| ACT | P1→P6 abaixo |
| PROVE | checks + provas no ledger |
| COMMIT | `polish(ui): GOD-RESTRUCTURE &lt;foco&gt;` → **já** próximo AUDIT |
| deepen | domínio limpo → `domain_index++` ou `pass+=1` — **nunca parar** |

### Ordem ACT

1. Delete morto  
2. Rename honesty  
3. Unificar `spoken` / `packFacts` / `rank`  
4. MARK + papel Chrome/Body  
5. Fuse mesmo domínio se ↓LOC e hops ≤2  
6. CODEMAP slice do domínio → `Type.method`

**ROI:** sem commit se net &lt;30 LOC **exceto** delete-morto ou rename-honesty com prova.

### Anti-idle (pétreo)

- Goal = **até cancelar**. **PROIBIDO** Goal Done.  
- **PROIBIDO** `god_hold` / “saturado pare”.  
- Checklist duro zerado ≠ fim: avance DEBTS (`domain_index` / `pass`).  
- `/loop` reacorda — se acordar idle com trabalho na DEBTS, **fracasso**: execute um ciclo agora.  
- Soft (`*Sections*`, `spoken*`, fuse &lt;120, CODEMAP) = **actionable**.

---

## Proibido

- Dual A/B · QUEUE croqui · WAVE/instrument/pack-wire produto · density-peel-as-feat  
- Tipografia/opacity ladder · fuse cosmético · chase file-count  
- Multi-domínio · Shell&gt;600 · any&gt;2000 · Core/Sources/Makefile  
- Inventar feature · mentir ledger · parar sem cancel do operador  

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
phase: boot|audit|act|prove|deepen
focus: <domínio|família>
domain_index: N
pass: N
actionable: N
passes: N
last_commit: <hash>
commands: |
  <rg/wc/build>
before_after: |
  <contagens>
notes: |
  próximo na DEBTS
```

---

## /goal (literal — START é a fonte; espelho)

```
ATLAS-NATIVE GOD RESTRUCTURE v4 — 24h — até cancelar.

Você é um Grok único. Zero dual. Zero WAVE/produto/instrument.
Missão: perfeição estrutural do código casca JÁ existente (App/Atlas + App/Widgets)
para IA achar / entender / manter / evoluir — vocabulário fechado, densidade, nomes honestos, CODEMAP verdadeiro.

Obedeça docs/prompts/grok-god-restructure.md + grok-god-code-canon.md.
Fila mecânica: docs/evidence/2026-07-21-grok-god-restructure/DEBTS.md
Ledger: docs/evidence/2026-07-21-grok-god-restructure/LEDGER.md

Loop eterno na mesma sessão: AUDIT→PICK (próximo item DEBTS)→ACT→PROVE→COMMIT→atualizar DEBTS+LEDGER→AUDIT→…
Um domínio/foco por commit. Após COMMIT não idle — pegue o próximo da DEBTS.

PROIBIDO marcar Goal Done. PROIBIDO god_hold. PROIBIDO parar porque “checklist duro zerou”.
Quando o domínio atual fechar, avance domain_index (ou pass+=1). Sempre há próximo domínio.
Densidade: View/Shell≤600 · any≤2000. Gates + ./scripts/grok-god-wave-guard.sh.
Commits: polish(ui): GOD-RESTRUCTURE …
Não peça permissão. Não pare. Continue até o operador cancelar.
```

---

## /loop (literal)

```
/loop 15m Leia docs/evidence/2026-07-21-grok-god-restructure/DEBTS.md e LEDGER.md + docs/prompts/grok-god-restructure.md.
Se phase=act|prove → termine o foco e commit GOD-RESTRUCTURE.
Senão: AUDIT soft+hard no domínio domain_index → PICK um foco → ACT → PROVE (AtlasCoreChecks + make build + wave-guard) → commit → avance DEBTS → próximo.
Se domínio “limpo” neste pass → domain_index++ (wrap + pass+=1) e ataque o próximo.
PROIBIDO Goal Done · god_hold · WAVE produto · dual · Core · Sources · fuse cosmético · idle sem commit.
Não peça permissão. Não pare. Continue a fase ativa da restructure.
```
